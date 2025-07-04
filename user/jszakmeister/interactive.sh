# I need to cope with environments where I cannot change the shell in the
# traditional way.  This ensures SHELL gets correctly.
if _etc_has_executable zsh
then
    alias zsh='SHELL="$(_etc_find_executable zsh)" zsh'
fi

if _etc_has_executable bash
then
    alias bash='SHELL="$(_etc_find_executable bash)" bash'
fi

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

if [ "$_etc_platform" = "darwin" ]
then
    source_docker_completion /Applications/Docker.app/Contents/Resources/etc/docker docker dockerd
    source_docker_completion /Applications/Docker.app/Contents/Resources/etc/docker-compose docker-compose
    source_docker_completion /Applications/Docker.app/Contents/Resources/etc/docker-machine docker-machine

    alias df="df --si -i"
    alias ostat="stat -f '%Mp%Lp %N'"
    alias sstat="stat -f '%N: %z'"
    alias plprint="plutil -p"
    alias dump-uuid="dwarfdump -u"

    if _etc_has_executable gnu-ls
    then
        alias ls='gnu-ls -hFA --color=auto'
        alias ll='gnu-ls -hFl --color=auto'
    fi
    alias clear-arp="sudo arp -a -d"

    if test -x /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport
    then
        # See https://nuxx.net/blog/2023/10/20/command-line-802-11-monitor-mode-on-macos-sonoma-14-0/
        alias airport="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
    fi

    if test -x "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/dyldinfo"
    then
        alias dyldinfo="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/dyldinfo"
    fi

    if ! _etc_has_executable lsusb
    then
        alias lsusb="system_profiler SPUSBDataType"
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

    platform-details()
    {
        system_profiler SPSoftwareDataType SPHardwareDataType SPStorageDataType "$@"
    }

    cpuinfo()
    {
        sysctl -a machdep.cpu
    }

    local-ip()
    {
        local res

        for iface in $(ifconfig -l)
        do
            res="$(ipconfig getifaddr $iface)"
            if [ -n "$res" ]
            then
                echo "$iface: $res"
            fi
        done
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
elif [ "$_etc_platform" = "linux" ]
then
    alias ostat="stat -c '%a %n'"
    alias sstat="stat --format='%n: %s'"
    alias clear-arp="sudo ip -s -s neighbor flush all"
    alias ll='ls -l --time-style=long-iso'

    if _etc_has_executable dysk
    then
        df()
        {
            if test -t 1
            then
                dysk "$@"
            else
                command df --si --output=source,size,used,avail,pcent,iused,iavail,ipcent,target "$@"
            fi
        }
    else
        alias df='df --si --output=source,size,used,avail,pcent,iused,iavail,ipcent,target'
    fi

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

    cpuinfo()
    {
        cat /proc/cpuinfo
    }

    clear-dns-cache()
    {
        if systemctl is-enabled systemd-resolved.service --quiet > /dev/null 2>&1
        then
            sudo resolvectl flush-caches
        else
            # Assume dnsmasq is running?
            sudo killall -HUP dnsmasq
        fi
    }
fi

alias l=ll
alias lsvirtualenv="lsvirtualenv -b"
alias helptags="vim '+Helptags|q'"
alias p8="ping 8.8.8.8"
alias fndate="date '+%Y-%m-%d-%H-%M-%S'"

_add_dir_shortcut d ~/Downloads true
_add_dir_shortcut e ~/.etc true
_add_dir_shortcut e ~/projects/etc true
_add_dir_shortcut i ~/projects/intelesys true
_add_dir_shortcut j ~/projects/jszakmeister true
_add_dir_shortcut p ~/projects true
_add_dir_shortcut v ~/.vim true
_add_dir_shortcut v ~/vimfiles true
_add_dir_shortcut tmp ~/tmp true

if test -d ~/.vimuser
then
    _add_dir_shortcut vu ~/.vimuser true
elif test -d ~/_vimuser
then
    _add_dir_shortcut vu ~/_vimuser true
else
    _add_dir_shortcut vu ~/.vim/user/jszakmeister true
fi

pdt() {
    pushd .
    cdt
}

_etc_has_executable sqlite3 &&
    alias sqlite=sqlite3

_etc_has_executable git &&
    alias gitst="git st"

_etc_has_executable just &&
    alias j=just

# Make netcat a little more friendly to use.
_etc_has_executable rlwrap &&
    _etc_has_executable nc &&
    alias nc="rlwrap '$(_etc_find_executable nc)'"

_etc_has_executable cninja &&
    alias cn="cninja"

test -e /System/Library/Frameworks/JavaScriptCore.framework/Resources/jsc &&
    alias jsc="/System/Library/Frameworks/JavaScriptCore.framework/Resources/jsc"

if _etc_has_executable wget
then
    alias webcat="wget -qO-"
elif _etc_has_executable curl
then
    alias webcat="curl"
fi

_etc_has_executable petname &&
    alias petname="petname -l 10"

_etc_has_executable ssh &&
    alias stop-ssh="ssh -O stop"

# Look for strings in all parts of a file.
_etc_has_executable strings &&
    alias strings="strings -"

if _etc_has_executable gmake
then
    # alias make='nice -n 3 gmake -O -j$(_num_cpus)'
    alias make='nice -n 3 gmake --output-sync=line -j$(_num_cpus)'
elif _etc_has_executable make
then
    alias make='nice -n 3 make --output-sync=line -j$(_num_cpus)'
fi

_etc_has_executable fd &&
    alias fdg="fd --glob"


# Turn off xon/xoff flow control.  This also allows the use of CTRL-Q and CTRL-S
# in vim when running at the terminal.
test -t 0 && type -f stty >& /dev/null && stty -ixon -ixoff

if [ "$_etc_platform" = "darwin" ]; then
    # Allow CTRL-o to work on the Mac.
    test -t 0 && type -f stty >& /dev/null && stty discard '^-'
fi

if [ -n "$ZSH_VERSION" ]
then
    # I prefer having the cursor stay where it's at when searching through history.
    [ -n "${key[Up]}" ] &&
        bindkey "${key[Up]}" history-beginning-search-backward
    [ -n "${key[Down]}" ] &&
        bindkey "${key[Down]}" history-beginning-search-forward

    # A better history default for me.
    history()
    {
        if [ $# -eq 0 ]
        then
            fc -l 0
        else
            fc -l "$@"
        fi
    }
fi

export LESSOPEN="|$ETC_HOME/user/jszakmeister/lessfilter.sh %s"

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

grw()
{
    gr "$(_etc_find_executable "$1")"
}

function ssh-hosts()
{
    local _ssh_hosts=$(sed -ne 's/^[\t]*[Hh][Oo][Ss][Tt]\([Nn][Aa][Mm][Ee]\)\{0,1\}['"$'\t '"']\{1,\}\([^#*?]*\)\(#.*\)\{0,1\}$/\2/p' ~/.ssh/config | xargs -n 1 echo)
    echo "$_ssh_hosts" | xargs -n 1 echo
}

if _etc_has_executable ag; then
    ag()
    {
        local _ag_path="$(_etc_find_executable ag)"
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

if _etc_has_executable rg; then
    alias rg="rg -LS 2>/dev/null"

    rg()
    {
        local _rg_path
        local _pager_options

        _rg_path="$(_etc_find_executable rg)"

        # Let ctrl-c pass kill less.
        [ "$PAGER" = "less" ] && _pager_options="-K"

        if test -t 1
        then
            "$_rg_path" --color always "$@" | $PAGER $_pager_options
        else
            "$_rg_path" "$@"
        fi
    }

    rgg()
    {
        if test -t 1
        then
            rg --json "$@" 2>/dev/null | delta
        else
            rg "$@" 2>/dev/null
        fi
    }

    alias rgn="rgg -uuu"
fi

if _etc_has_executable curl
then
    alias curl-json="curl -H 'Accept: application/json'"
fi

if _etc_has_executable dig
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

if _etc_has_executable broot
then
    function br {
        local cmd cmd_file code
        cmd_file=$(mktemp)
        if broot --outcmd "$cmd_file" "$@"; then
            cmd=$(<"$cmd_file")
            command rm -f "$cmd_file"
            eval "$cmd"
        else
            code=$?
            command rm -f "$cmd_file"
            return "$code"
        fi
    }
fi

if _etc_has_executable eza
then
    if [ "$_etc_platform" = "darwin" ]
    then
        alias ls="eza --group-directories-first --time-style '+%Y-%m-%d %H:%M:%S' --classify=auto -oag"
        # Realias ll since it has -e in it.
        alias lle="/bin/ls -hFGAOlT@e"
    else
        alias ls="eza --group-directories-first --time-style '+%Y-%m-%d %H:%M:%S' --classify=auto -oag"
        alias lle="ls -l@"
    fi

    # Realias ll, since it may have the -T option in it.
    alias ll="ls -l"

    if ! _etc_has_executable tree
    then
        alias tree='ls --tree -I"__pycache__|build|.git|.fingerprint|target|*.sw?|.?*"'
    fi
fi

if _etc_has_executable bat
then
    # unset -f cat
    export BAT_THEME="Visual Studio Dark+"
    alias cat="bat --plain"
    alias ppc="bat --style=header,numbers,grid"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"

    if [ -n "$ZSH_VERSION" ]
    then
        # alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
        alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
    fi
else
    # My setup will get us close to the same functionality, so fall back to less.
    alias ppc="less"

    man()
    {
        env LESS_TERMCAP_mb=$'\E[01;31m' \
        LESS_TERMCAP_md=$'\E[01;38;5;74m' \
        LESS_TERMCAP_me=$'\E[0m' \
        LESS_TERMCAP_se=$'\E[0m' \
        LESS_TERMCAP_ue=$'\E[0m' \
        LESS_TERMCAP_us=$'\E[03;38;5;146m' \
        PAGER=less \
        man "$@"
    }
fi

if _etc_has_executable btop
then
    alias top=btop
elif _etc_has_executable btm
then
    alias top="btm -b -n"
    alias btop="btm -b -n"
elif _etc_has_executable ptop
then
    alias top=ptop
fi

_etc_has_executable shasum && ! _etc_has_executable sha256sum &&
    alias sha256sum="shasum -a 256"

_etc_has_executable xcp &&
    alias cp="xcp -w 0"

_etc_has_executable dust &&
    alias du="dust -rs"

_etc_has_executable dysk &&
    alias dysk="dysk -s mount"

if _etc_has_executable names
then
    names()
    {
        command names ${@:-10}
    }
fi

_etc_has_executable hwatch &&
    alias watch="hwatch -n 1 --color"

_etc_has_executable yank-cli &&
    alias yank=yank-cli

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
# if _etc_has_executable xkbset; then
#     xkbset -sl
# fi

aws-public-ip()
{
    aws --output text ec2 describe-instances --query 'Reservations[0].Instances[0].PublicIpAddress' --instance-ids "$@"
}

if _etc_has_executable openssl
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
            openssl x509 -noout -text -fingerprint -in "$cert"
        done

        return 0
    }

    dump-rsa()
    {
        if [ $# -eq 0 ]
        then
            echo 1>&2 "ERROR: Specify a certificate to examine in PEM format."
            return 1
        fi

        for cert in "$@"
        do
            openssl rsa -noout -text -in "$cert"
        done

        return 0
    }
fi

if _etc_has_executable gem
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

if _etc_has_executable docker
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

if _etc_has_executable 7zz
then
    zip-list()
    {
        7zz l "$@"
    }
elif _etc_has_executable 7z
then
    zip-list()
    {
        7z l "$@"
    }
elif _etc_has_executable 7za
then
    zip-list()
    {
        7za l "$@"
    }
elif _etc_has_executable zip
then
    zip-list()
    {
        zip -sf "$@"
    }
fi

if _etc_has_executable rsync
then
    alias local-rsync="rsync -a --info=progress2 --inplace"
fi

# Used to copy files from the last 90 days to a new location.
# rsync -vvaEi0P --files-from=<(find . -mtime -90 -print0) . ../loc2/

public-ip()
{
     dig +short txt ch whoami.cloudflare @1.0.0.1
}


quick-compile()
{
    # Maybe add -Wstrict-prototypes -Wmissing-prototypes -Werror=implicit-function-declaration \
    #   -Wbad-function-cast -Wnested-externs -std=c99
    ${CC:-cc} -Wall -Wextra -Wpointer-arith -Wcast-qual -Wwrite-strings -Wshadow -Wcast-align -Winline -Wredundant-decls "$@"
}


quick-compile-clang()
{
    CC=clang quick-compile "$@"
}


print-pcap()
{
    if [ $# -eq 0 ]
    then
        echo "[usage] print-pcap /path/to/pcap"
        return 2
    fi

    tcpdump -qns 0 -X -r "$1"
}

# if _etc_has_exectuable fzf
# then
#     if [ -n "$BASH_VERSION" ]
#     then
#         eval "$(fzf --bash)"
#     elif [ -n "$ZSH_VERSION" ]
#     then
#         source <(fzf --zsh)
#     fi
# fi

if _etc_has_executable zoxide
then
    if [ -n "$BASH_VERSION" ]
    then
        eval "$(zoxide init zsh)"
    elif [ -n "$ZSH_VERSION" ]
    then
        eval "$(zoxide init zsh)"
    fi
fi
