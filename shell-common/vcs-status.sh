source "${ETC_HOME}/shell-common/colors.sh"

_git_has_diverged() {
    local a="$1"
    local b="$2"
    local m

    m=$(git merge-base "$a" "$b" 2>/dev/null)

    # This probably means there is no HEAD.  For example, on a new repository.
    if [ $? -ne 0 ]; then
        return 0
    fi

    if test "$m" = "$(git rev-parse "$a")" -o "$m" = "$(git rev-parse "$b")"; then
        # We've not diverged.
        return 0
    fi

    return 1
}

# This is duplicated in git-missing.  Make sure to update both if you make
# changes.
_git_infer_publish_branch()
{
    local publish_branch

    ref="$(git symbolic-ref HEAD 2>/dev/null)"
    if [[ "$ref" == "" ]]; then
        return
    fi

    ref="${ref#refs/heads/}"

    case $(git config --get push.default || echo "matching") in
        current | simple | matching)
            remote=$(git config --get branch.${ref}.pushremote ||
                git config --get remote.pushdefault ||
                git config --get branch.${ref}.remote)
            if [ -z "$remote" -a -n "$(git config --get remote.origin.url 2> /dev/null)" ]; then
                remote="origin"
            fi
            if [[ -n "$remote" ]]; then
                git rev-parse "$remote/$ref" > /dev/null 2>&1 &&
                    publish_branch="$remote/$ref"
            fi
            ;;
        upstream)
            publish_branch=$(git rev-parse --symbolic-full-name @{upstream} 2> /dev/null)
            if [ $? -eq 0 -a "$publish_branch" != "@{upstream}" ]; then
                publish_branch=${publish_branch#refs/remotes/}
            else
                publish_branch=""
            fi
            ;;
        *)
            publish_branch=""
            ;;
    esac

    echo "$publish_branch"
}

_vcs_status() {
    function git_status {
        local ref dirty count ahead behind divergent upstream g differ remote
        local nomaster=""

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

        upstream="$(_git_infer_publish_branch)"

        [ -f "$g/.nomaster" ] && nomaster=true

        if [[ -n "$upstream" ]]; then
            ahead=$(git rev-list --count --cherry-pick --right-only --no-merges $upstream... 2>/dev/null || echo "0")
            behind=$(git rev-list --count --cherry-pick --left-only --no-merges $upstream... 2>/dev/null || echo "0")
        elif [[ -n "$(git symbolic-ref HEAD 2>/dev/null)" ]]; then
            if [[ -n "$nomaster" ]]; then
                ahead="0"
                behind="0"
            else
                ahead=$(git rev-list --count --cherry-pick --right-only --no-merges master... 2>/dev/null || echo "0")
                behind=$(git rev-list --count --cherry-pick --left-only --no-merges master... 2>/dev/null || echo "0")
            fi
        else
            ahead="0"
            behind="0"
        fi

        # Divergence isn't the same as counts (counts checks patch id, where as
        # divergence takes into account the real commit id).
        if [[ -n "$upstream" ]]; then
            _git_has_diverged HEAD "$upstream"
            differ=$?
        elif [[ -n "$(git symbolic-ref HEAD 2>/dev/null)" ]]; then
            if [[ -n "$nomaster" ]]; then
                differ=0
            else
                _git_has_diverged HEAD master
                differ=$?
            fi
        else
            differ=0
        fi

        if [[ -n "$upstream" ]]; then
            # Use a simple "u" if the it's at origin/<branch-name>.
            upstream="${upstream/%origin\/$ref/u}"

            # If the remote is different, use "remote/...".
            if [[ "$upstream" == */${ref} ]]; then
                upstream="${upstream%%${ref}}..."
            fi
            upstream=" ${fg_no_bold_white}[${upstream}]${ansi_reset}"
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
