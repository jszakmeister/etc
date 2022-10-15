# Use the 'function funcname()' form to avoid collisions with aliases in
# Bash.  Zsh seems smart enough to deal with it, but Bash errors.

find-project-root()
{
    local last_found="$(pwd)"
    local tmp_path="$(dirname "$last_found")"
    while [[ "$tmp_path" != "/" ]];
    do
        if [ -e "$tmp_path/.git" -o -d "$tmp_path/.hg" -o -d "$tmp_path/.bzr" -o -f "$tmp_path/.cdt-stop" ]; then
            last_found="$tmp_path"
            break
        elif [ -d "$tmp_path/.svn" ]; then
            last_found="$tmp_path"
        fi
        tmp_path="$(dirname "$tmp_path")"
    done
    echo "$last_found"
}

search-up-tree()
{
    local tmp_path="$(pwd)"
    while [[ "$tmp_path" != "/" ]];
    do
        for file in "$@"
        do
            if [ -e "$tmp_path/$file" ]; then
                echo "$tmp_path/$file"
                return
            fi
        done

        tmp_path="$(dirname "$tmp_path")"
    done
}

cdt()
{
    local project_root="$(find-project-root)"
    if [ -n "$1" ]; then
        cd "$project_root/$1"
    else
        cd "$project_root"
    fi
}

md()
{
    mkdir -p "$1"
    cd "$1"
}

if _has_executable gdb
then
    function gdb()
    {
        local gdb_path=$(_find_executable gdb)
        if "$gdb_path" 2>&1 --version | head -n 1 | grep "Apple version" > /dev/null; then
            "$gdb_path" -x "$ETC_HOME/gdb/darwin.gdb" "$@"
        else
            "$gdb_path" -x "$ETC_HOME/gdb/default.gdb" "$@"
        fi
    }
fi

# Function needed here for Bash, as we also alias grep.  See comment at top of
# file.
function grep()
{
    local _grep_path="$(_find_executable grep)"
    local _pager_options
    local _grep_options

    # Let ctrl-c pass kill less.
    [ "$PAGER" = "less" ] && _pager_options="-K"

    test -n "$_grep_color" && _grep_options="--color=always"

    if test -t 1
    then
        "$_grep_path" "$@" $_grep_options | $PAGER $_pager_options
    else
        "$_grep_path" "$@"
    fi
}

# Function needed here for Bash, as we also alias egrep.  See comment at top of
# file.
function egrep()
{
    local _egrep_path="$(_find_executable egrep)"
    local _pager_options
    local _egrep_options

    # Let ctrl-c pass kill less.
    [ "$PAGER" = "less" ] && _pager_options="-K"

    test -n "$_grep_color" && _egrep_options="--color=always"

    if test -t 1
    then
        "$_egrep_path" "$@" $_egrep_options | $PAGER $_pager_options
    else
        "$_egrep_path" "$@"
    fi
}

buildall()
{
    local buildall_exec="$(search-up-tree buildall buildall.sh)"

    if [ -z "$buildall_exec" ]
    then
        echo 1>&2 "ERROR: buildall or buildall.sh not found"
        return 1
    fi

    pushd "$(dirname "$buildall_exec")" 2>&1 > /dev/null
    "$buildall_exec" "$@"
    local result=$?
    popd 2>&1 > /dev/null

    return $result
}

ssh-add()
{
    function kill-ssh-agent()
    {
        command ssh-add -D > /dev/null 2>&1
        ( eval $(ssh-agent -k) ) > /dev/null 2>&1
    }

    # Let's try to use SSH_AUTH_SOCK instead of PID to make this work correctly
    # under Mac OS X.
    if test -z "$SSH_AUTH_SOCK" || test ! -S "$SSH_AUTH_SOCK"
    then
        if [ "$ZSH_VERSION" ]
        then
            autoload -Uz add-zsh-hook
            add-zsh-hook zshexit kill-ssh-agent
        else
            trap kill-ssh-agent EXIT
        fi

        eval $(ssh-agent -s)
    fi

    command ssh-add "$@"
}

find-domain-controllers()
{
    local DNS_SERVER
    local OPTIONS

    if [ -z "$1" ]
    then
        echo "ERROR: must provide the AD domain name" 1>&2
        return 1
    fi

    # Use the domain name as the argument, and the DNS server as a secondary
    # argument.
    if [ -n "$2" ]; then
        DNS_SERVER="@${2}"
    else
        DNS_SERVER=
    fi


    if [ "$platform" = 'linux' ]
    then
        OPTIONS="+nocookie"
    fi

    dig $DNS_SERVER $OPTIONS -t SRV _ldap._tcp.$1
}

if _has_executable nohup; then
    # Runs a command and detaches it from the terminal.  It also silences stdout
    # and stderr, getting rid of debugging from many GTK related projects.
    function run_detached()
    {
        nohup "$@" </dev/null >/dev/null 2>&1 &
    }
fi

# Some git-related setup for completion.

if _has_devtool git; then
    if _has_executable git-ffwd; then
        function _git_ffwd()
        {
            __gitcomp_nl "$(__git_remotes)"
        }
    fi

    if _has_executable git-ff || \
            git config --get alias.ff > /dev/null 2>&1; then
        function _git_ff()
        {
            __gitcomp_nl "$(__git_refs)"
        }
    fi

    if _has_executable git-missing; then
        function _git_missing()
        {
            __gitcomp_nl "$(__git_refs)"
        }
    fi

    if _has_executable git-branch-diff; then
        function _git_branch_diff()
        {
            case "$cur" in
                --*)
                    __gitcomp "--stat"
                    return
            esac

            __gitcomp_nl "$(__git_refs)"
        }
    fi
fi

# Cope with Python and virtual environments.

if _has_executable pip3
then
    function pip()
    {
        if [ -z "$VIRTUAL_ENV" ]
        then
            if _has_executable pip3
            then
                command pip3 "$@"
                return
            fi
        fi

        command pip "$@"
    }
fi

if _has_executable python3
then
    function python()
    {
        if [ -z "$VIRTUAL_ENV" ]
        then
            if _has_executable python3
            then
                command python3 "$@"
                return
            fi
        fi

        command python "$@"
    }
fi

if _has_executable hexdump
then
    function hexdump()
    {
        if test -t 1
        then
            command hexdump -v -e '"%10_ad (%8_axh):  " 8/1 "%02x " "  " 8/1 "%02x "' -e'"  " 16/1 "%_p" "\n"' "$@" | ${PAGER}
        else
            command hexdump -v -e '"%10_ad (%8_axh):  " 8/1 "%02x " "  " 8/1 "%02x "' -e'"  " 16/1 "%_p" "\n"' "$@"
        fi
    }
fi
