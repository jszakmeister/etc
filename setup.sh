#!/bin/bash

cd $(dirname $0)

# If the path is under HOME, then make it relative
PATH_TO_ETC=${PWD/$HOME\//}
ETC_HOME=${PWD/$HOME\//\$HOME\/}
TILDE_ETC_HOME=${PWD/$HOME\//~\/}
CONFIG_HOME=${XDG_CONFIG_HOME-$HOME/.config}

if [ "$PATH_TO_ETC" != "projects/etc" ]; then
    SET_ETC_HOME="ETC_HOME=\"$ETC_HOME\""
    SOURCE_PREFIX="\$ETC_HOME"
else
    SET_ETC_HOME=""

    # Use ETC_HOME as the source prefix because the shell may be coming up in
    # a directory other than home.  This is common in Fedora, where a new
    # terminal will start you in the current working directory.
    SOURCE_PREFIX="$ETC_HOME"
fi

# Record the date and time for backups
save_date=$(date "+%Y%m%d-%H%M%S")

_backupFile() {
    local origFile="$1"
    local newFile="$origFile.$save_date"

    test -e "$origFile" &&
        mv "$origFile" "$newFile" &&
        echo "Saved old '$origFile' as '$newFile'"

    return 0
}

_maybeInstall() {
    local s="$1"
    local file="$2"
    local base=$(basename "${file}")

    echo "Checking ${base}..."

    (test -e "$file" && grep -F -x -q "${s}" "$file") ||
        (_backupFile "$file" &&
         ((test -n "$SET_ETC_HOME" && echo "$SET_ETC_HOME" > "$file") ||
          : > "$file") &&
         echo "$s" >> "$file" &&
         echo "Installed $base")
    return 0
}

# Set up links to configuration bits

echo "Checking .inputrc..."
test ! -e "$HOME/.inputrc" && \
    ln -s "$PATH_TO_ETC/inputrc/inputrc" "$HOME/.inputrc" &&
    echo "Installed .inputrc"

echo "Checking .tmux.conf..."
test ! -e "$HOME/.tmux.conf" &&
    ln -s "$PATH_TO_ETC/tmux/tmux.conf" "$HOME/.tmux.conf" &&
    echo "Installed .tmux.conf"

echo "Checking .gitconfig..."
test ! -e "$HOME/.gitconfig" &&
    cat gitconfig/gitconfig |
        sed -e "s|~/projects/etc|$TILDE_ETC_HOME|" > "$HOME/.gitconfig" &&
    echo "Installed .gitconfig" &&
    echo 'Run the following to set the git user name:
    git config --global user.name "User Name"' &&
    echo 'Run the following to set the git user email:
    git config --global user.email "user@example.com"'

echo "Checking .quiltrc..."
test ! -e "$HOME/.quiltrc" && \
    ln -s "$PATH_TO_ETC/quilt/quiltrc" "$HOME/.quiltrc" &&
    echo "Installed .quiltrc"

echo "Checking .colordiffrc..."
test ! -e "$HOME/.colordiffrc" && \
    ln -s "$PATH_TO_ETC/colordiffrc/colordiffrc" "$HOME/.colordiffrc" &&
    echo "Installed .colordiffrc"

echo "Checking svnwrap config..."
test ! -e "$CONFIG_HOME/svnwrap/config.ini" &&
    mkdir -p "$CONFIG_HOME/svnwrap" &&
    cp "svnwrap/config.ini" "$CONFIG_HOME/svnwrap/config.ini" &&
    echo "Installed svnwrap config"

if [ "$(uname)" == "Darwin" ]; then
    echo "Checking .editrc..."
    test ! -e "$HOME/.editrc" &&
        ln -s "$PATH_TO_ETC/editrc/editrc" "$HOME/.editrc" &&
        echo "Installed .editrc"
    mkdir -p $HOME/Library/Fonts &&
        cp fonts/*.ttf $HOME/Library/Fonts &&
        echo "Installed custom fonts"
fi

if [ "$(uname)" == "Linux" ]; then
    mkdir -p $HOME/.fonts &&
        cp fonts/*.ttf $HOME/.fonts &&
        echo "Installed custom fonts"
fi
_maybeInstall "source \"$SOURCE_PREFIX/bash/bashrc\"" "$HOME/.bashrc"
_maybeInstall "source \"$SOURCE_PREFIX/zsh/zshenv\"" "$HOME/.zshenv"
_maybeInstall "source \"$SOURCE_PREFIX/zsh/zshrc\"" "$HOME/.zshrc"
