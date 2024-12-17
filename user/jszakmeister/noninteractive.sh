export WORKON_HOME=$HOME/.virtualenvs
export CCACHE_CPP2=1
export HOMEBREW_NO_EMOJI=1
export USE_EMOJI=no
export LESS="-eFRX -Pslines %lt-%lb?Pb(%Pb\%).?m (%i of %m).  ?f%f:-."


_etc_iterate_path()
{
    # If an argument is provided, only provide paths that have that filename
    # in them.

    local filename
    if [ $# -eq 0 ]
    then
        filename=
    else
        filename="$1"
    fi

    (
        IFS=:
        set -f
        for dir in $PATH
        do
            dir=${dir:-.}
            [ -x "${dir%/}/$filename" ] && printf "%s\n" "$dir"
        done
    )
}


_etc_is_path_present()
{
    local path_to_find
    path_to_find="$1"

    # shellcheck disable=SC2119
    while read -r dir
    do
        if [ "$path_to_find" = "$dir" ]
        then
            return 0
        fi
    done < <(_etc_iterate_path)

    return 1
}


_etc_path_insert_before_after()
{
    local path_to_add="$1"
    local dir_to_match="$2"
    local before_after="$3"
    local new_path=""

    if [ -z "$path_to_add" ] ||  [ -z "$dir_to_match" ]
    then
        return 1
    fi

    if _etc_is_path_present "$path_to_add"
    then
        return 0
    fi

    if ! _etc_is_path_present "$dir_to_match"
    then
        return 1
    fi

    # Insert the new path.
    # shellcheck disable=SC2119
    while read -r dir
    do
        if [ -z "$before_after" ] && [ "$dir_to_match" = "$dir" ]
        then
            new_path="$(append_path "$new_path" "$path_to_add")"
        fi

        new_path="$(append_path "$new_path" "$dir")"

        if [ -n "$before_after" ] && [ "$dir_to_match" = "$dir" ]
        then
            new_path="$(append_path "$new_path" "$path_to_add")"
        fi
    done < <(_etc_iterate_path)

    PATH="$new_path"
}


_etc_path_insert_before()
{
    _etc_path_insert_before_after "$1" "$2" ""
}


_etc_path_insert_after()
{
    _etc_path_insert_before_after "$1" "$2" t
}


_etc_path_remove()
{
    local path_to_remove="$1"
    local new_path=

    if [ -z "$path_to_remove" ]
    then
        return 1
    fi

    # shellcheck disable=SC2119
    while read -r dir
    do
        if [ "$path_to_remove" != "$dir" ]
        then
            new_path=$(append_path "$new_path" "$dir")
        fi
    done < <(_etc_iterate_path)

    PATH="$new_path"
}


# Drop the PackageKit command not found handlers.  And yes, you need to unset
# both. :-/  Alternatively, remove the PackageKit-command-not-found package.
if typeset -f command_not_found_handler >/dev/null
then
    unset -f command_not_found_handler
fi

if typeset -f command_not_found_handle >/dev/null
then
    unset -f command_not_found_handle
fi


if [ -n "$ZSH_VERSION" ]
then
    export TIMEFMT="%J  %U user %S system %P cpu %*E total/elapsed"
fi


if [ "$_etc_platform" = "darwin" ]
then
    # Bump up the number of files I can have open, since I often do crazy things
    # that pushes that limit.
    ulimit -n "$(sysctl -n kern.maxfilesperproc)"

    if test -d "/Applications/VMware Fusion.app"
    then
        export VAGRANT_DEFAULT_PROVIDER=vmware_fusion
    fi

elif [ "$_etc_platform" = "linux" ]
then
    :
fi


if test -d ~/projects/jszakmeister/local-bin
then
    if ! _etc_path_insert_after ~/projects/jszakmeister/local-bin ~/.local/bin
    then
        export PATH="$HOME/projects/jszakmeister/local-bin:$PATH"
    fi
fi


if test -d /opt/homebrew/opt/bison/bin
then
    export PATH="/opt/homebrew/opt/bison/bin:$PATH"
fi


_etc_has_executable ninja-build &&
    export CMAKE_MAKE_PROGRAM="ninja-build" &&
    export CMAKE_GENERATOR="Ninja"

_etc_has_executable ninja &&
    export CMAKE_GENERATOR="Ninja"

export LESSOPEN="|$ETC_HOME/user/jszakmeister/lessfilter.sh %s"
