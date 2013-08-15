source "${ETC_HOME}/shell-common/colors.sh"

_git_has_diverged() {
    local a="$1"
    local b="$2"
    local m=$(git merge-base "$a" "$b")

    if test "$m" = "$(git rev-parse "$a")" -o "$m" = "$(git rev-parse "$b")"; then
        # We've not diverged.
        return 0
    fi

    return 1
}

_vcs_status() {
    function git_status {
        local ref dirty count ahead behind divergent upstream g differ
        g=$(git rev-parse --git-dir 2>/dev/null)
        if [[ -z "$g" ]]; then
                return 1
        fi

        git rev-parse --git-dir >& /dev/null || return 1

        ref="$(git symbolic-ref HEAD 2>/dev/null)" || {
                ref=$( (
                        git describe --tags --exact-match HEAD ||
                        git describe --contains --all HEAD ||
                        git describe --contains HEAD ||
                        git describe HEAD ) 2>/dev/null
                ) ||
                ref="$(cut -c1-7 "$g/HEAD" 2>/dev/null)..." ||
                ref="unknown"
                ref="($ref)"
        }

        if [ ! -f "$g/.nostatus" ]; then
            if [[ -n "$(git status -s 2> /dev/null)" ]]; then
                dirty="${fg_bold_red}*${ansi_reset}"
            else
                dirty=""
            fi
        else
            dirty="${fg_bold_red}?${ansi_reset}"
        fi

        ref="${ref#refs/heads/}"
        upstream=$(git rev-parse --symbolic-full-name @{upstream} 2> /dev/null)
        if [[ $upstream == "@{upstream}" ]]; then
            upstream=""
        else
            upstream=${upstream#refs/remotes/}
        fi

        if [[ -f "$g/.nocount" ]]; then
            ahead="0"
            behind="0"
        elif [[ -n "$upstream" ]]; then
            ahead=$(git rev-list --count --cherry-pick --right-only --no-merges $upstream... 2>/dev/null || echo "0")
            behind=$(git rev-list --count --cherry-pick --left-only --no-merges $upstream... 2>/dev/null || echo "0")
            _git_has_diverged HEAD "$upstream"
            differ=$?
        elif [[ -n "$(git symbolic-ref HEAD 2>/dev/null)" ]]; then
            ahead=$(git rev-list --count --cherry-pick --right-only --no-merges master... 2>/dev/null || echo "0")
            behind=$(git rev-list --count --cherry-pick --left-only --no-merges master... 2>/dev/null || echo "0")
            _git_has_diverged HEAD master
            differ=$?
        else
            ahead="0"
            behind="0"
            differ=0
        fi

        if [[ -n "$upstream" ]]; then
            upstream=" ${fg_no_bold_white}[${upstream/%origin\/$ref/u}]${ansi_reset}"
        fi

        if (( ${behind} > 0 )); then
            behind="${fg_no_bold_white}behind ${fg_bold_red}${behind}${ansi_reset}"
        else
            behind=""
        fi

        if (( ${ahead} > 0 )); then
            ahead="${fg_no_bold_white}ahead ${fg_bold_green}${ahead}${ansi_reset}"
        else
            ahead=""
        fi

        if [ "$differ" -ne 0 ]; then
            differ="${fg_bold_red}∆${ansi_reset}"
        else
            differ=""
        fi

        if [[ -n $ahead && -n $behind ]]; then
            divergent=" [${behind}, ${ahead}]${differ}"
        elif [[ -n $ahead || -n $behind ]]; then
            divergent=" [${behind}${ahead}]${differ}"
        else
            divergent="${differ:+ $differ}"
        fi


        ref="${fg_no_bold_yellow}${ref#refs/heads/}${ansi_reset}"
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
