# May be overridden later
alias em='emacs -nw'
alias ec='emacsclient -n'
alias pd='pushd'

_has_executable scons && alias scons='scons -u -j$(_num_cpus)'
_has_executable make && alias make='nice -n 3 make -j$(_num_cpus)'
_has_executable gmake && alias gmake='nice -n 3 gmake -j$(_num_cpus)'
_has_executable ninja && alias ninja='nice -n 3 ninja'
_has_executable cninja && {
    alias cninja='nice -n 3 cninja'
    alias cn=cninja
}
_has_executable tree && alias tree='tree --charset=ASCII -F -v'
_has_executable hexdump &&
    alias hexdump="hexdump -v -e '\"%10_ad:  \" 8/1 \"%02x \" \"  \" 8/1 \"%02x \"' -e'\"  \" 16/1 \"%_p\" \"\n\"'"
_has_executable vs && alias vs='vs -new'

# Always use shasum in binary mode.
_has_executable shasum && alias shasum="shasum -b"

if [ "$platform" = 'freebsd' ]; then
    alias du='du -h -d1'
    alias ps='ps auxww'
    alias ls='ls -hFGA'
    alias ll='ls -l'
    alias top='top -o cpu -i 1'
fi

if [ "$platform" = 'darwin' ]; then
    alias twistd="/System/Library/Frameworks/Python.framework/Versions/Current/Extras/bin/twistd"

    alias du='du -h -d1'
    alias ps='ps auxww'
    slickedit_path=$(\ls -d /Applications/SlickEdit* ~/Applications/SlickEdit* 2>/dev/null | sort -rn | head -n 1)
    if [[ $slickedit_path != '' ]]; then
        alias vs='open -a $slickedit_path'
    fi
    if [ -d "$HOME/Applications/0xED.app" ]; then
        alias he='open -a ~/Applications/0xED.app'
    fi
    if [ -d /Developer/Applications/Qt/Designer.app ]; then
        alias qtd='open -a /Developer/Applications/Qt/Designer.app'
    fi
    alias keychain='open -a /Applications/Utilities/Keychain\ Access.app'
    alias textedit='open -a /Applications/TextEdit.app'
    if [ -d "$HOME/Applications/Emacs.app" ]; then
        alias emacs="$HOME/Applications/Emacs.app/Contents/MacOS/Emacs"
        alias emacsclient="$HOME/Applications/Emacs.app/Contents/MacOS/bin/emacsclient"
        alias em="$HOME/Applications/Emacs.app/Contents/MacOS/Emacs -nw"
        alias ec="$HOME/Applications/Emacs.app/Contents/MacOS/bin/emacsclient -n"
    fi
    alias ls='ls -hFGAO'
    alias ll='ls -l'
    alias top='top -o cpu -i 1'
    alias arp-clear='dscacheutil -flushcache'
    alias eject='diskutil eject'
    alias flush-dns='dscacheutil -flushcache'
    alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport'
fi

if [ "$platform" = 'linux' -o "$platform" == 'mingw' ]; then
    alias du='du -bh --max-depth=1'
    alias ps='ps -ef'
    alias ls='ls -hFA --color=auto'
    alias ll='ls -l'
    alias top='top -d 1'
    if _has_executable xsel; then
        alias pbcopy='xsel --clipboard --input'
        alias pbpaste='xsel --clipboard --output'
    elif _has_executable xclip; then
        alias pbcopy='xclip -selection clipboard'
        alias pbpaste='xclip -selection clipboard -o'
    fi
    if _has_executable xdg-open; then
        alias open="xdg-open"
    elif [[ "$DESKTOP_SESSION" == "gnome" ]]; then
        alias open="gnome-open"
    elif [[ "$DESKTOP_SESSION" == "kde" ]]; then
        alias open="kde-open"
    else
        # Default to xdg open... it'll at least remind me to install
        # xdg-utils (or the equivalent).
        alias open="xdg-open"
    fi
fi

# cd-related
alias mkisofs='mkisofs -iso-level 3 -J -L -r'
alias cdrecord='cdrecord dev=0,0,0 -v driveropts=burnfree'

if [ -d "$HOME/projects/subversion" ]; then
    alias fsfsverify="'$HOME/projects/subversion/contrib/server-side/fsfsverify.py'"
fi

alias apg='apg -M SNCL -m8 -n1 -t -a0'
alias svnup='svn up $(find-project-root)'

if [[ "$platform" == "mingw" ]]; then
    _grep_color=""
else
    _grep_color="--color=auto"
fi

# Don't descend into Subversion's admin area, or others like it.
# Mac's bsd grep sucks... so there's no easy way to do this.
# Also, suppress error messages.
if [[ "$platform" == 'linux' ]]; then
    _grep_extra="$_grep_color -s --exclude-dir=.svn --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.bzr --exclude=tags"
else
    _grep_extra="$_grep_color -s"
fi

alias grep="grep $_grep_extra"

alias ngrep="grep -n $_grep_extra"
alias egrep="egrep $_grep_extra"
alias negrep="egrep -n $_grep_extra"

unset _grep_extra

_has_executable colordiff &&
    {
        function diff()
        {
            if test -t 1
            then
                "$(_find_executable diff)" "$@" | colordiff | $PAGER
            else
                "$(_find_executable diff)" "$@"
            fi
        }

        function interdiff()
        {
            if test -t 1
            then
                "$(_find_executable interdiff)" "$@" | colordiff | $PAGER
            else
                "$(_find_executable interdiff)" "$@"
            fi
        }
    }

if [ -d "$HOME/local/erlang" ]; then
    alias erl="'$HOME/local/erlang/bin/erl'"
    alias erlc="'$HOME/local/erlang/bin/erlc'"
fi
if [ -d "$HOME/.local/erlang" ]; then
    alias erl="'$HOME/.local/erlang/bin/erl'"
    alias erlc="'$HOME/.local/erlang/bin/erlc'"
fi

alias wget="wget --no-check-certificate"
alias wget-ff='wget --user-agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:11.0) Gecko/20100101 Firefox/11.0"'

#alias file='file -L'

alias od='od -A x'
alias traceroute='traceroute -n -w 2'
alias netcat=nc

if _has_executable svnwrap; then
    alias svn=svnwrap

    function svndiff()
    {
        svnwrap diff -x -p --color on "$@" | diff-highlight | $PAGER
    }
else
    function svndiff()
    {
        svn diff -x -p "$@" | colordiff | diff-highlight | $PAGER
    }
fi

# rvm-related
if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
    # yes, this essentially replaces the system gem... but I like to install
    # libraries for me, and not f-up my entire system.
    alias gem="rvm gem"
    alias compass="rvm exec compass"
    alias rake="rvm rake"
fi
