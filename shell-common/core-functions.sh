function _has_executable()
{
    _find_executable "$@" > /dev/null 2>&1
}

function _has_devtool()
{
    if [ "$platform" = 'darwin' ]; then
        xcode-select -p > /dev/null 2>&1
        if [[ "$?" != "0" ]]; then
            return 1
        fi
    fi

    _find_executable "$@" > /dev/null 2>&1
}

function _run_helper()
{
    # Disables command not found helpers when probing for features, such as
    # the PackageKit command not found helper installed in Fedora environments
    # by default.
    ({
        unset -f command_not_found_handler
        "$@"
    })
}

function prepend_path()
{
    if [[ "$1" == '' ]]; then
        echo $2
    else
        echo $2:$1
    fi
}

function append_path()
{
    if [[ "$1" == '' ]]; then
        echo $2
    else
        echo $1:$2
    fi
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
function _add_dir_shortcut()
{
    local shortcut="$1"
    local shortcut_path="$2"
    test -e "$shortcut_path" &&
        _make_dir_complete "cd$shortcut" cd "$shortcut_path" &&
        _make_dir_complete "pd$shortcut" pushd "$shortcut_path" &&
        [ -n "$3" ] && [ -n "$ZSH_VERSION" ] &&
        hash -d $shortcut="$shortcut_path"
}
