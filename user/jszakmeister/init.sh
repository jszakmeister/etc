export WORKON_HOME=$HOME/.virtualenvs
export CCACHE_CPP2=1
export HOMEBREW_NO_EMOJI=1

if [ "$platform" = "darwin" ]; then
    alias ostat="stat -f '%Mp%Lp %N'"
    if _has_executable gnu-ls; then
        alias ls='gnu-ls -hFA --color=auto'
        alias ll='gnu-ls -hFl --color=auto'
    fi
    alias clear-arp="sudo arp -a -d"
    alias ps="ps aux -ww"

elif [ "$platform" = "linux" ]; then
    alias ostat="stat -c '%a %n'"
    alias clear-arp="sudo ip -s -s neighbor flush all"

    function disassemble_func() {
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

_add_dir_shortcut e ~/.etc true
_add_dir_shortcut e ~/projects/etc true
_add_dir_shortcut i ~/projects/intelesys true
_add_dir_shortcut j ~/projects/jszakmeister true
_add_dir_shortcut p ~/projects true
_add_dir_shortcut v ~/.vim true

if test -d ~/.vimuser; then
    _add_dir_shortcut vu ~/.vimuser true
else
    _add_dir_shortcut vu ~/.vim/user/jszakmeister true
fi

_add_dir_shortcut s ~/sources true

_make_dir_complete pdt pushd ~/tmp

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
# function man() {
#     $(_find_executable man) -P cat "$@" > /dev/null && vim -c "RMan $*"
# }

function man() {
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
[[ -n "${key[Up]}" ]] &&
    bindkey "${key[Up]}" history-beginning-search-backward
[[ -n "${key[Down]}" ]] &&
    bindkey "${key[Down]}" history-beginning-search-forward

if _has_executable pygmentize; then
    export LESSOPEN="|$ETC_HOME/user/jszakmeister/lessfilter.sh %s"
fi

if _has_executable hexdump; then
    alias hexdump="hexdump -v -e '\"%10_ad:  \" 8/1 \"%02x \" \"  \" 8/1 \"%02x \"' -e'\"  \" 16/1 \"%_p\" \"\n\"'"
fi

_has_executable cninja && alias cn='nice -n 3 cninja'

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

function find-domain-controllers() {
    local DNS_SERVER

    # Use the domain name as the argument, and the DNS server as a secondary
    # argument.
    if [ -n "$2" ]; then
        DNS_SERVER="@${2}"
    else
        DNS_SERVER=
    fi

    dig $DNS_SERVER -t SRV _ldap._tcp.$1
}

function ssh-add()
{
    function kill-ssh-agent()
    {
        command ssh-add -D > /dev/null 2>&1
        ( eval $(ssh-agent -k) ) > /dev/null 2>&1
    }

    if test -z "$SSH_AGENT_PID" ||
        (ps | grep ${SSH_AGENT_PID} | grep -v grep | grep -qv ssh-agent)
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

function buildall()
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

# Disable slow keys...
# Not sure if this persists or not.
#
# if _has_executable xkbset; then
#     xkbset -sl
# fi
