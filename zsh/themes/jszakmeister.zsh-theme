# jszakmeister@localhost [~/path/to/somewhere] [version-control-status] -------------------------------------------- [something?]

_vcs_status() {
    function git_status {
        local ref dirty count ahead behind divergent upstream g
	g=$(git rev-parse --git-dir 2>/dev/null)
        if [[ -z "$g" ]]; then
		return 1
	fi

        git rev-parse --git-dir >& /dev/null || return 1

	ref="$(git symbolic-ref HEAD 2>/dev/null)" || {
		ref=$(
			git describe --tags --exact-match HEAD ||
			git describe --contains --all HEAD ||
			git describe --contains HEAD ||
			git describe HEAD
		) 2>/dev/null ||
		ref="$(cut -c1-7 "$g/HEAD" 2>/dev/null)..." ||
		ref="unknown"
		ref="($ref)"
	}

        ref="%{$fg_no_bold[yellow]%}${ref#refs/heads/}%{$reset_color%}"
        upstream=$(git rev-parse --symbolic-full-name @{upstream} 2> /dev/null)
        if [[ $upstream == "@{upstream}" ]]; then
            upstream=""
        else
            upstream=${upstream#refs/remotes/}
        fi

        if [[ -n "$(git status -s 2> /dev/null)" ]]; then
            dirty="%{$fg_bold[red]%}*%{$reset_color%}"
        else
            dirty=""
        fi

        if [[ -n "$upstream" ]]; then
            count=$(git rev-list --count --left-right $upstream...HEAD)
            upstream="...%{$fg_no_bold[white]%}${upstream#refs/remotes/}%{$reset_color%}"
        elif [[ -n $(git show-ref HEAD) ]]; then
            count=$(git rev-list --count --left-right master...HEAD)
        else
            count="0 0"
        fi

        if (( ${count[(w)1]} > 0 )); then
            behind="%{$fg_no_bold[white]%}behind %{$fg_bold[red]%}${count[(w)1]}%{$reset_color%}"
        else
            behind=""
        fi

        if (( $count[(w)2] > 0 )); then
            ahead="%{$fg_no_bold[white]%}ahead %{$fg_bold[green]%}${count[(w)2]}%{$reset_color%}"
        else
            ahead=""
        fi

        if [[ -n $ahead && -n $behind ]]; then
            divergent=" [${behind}, ${ahead}]"
        elif [[ -n $ahead || -n $behind ]]; then
            divergent=" [${behind}${ahead}]"
        else
            divergent=""
        fi

        echo "on ${ref}${dirty}${upstream}${divergent}"
        return 0
    }

    function svn_status {
        return 1
    }

    function bzr_status {
        return 1
    }

    function hg_status {
        return 1
    }

    git_status || svn_status || bzr_status || hg_status
}

# Turn off the darn % at the end of a partial line.  Use the technique
# mentioned here:
#     http://zsh.sourceforge.net/FAQ/zshfaq03.html  (3.23)
# to just force us to the next line.
#
# Later versions of zsh support PROMPT_EOL_MARK, but unfortunately
# the zsh that comes with Snow Leopard does not.
unsetopt promptsp
function precmd {
    print -nP "${(l:$((COLUMNS-1)):::):-}\r"

    case "$TERM" in
    xterm*|rxvt*)
        echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD/#$HOME/~}\007"
        ;;
    screen)
        echo -ne "\033_${USER}@${HOST%%.*}:${PWD/#$HOME/~}\007"
        ;;
    *)
        ;;
    esac
}

_jszakmeister_prompt() {
    local separator='%{$fg_bold[blue]%}:%{$reset_color%}'
    local user_host SRMT ERMT

    if [ -n "$SSH_TTY" ]; then
	# We're remoted
        SRMT="{"
        ERMT="}"
    else
        SRMT=""
        ERMT=""
    fi
    user_host="%{$fg_no_bold[white]%}$SRMT%{$fg_bold[yellow]%}%n%{$fg_bold[cyan]%}@%{$fg_bold[blue]%}%M%{$fg_no_bold[white]%}$ERMT%{$reset_color%}"

    local current_dir="%{$fg_bold[yellow]%}[%{$fg_no_bold[magenta]%}"'${PWD/#$HOME/~}'"%{$fg_bold[yellow]%}]%{$reset_color%}"
    local topline="${user_host} ${current_dir} \$(_vcs_status)"

    echo "${topline}
${separator}${separator} "
}

PROMPT="$(_jszakmeister_prompt)"

RPS1="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

