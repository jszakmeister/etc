PATHS_TO_PREPEND=
PATHS_TO_APPEND=

test -n "$TMUX" && export TERM="screen-256color"

test -d "$HOME/bin" &&
        PATHS_TO_PREPEND=$(append_path "$PATHS_TO_PREPEND" "$HOME/bin")

test -d "$HOME/.local/bin" &&
        PATHS_TO_PREPEND=$(append_path "$PATHS_TO_PREPEND" "$HOME/.local/bin")

test -d "$HOME/local/bin" &&
        PATHS_TO_PREPEND=$(append_path "$PATHS_TO_PREPEND" "$HOME/local/bin")

if [[ "$platform" == 'darwin' ]]; then
    # We compute the path to the standard framework area in the user's area
    # because site.USER_SITE lies in Python 2.6 and less (it points to the posix
    # user's location, which should be picked up by adding ~/.local/bin to the
    # path).  So we compute it manually.  Also, we do a bit of a dance to cope
    # with Python 3 being the default python implementation.
    python_version=$(python -c "import sys; print '%d.%d' % sys.version_info[:2]" 2>/dev/null ||
                     python -c "import sys; print('{}.{}'.format(*sys.version_info[:2]))" 2>/dev/null)
    PATHS_TO_PREPEND=$(append_path "$PATHS_TO_PREPEND" "$HOME/Library/Python/$python_version/bin")
    PATHS_TO_APPEND=$(append_path "$PATHS_TO_APPEND" "/Library/Python/$python_version/bin:/System/Library/Frameworks/Python.framework/Versions/$python_version/bin")

    slickedit_path=$(\ls -d /Applications/SlickEdit* ~/Applications/SlickEdit* 2>/dev/null | sort -rn | head -n 1)
    if [[ $slickedit_path != '' ]]; then
        if [ -f $slickedit_path/Contents/slickedit/bin/vs ]; then
            PATHS_TO_APPEND=$(append_path "$PATHS_TO_APPEND" "$slickedit_path/Contents/slickedit/bin")
        fi
        if [ -f $slickedit_path/Contents/MacOS/vs ]; then
            PATHS_TO_APPEND=$(append_path "$PATHS_TO_APPEND" "$slickedit_path/Contents/MacOS")
        fi
    fi

    if [ -d /opt/local/bin ]; then
        PATHS_TO_APPEND=$(append_path "$PATHS_TO_APPEND" /opt/local/bin)
    fi

    if [ -d /usr/local/texlive/2009/bin/universal-darwin ]; then
        PATHS_TO_APPEND=$(append_path "$PATHS_TO_APPEND" "/usr/local/texlive/2009/bin/universal-darwin")
    fi

    if [ -d /usr/local/git/bin ]; then
        PATHS_TO_PREPEND=$(append_path "$PATHS_TO_PREPEND" /usr/local/git/bin)
    fi
fi
if [[ "$platform" == 'linux' ]]; then
    if [ -d /opt/slickedit ]; then
        PATHS_TO_PREPEND=$(append_path "$PATHS_TO_PREPEND" /opt/slickedit/bin)
    fi
    if [ -d $HOME/.local/slickedit ]; then
        PATHS_TO_PREPEND=$(append_path "$PATHS_TO_PREPEND" "$HOME/.local/slickedit/bin")
    fi
fi

if [ -d "$ETC_HOME/git-addons" ]; then
    PATHS_TO_PREPEND=$(append_path "$PATHS_TO_PREPEND" "$ETC_HOME/git-addons")
fi

if [ -d "$ETC_HOME/scripts" ]; then
    PATHS_TO_PREPEND=$(prepend_path "$PATHS_TO_PREPEND" "$ETC_HOME/scripts/all")

    # Add a platform-specific area too.
    etc_scripts_platform="$ETC_HOME/scripts/$platform"
    if [ -d "$etc_scripts_platform" ]; then
        PATHS_TO_PREPEND=$(prepend_path "$PATHS_TO_PREPEND" "$etc_scripts_platform")
    fi
    unset etc_scripts_platform
fi

# Put user script directories on the path.
test -d "$ETC_HOME/user/$ETC_USER/scripts/all" &&
    PATHS_TO_PREPEND=$(prepend_path "$PATHS_TO_PREPEND" "$ETC_HOME/user/$ETC_USER/scripts/all")

test -d "$ETC_HOME/user/$ETC_USER/scripts/$platform" &&
    PATHS_TO_PREPEND=$(prepend_path "$PATHS_TO_PREPEND" "$ETC_HOME/user/$ETC_USER/scripts/$platform")

# Put ccache links on the path, if they're available.
test -d /usr/local/opt/ccache/libexec &&
        PATHS_TO_PREPEND=$(append_path "$PATHS_TO_PREPEND" /usr/local/opt/ccache/libexec)
test -d /usr/local/lib/ccache &&
        PATHS_TO_PREPEND=$(append_path "$PATHS_TO_PREPEND" /usr/local/lib/ccache)
test -d /usr/lib/ccache &&
        PATHS_TO_PREPEND=$(append_path "$PATHS_TO_PREPEND" /usr/lib/ccache)

test -d /usr/local/bin &&
        PATHS_TO_PREPEND=$(append_path "$PATHS_TO_PREPEND" /usr/local/bin)
test -d /usr/local/sbin &&
        PATHS_TO_PREPEND=$(append_path "$PATHS_TO_PREPEND" /usr/local/sbin)
test -d /usr/sbin &&
        PATHS_TO_PREPEND=$(append_path "$PATHS_TO_PREPEND" /usr/sbin)
test -d /sbin &&
        PATHS_TO_PREPEND=$(append_path "$PATHS_TO_PREPEND" /sbin)

if [[ "$PATHS_TO_PREPEND" != '' ]]; then
    export PATH=$PATHS_TO_PREPEND:$PATH
fi

if [[ "$PATHS_TO_APPEND" != '' ]]; then
    export PATH=$PATH:$PATHS_TO_APPEND
fi

if _has_executable vs; then
    export VSLICKXNOPLUSNEWMSG=1

    if [ -f /usr/local/share/firefox/firefox ]; then
        export VSLICKHELP_WEB_BROWSER=/usr/local/share/firefox/firefox
    fi
fi

# A few times I've run into the locale not being set correctly...
# So fix that.  This also fixes an issue with ZSH and RPS1 containing
# a UTF-8 character.  When ssh'ing into a box, if the locale wasn't
# UTF-8 compatible, it would mess up the prompt.
export LANG="en_US.UTF-8"

# Quite often, I want to see the last output of less on the screen...
# Stop the default behavior of wiping the screen
# e - exit at the end of the file
# F - Quit automatically if there is only one screen worth of data
# R - Only show ANSI raw characters.  Allows color to work, while still
#     maintaining the format of the screen.
# X - Stop termcap init and deinit.  It tends to clear the screen, and I
#     don't like that.
export LESS=eFRX

export GDKUSEXFT=1

# Don't descend into Subversion's admin area, or others like it.
# Mac's bsd grep sucks... so there's no easy way to do this.
# Also, suppress error messages.
if [[ "$platform" == 'linux' ]]; then
    export GREP_OPTIONS='-s --exclude-dir=.svn --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.bzr'
else
    export GREP_OPTIONS='-s'
fi

# For use by some of my aliases
export JAVA_LOCALLIB=$HOME/.local/lib/java:$HOME/local/lib/java

# Setup a default classpath so that I don't have to type it all the time
export CLASSPATH=$JAVA_LOCALLIB:/usr/lib/java/lib

# Point X at the truetype fonts... Mac's OS X seems to really want this,
# but it doesn't hurt for Linux either, IIRC
export TTFPATH=/usr/X11/lib/X11/fonts/truetype

export EDITOR=$(_find_executable vim)

# Add a default LS_COLORS
if [ "$TERM" != "dumb" ]; then
  if [ -x /usr/bin/dircolors ]; then
      eval "$(dircolors -b)"
  else
      LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:';
      export LS_COLORS
  fi
fi

if [ "$platform" == "darwin" -o "$platform" == "linux" ]; then
    if [ -e "$ETC_HOME/python/startup.py" ]; then
        export PYTHONSTARTUP="$ETC_HOME/python/startup.py"
    fi
fi

# Ignore duplicate entries, and the exit command.
export HISTIGNORE="&:exit"

# Turn on colors for minicom.
export MINICOM='-c on'

# Setup up TMPDIR correctly when SSH'd into your machine.
if [ "$platform" = "darwin" ]; then
    # SSH sessions don't have this properly set.  As a result, you can't connect
    # to tmux instances started in a local shell.  This resolves that issue.
    test -z "$TMPDIR" &&
        export TMPDIR=$(getconf DARWIN_USER_TEMP_DIR)
fi
