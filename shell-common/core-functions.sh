_etc_has_executable()
{
    _etc_find_executable "$@" > /dev/null 2>&1
}

_has_devtool()
{
    if [ "$_etc_platform" = 'darwin' ]; then
        if ! xcode-select -p > /dev/null 2>&1 ; then
            return 1
        fi
    fi

    _etc_find_executable "$@" > /dev/null 2>&1
}

_run_helper()
{
    # Disables command not found helpers when probing for features, such as
    # the PackageKit command not found helper installed in Fedora environments
    # by default.
    ({
        unset -f command_not_found_handler
        "$@"
    })
}

prepend_path()
{
    if [ "$1" = '' ]; then
        echo "$2"
    else
        echo "$2:$1"
    fi
}

append_path()
{
    if [ "$1" = '' ]; then
        echo "$2"
    else
        echo "$1:$2"
    fi
}

_etc_prepend_script_dir()
{
    export PATH="$(prepend_path "$PATH" "$1/$_etc_platform:$1/all")"
}

__etc_source_user_file()
{
    test -s "$ETC_LOCAL_DIR/$1" &&
        . "$ETC_LOCAL_DIR/$1"
    test -s "$ETC_USER_DIR/$1" &&
        . "$ETC_USER_DIR/$1"
    test -s "$ETC_HOME/user/$ETC_USER/$1" &&
        . "$ETC_HOME/user/$ETC_USER/$1"
}

# Builds on _make_dir_complete to help make nifty shortcuts.  For instance:
#   _add_dir_shortcut p ~/projects true
#
# Will create two commands for use at the prompt: cdp and pdp.  The first is
# just a cd command to change into ~/projects, but it also offers completion.
# The second is the same thing, except it uses pushd to change the directory.
# The last argument, if present an non-empty, says to create a zsh directory
# alias, if you're running zsh.  In this example, you could then use ~p as a
# shortcut to ~/projects.
_add_dir_shortcut()
{
    local shortcut="$1"
    local shortcut_path="$2"
    test -e "$shortcut_path" &&
        _make_dir_complete "cd$shortcut" cd "$shortcut_path" &&
        _make_dir_complete "pd$shortcut" pushd "$shortcut_path" &&
        [ -n "$3" ] && [ -n "$ZSH_VERSION" ] &&
        hash -d "$shortcut=$shortcut_path"
}


# Compatibility shims.  Remove at some point.
_has_executable()
{
    _etc_has_executable "$@"
}

__find_executable()
{
    _etc_find_executable "$@"
}
