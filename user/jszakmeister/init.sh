export WORKON_HOME=$HOME/.virtualenvs
export CCACHE_CPP2=1
export HOMEBREW_NO_EMOJI=1
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


source_docker_completion()
{
    if [ -n "$BASH_VERSION" ]; then
        local compfile="$1.bash-completion"
        if test -f $compfile; then
            . "$compfile"
        fi
    elif [ -n "$ZSH_VERSION" ]; then
        local compfile="$1.zsh-completion"
        shift
        if test -f $compfile; then
            . "$compfile"
            for def in "$@"
            do
                compdef "_$def" "$def"
            done
        fi
    fi
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

if [ "$platform" = "darwin" ]; then
    source_docker_completion /Applications/Docker.app/Contents/Resources/etc/docker docker dockerd
    source_docker_completion /Applications/Docker.app/Contents/Resources/etc/docker-compose docker-compose
    source_docker_completion /Applications/Docker.app/Contents/Resources/etc/docker-machine docker-machine

    alias df="df -hi"
    alias ostat="stat -f '%Mp%Lp %N'"
    alias sstat="stat -f '%N: %z'"
    alias plprint="plutil -p"

    if _has_executable gnu-ls; then
        alias ls='gnu-ls -hFA --color=auto'
        alias ll='gnu-ls -hFl --color=auto'
    fi
    alias clear-arp="sudo arp -a -d"

    if test -d "/Applications/VMware Fusion.app"
    then
        export VAGRANT_DEFAULT_PROVIDER=vmware_fusion
    fi

    clear-dns-cache()
    {
        sudo killall -HUP mDNSResponder
        sudo killall mDNSResponderHelper
        sudo dscacheutil -flushcache
    }

    enable-screen-sharing()
    {
        sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
    }

    disable-screen-sharing()
    {
        sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
    }

    vm-get-ip-addr()
    {
        if [ -z "$1" ]
        then
            echo "Missing path to VMX." 1>&2
            return 1
        fi

        vmrun -T fusion getGuestIPAddress "$1" -wait
    }

    lldb()
    {
        PATH=/usr/bin /usr/bin/lldb "$@"
    }

    # pkg-remove()
    # {
    #   pushd /
    #
    #   pkgutil --only-files --files "$1" | tr '\n' '\0' | xargs -n 1 -0 sudo rm -if &&
    #     pkgutil --only-dirs --files "$1" | tail -r | tr '\n' '\0' | xargs -n 1 -0 sudo rmdir &&
    #     sudo pkgutil --forget "$1"
    #
    #   popd
    # }

elif [ "$platform" = "linux" ]; then
    alias ostat="stat -c '%a %n'"
    alias sstat="stat --format='%n: %s'"
    alias clear-arp="sudo ip -s -s neighbor flush all"
    alias ll='ls -l --time-style=long-iso'
    alias df='df -h --output=source,size,used,avail,pcent,iused,iavail,ipcent,target'

    unrpm()
    {
        rpm2cpio "$@" | cpio --extract --make-directories --verbose
    }

    disassemble_func()
    {
        i=$(nm -S --size-sort "$2" | grep "\<$1\>"  |
            awk '{print toupper($1),toupper($2)}')
        echo "$i" | while read line; do
            start=${line%% *}; size=${line##* }
            end=$(echo "obase=16; ibase=16; $start + $size" | bc -l)
            objdump -S -M intel -d --start-address="0x$start" \
                --stop-address="0x$end" "$2"
        done
    }
fi

if test -d ~/projects/jszakmeister/local-bin
then
    if ! _etc_path_insert_after ~/projects/jszakmeister/local-bin ~/.local/bin
    then
        PATH="$HOME/projects/jszakmeister/local-bin:$PATH"
    fi
fi

alias l=ll
alias lsvirtualenv="lsvirtualenv -b"
alias helptags="vim '+Helptags|q'"
alias p8="ping 8.8.8.8"
alias fndate="date '+%Y-%m-%d-%H-%M-%S'"

_add_dir_shortcut e ~/.etc true
_add_dir_shortcut e ~/projects/etc true
_add_dir_shortcut i ~/projects/intelesys true
_add_dir_shortcut j ~/projects/jszakmeister true
_add_dir_shortcut p ~/projects true
_add_dir_shortcut v ~/.vim true
_add_dir_shortcut v ~/vimfiles true

if test -d ~/.vimuser; then
    _add_dir_shortcut vu ~/.vimuser true
elif test -d ~/_vimuser; then
    _add_dir_shortcut vu ~/_vimuser true
else
    _add_dir_shortcut vu ~/.vim/user/jszakmeister true
fi

test -e ~/tmp && _make_dir_complete pdt pushd ~/tmp

_has_executable git &&
    alias gitst="git st"

# Make netcat a little more friendly to use.
_has_executable rlwrap &&
    _has_executable nc &&
    alias nc="rlwrap '$(_find_executable nc)'"

_has_executable cninja &&
    alias cn="cninja"

_has_executable ninja-build &&
    export CMAKE_MAKE_PROGRAM="ninja-build" &&
    export CMAKE_GENERATOR="Ninja"

_has_executable ninja &&
    export CMAKE_GENERATOR="Ninja"

test -e /System/Library/Frameworks/JavaScriptCore.framework/Resources/jsc &&
    alias jsc="/System/Library/Frameworks/JavaScriptCore.framework/Resources/jsc"

if _has_executable wget
then
    alias webcat="wget -qO-"
elif _has_executable curl
then
    alias webcat="curl"
fi

_has_executable petname &&
    alias petname="petname -l 10"

_has_executable ssh &&
    alias stop-ssh="ssh -O stop"

# Look for strings in all parts of a file.
_has_executable strings &&
    alias strings="strings -"

if _has_executable gmake
then
    # alias make='nice -n 3 gmake -O -j$(_num_cpus)'
    alias make='nice -n 3 gmake -j$(_num_cpus)'
fi

if _has_executable fcp
then
    alias cp=fcp
fi

# Turn off xon/xoff flow control.  This also allows the use of CTRL-Q and CTRL-S
# in vim when running at the terminal.
test -t 0 && type -f stty >& /dev/null && stty -ixon -ixoff

if [ "$platform" = "darwin" ]; then
    # Allow CTRL-o to work on the Mac.
    test -t 0 && type -f stty >& /dev/null && stty discard '^-'
fi

# Use Vim as a front-end to man.
# man()
# {
#     $(_find_executable man) -P cat "$@" > /dev/null && vim -c "RMan $*"
# }

man()
{
    env LESS_TERMCAP_mb=$'\E[01;31m' \
    LESS_TERMCAP_md=$'\E[01;38;5;74m' \
    LESS_TERMCAP_me=$'\E[0m' \
    LESS_TERMCAP_se=$'\E[0m' \
    LESS_TERMCAP_so=$'\E[38;7;246m' \
    LESS_TERMCAP_ue=$'\E[0m' \
    LESS_TERMCAP_us=$'\E[04;38;5;146m' \
    man "$@"
}

# I prefer having the cursor stay where it's at when searching through history.
if [ -n "$ZSH_VERSION" ]; then
    [ -n "${key[Up]}" ] &&
        bindkey "${key[Up]}" history-beginning-search-backward
    [ -n "${key[Down]}" ] &&
        bindkey "${key[Down]}" history-beginning-search-forward
fi

if _has_executable pygmentize; then
    export LESSOPEN="|$ETC_HOME/user/jszakmeister/lessfilter.sh %s"
fi

if [ -f "/Applications/VMware Fusion.app/Contents/Library/vmrun" ]; then
    alias vmrun="/Applications/VMware\ Fusion.app/Contents/Library/vmrun"
    [ -f ~/Documents/Virtual\ Machines.localized/dev-ubuntu.vmwarevm/dev-ubuntu.vmx ] && {
        alias start-dev-ubuntu="vmrun -T fusion start ~/Documents/Virtual\ Machines.localized/dev-ubuntu.vmwarevm/dev-ubuntu.vmx nogui"
        alias stop-dev-ubuntu="vmrun -T fusion stop ~/Documents/Virtual\ Machines.localized/dev-ubuntu.vmwarevm/dev-ubuntu.vmx"
    }
fi

sudo-xauth()
{
    [ -z "$SUDO_USER" ] && return

    local display=$(printenv DISPLAY | egrep -o ':[[:digit:]]+')

    xauth -f $(eval echo "~${SUDO_USER}/.Xauthority") list |
        grep "$display" |
        xargs -n 3 xauth add
}

td()
{
    mkdir -p "$(dirname "$1")"
    touch "$1"
}

function ssh-hosts()
{
    local _ssh_hosts=$(sed -ne 's/^[\t]*[Hh][Oo][Ss][Tt]\([Nn][Aa][Mm][Ee]\)\{0,1\}['"$'\t '"']\{1,\}\([^#*?]*\)\(#.*\)\{0,1\}$/\2/p' ~/.ssh/config | xargs -n 1 echo)
    echo "$_ssh_hosts" | xargs -n 1 echo
}

if _has_executable ag; then
    ag()
    {
        local _ag_path="$(_find_executable ag)"
        local _pager_options

        # Let ctrl-c pass kill less.
        [ "$PAGER" = "less" ] && _pager_options="-K"

        if test -t 1
        then
            "$_ag_path" --group --color "$@" | $PAGER $_pager_options
        else
            "$_ag_path" "$@"
        fi
    }
fi

if _has_executable rg; then
    rg()
    {
        local _rg_path
        local _pager_options

        _rg_path="$(_find_executable rg)"

        # Let ctrl-c pass kill less.
        [ "$PAGER" = "less" ] && _pager_options="-K"

        if test -t 1
        then
            "$_rg_path" --color always "$@" | $PAGER $_pager_options
        else
            "$_rg_path" "$@"
        fi
    }
fi

if _has_executable curl
then
    alias curl-json="curl -H 'Accept: application/json'"
fi

if _has_executable dig
then
    alias dig="dig +noall +answer"

    get-soa()
    {
        dig +short NS "$*"
    }

    mdns()
    {
        dig +noall +answer -p 5353 @224.0.0.251 "$@"
    }
fi

delete-unused()
{
    for filename in "$@"
    do
        if ! lsof -wt "$filename" >/dev/null 2>&1
        then
            rm -r "$filename"
        fi
    done
}

clean-dirs()
{
    local dir="${1:-.}"

    find "$dir" -type d -empty -delete
}

clean-python()
{
    local dir="${1:-.}"

    # OS X doesn't have --no-run-if-empty for xargs, so we work around that
    # limitation by looping through the results.
    find "$dir" -depth \( -name '*.pyc' -or -name __pycache__ \) -print0 |
    while IFS= read -r -d '' file
    do
        rm -r "$file"
    done

    clean-dirs "$dir"
}

clean-vim()
{
    find . \( -name '.*.sw?' -or -name '.sw?' \) -print0 |
    while IFS= read -r -d '' file
    do
        delete-unused "$file"
    done
}

clean-cruft()
{
    clean-python
    clean-vim
}

hash-dir()
{
    find "${1:-.}" -type f -print0 | sort -z | xargs -0 sha1sum | sha1sum
}

# Disable slow keys...
# Not sure if this persists or not.
#
# if _has_executable xkbset; then
#     xkbset -sl
# fi

aws-public-ip()
{
    aws --output text ec2 describe-instances --query 'Reservations[0].Instances[0].PublicIpAddress' --instance-ids "$@"
}

if _has_executable openssl
then
    dump-cert()
    {
        if [ $# -eq 0 ]
        then
            echo 1>&2 "ERROR: Specify a certificate to examine in PEM format."
            return 1
        fi

        for cert in "$@"
        do
            openssl x509 -noout -text -in "$cert"
        done

        return 0
    }
fi

if _has_executable gem
then
    GEM_HOME="$HOME/.gem"

    # Make sure the user-install/bin folder is on the path.
    gem env gempath 2>/dev/null | while IFS=: read -r dir rest
    do
        case $GEM_HOME in ${dir}*)
            test -d "$dir/bin" && export "PATH=$dir/bin:$PATH"
        esac
    done
    unset rest
    unset dir
fi

if _has_executable docker
then
    docker-ip()
    {
        docker container inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$@"
    }
fi

if [ -n "$VIRTUALENVWRAPPER_PYTHON" ]
then
    rebuild-sphinx-env()
    {
        (command -v deactivate && deactivate || : ) &&
        rmvirtualenv sphinx &&
        mkvirtualenv --python=$(which python3) sphinx &&
        pip install -U Sphinx recommonmark hieroglyph sphinx_rtd_theme \
           sphinxcontrib-websupport guzzle_sphinx_theme
    }
fi

# Used to copy files from the last 90 days to a new location.
# rsync -vvaEi0P --files-from=<(find . -mtime -90 -print0) . ../loc2/
