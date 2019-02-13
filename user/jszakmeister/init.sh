export WORKON_HOME=$HOME/.virtualenvs
export CCACHE_CPP2=1
export HOMEBREW_NO_EMOJI=1


_etc_iterate_path()
{
    (
        IFS=:
        set -f
        for dir in $PATH
        do
            dir=${dir:-.}
            [ -x "${dir%/}/$1" ] && printf "%s\n" "$dir"
        done
    )
}


_etc_is_path_present()
{
    local path_to_find="$1"
    local found=
    _etc_iterate_path | while read dir
    do
        if [ "$path_to_find" = "$dir" ]
        then
            return 0
        fi
    done

    return 1
}


_etc_path_insert_before_after()
{
    local path_to_add="$1"
    local dir_to_match="$2"
    local before_after="$3"
    local new_path=""

    if [ -z "$path_to_add" -o -z "$dir_to_match" ]
    then
        echo "crap"
        return 1
    fi

    if _etc_is_path_present "$path_to_add"
    then
        echo "already there"
        return 0
    fi

    if ! _etc_is_path_present "$dir_to_match"
    then
        echo "uhhh"
        return 1
    fi

    # Insert the new path.
    _etc_iterate_path | while read dir
    do
        if [ -z "$before_after" -a "$dir_to_match" = "$dir" ]
        then
            new_path=$(append_path "$new_path" "$path_to_add")
        fi

        new_path=$(append_path "$new_path" "$dir")

        if [ -n "$before_after" -a "$dir_to_match" = "$dir" ]
        then
            new_path=$(append_path "$new_path" "$path_to_add")
        fi
    done

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

    _etc_iterate_path | while read dir
    do
        if [ "$path_to_remove" != "$dir" ]
        then
            new_path=$(append_path "$new_path" "$dir")
        fi
    done

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


if [ "$platform" = "darwin" ]; then
    source_docker_completion /Applications/Docker.app/Contents/Resources/etc/docker docker dockerd
    source_docker_completion /Applications/Docker.app/Contents/Resources/etc/docker-compose docker-compose
    source_docker_completion /Applications/Docker.app/Contents/Resources/etc/docker-machine docker-machine

    alias df="df -hi"
    alias ostat="stat -f '%Mp%Lp %N'"
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
elif [ "$platform" = "linux" ]; then
    alias ostat="stat -c '%a %n'"
    alias clear-arp="sudo ip -s -s neighbor flush all"
    alias ll='ls -l --time-style=long-iso'
    alias df='df -h --output=source,size,used,avail,pcent,iused,iavail,ipcent,target'

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

alias lsvirtualenv="lsvirtualenv -b"
alias helptags="vim '+Helptags|q'"
alias p8="ping 8.8.8.8"

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

_add_dir_shortcut s ~/sources true
_add_dir_shortcut gc ~/projects/gradle-clojure
_add_dir_shortcut w ~/Documents/Work true

test -e ~/tmp && _make_dir_complete pdt pushd ~/tmp

# Make netcat a little more friendly to use.
_has_executable rlwrap &&
    _has_executable nc &&
    alias nc="rlwrap '$(_find_executable nc)'"

test -e /System/Library/Frameworks/JavaScriptCore.framework/Resources/jsc &&
    alias jsc="/System/Library/Frameworks/JavaScriptCore.framework/Resources/jsc"

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
    [ -f /Volumes/parents/John/VMs/freebsd-10.vmwarevm/freebsd-10.vmx ] && {
        alias start-freebsd-10="vmrun -T fusion start /Volumes/parents/John/VMs/freebsd-10.vmwarevm/freebsd-10.vmx nogui"
        alias stop-freebsd-10="vmrun -T fusion stop /Volumes/parents/John/VMs/freebsd-10.vmwarevm/freebsd-10.vmx"
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

if _has_executable curl
then
    alias curl-json="curl -H 'Accept: application/json'"
fi

if _has_executable dig
then
    get-soa()
    {
        dig +short NS "$*"
    }
fi

delete-unused()
{
    for filename in "$@"
    do
        if ! lsof -wt "$filename" 2>&1 >/dev/null
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
    find -d "$dir" \( -name '*.pyc' -or -name __pycache__ \) -print0 |
    while IFS= read -r -d '' file; do
        rm -r "$file"
    done

    clean-dirs "$dir"
}

clean-vim()
{
    find . \( -name '.*.sw?' -or -name '.sw?' \) -print0 |
    while IFS= read -r -d '' file; do
        delete-unused "$file"
    done
}

clean-cruft()
{
    clean-python
    clean-vim
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
        if [ -z "$@" ]
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
    gem env gempath | while IFS=: read -r dir rest
    do
        test -d "$dir/bin" && export "PATH=$dir/bin:$PATH"
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
