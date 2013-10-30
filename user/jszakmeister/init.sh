export WORKON_HOME=$HOME/.virtualenvs
export PAGER=less

if [ "$platform" = "darwin" ]; then
    alias ostat="stat -f '%Mp%Lp %N'"
elif [ "$platform" = "linux" ]; then
    alias ostat="stat -c '%a %n'"
fi

_add_dir_shortcut() {
    local shortcut="$1"
    local shortcut_path="$2"
    test -e "$shortcut_path" &&
        _make_dir_complete "cd$shortcut" cd "$shortcut_path" &&
        _make_dir_complete "pd$shortcut" pushd "$shortcut_path" &&
        [ -n "$3" ] && [ -n "$ZSH_VERSION" ] &&
        hash -d $shortcut="$shortcut_path"
}

_add_dir_shortcut e ~/.etc true
_add_dir_shortcut e ~/projects/etc true
_add_dir_shortcut i ~/projects/intelesys true
_add_dir_shortcut j ~/projects/jszakmeister true
_add_dir_shortcut l ~/projects/local-homepage
_add_dir_shortcut l ~/projects/jszakmeister/local-homepage
_add_dir_shortcut p ~/projects true
_add_dir_shortcut v ~/.vim true

# In ZSH, we need to remove any completions associated with cdc, or this will
# fail.
if [ -n "$ZSH_VERSION" ]; then
    compdef -d cdc
fi
_add_dir_shortcut c ~/projects/clojure

alias tree='tree --charset=ASCII -F -v'

# Turn off xon/xoff flow control.  This also allows the use of CTRL-Q and CTRL-S
# in vim when running at the terminal.
test -t 0 && type -f stty >& /dev/null && stty -ixon -ixoff

if [ "$platform" = "darwin" ]; then
    # Allow CTRL-o to work on the Mac.
    test -t 0 && type -f stty >& /dev/null && stty discard '^-'
fi

# Use Vim as a front-end to man.
function man() {
    $(_find_executable man) -P cat "$@" > /dev/null && vim -c "RMan $*"
}

# Disable slow keys...
# Not sure if this persists or not.
#
# if _has_executable xkbset; then
#     xkbset -sl
# fi
