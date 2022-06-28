. "${ETC_HOME}/shell-common/colors.sh"

_git_has_diverged()
{
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

_git_has_matching_push() {
    # push.default is setup for 'simple', 'current', or 'matching'.
    case "$(git config --get push.default || echo "matching")" in
        current | simple | matching)
            return 0
    esac

    return 1
}


_git_determine_upstream_branch() {
    local ref="${1#refs/heads/}"
    local upstream="$(git for-each-ref --format='%(upstream:short)' "refs/heads/$ref")"
    local publish_branch

    if [[ -n "$upstream" ]]; then
        echo "$upstream"
        return 0
    fi

    if ! _git_has_matching_push; then
        return 1
    fi

    # Use the push location as the upstream.
    local remote=$(git config --get branch.${ref}.pushremote ||
        git config --get remote.pushdefault ||
        git config --get branch.${ref}.remote)
    if [ -z "$remote" -a -n "$(git config --get remote.origin.url 2> /dev/null)" ]; then
        remote="origin"
    fi
    if [[ -n "$remote" ]]; then
        git rev-parse "$remote/$ref" > /dev/null 2>&1 &&
            publish_branch="$remote/$ref"
    fi

    if [[ -n "$publish_branch" ]]; then
        echo "$publish_branch"
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

    publish_branch="$(_git_determine_upstream_branch "$ref")"

    echo "$publish_branch"
}


_git_determine_mainline()
{
    BRANCHES="development develop dev main master"

    for branch in $BRANCHES
    do
        git rev-parse --verify "$branch" -q >/dev/null 2>&1 &&
            echo $branch &&
            return 0
    done

    echo master
}


_git_additional()
{
    local g=$(git rev-parse --git-dir 2>/dev/null)
    local r;

    if [ -d "$g/rebase-merge" ]
    then
        if [ -f "$g/rebase-merge/interactive" ]
        then
            r="rebase-i"
        else
            r="rebase-m"
        fi
    else
        if [ -d "$g/rebase-apply" ]
        then
            if [ -f "$g/rebase-apply/rebasing" ]
            then
                r="rebase"
            elif [ -f "$g/rebase-apply/applying" ]
            then
                r="AM"
            else
                r="rebase-am"
            fi
        elif [ -f "$g/MERGE_HEAD" ]
        then
            r="merging"
        elif [ -f "$g/CHERRY_PICK_HEAD" ]
        then
            r="cherry-picking"
        elif [ -f "$g/REVERT_HEAD" ]
        then
            r="reverting"
        elif [ -f "$g/BISECT_LOG" ]
        then
            r="bisecting"
        fi
    fi

    echo "$r"
}


# To detect rebase...
# local r=""
# local b=""
# local step=""
# local total=""
# if [ -d "$g/rebase-merge" ]; then
#     __git_eread "$g/rebase-merge/head-name" b
#     __git_eread "$g/rebase-merge/msgnum" step
#     __git_eread "$g/rebase-merge/end" total
#     if [ -f "$g/rebase-merge/interactive" ]; then
#         r="|REBASE-i"
#     else
#         r="|REBASE-m"
#     fi
# else
#     if [ -d "$g/rebase-apply" ]; then
#         __git_eread "$g/rebase-apply/next" step
#         __git_eread "$g/rebase-apply/last" total
#         if [ -f "$g/rebase-apply/rebasing" ]; then
#             __git_eread "$g/rebase-apply/head-name" b
#             r="|REBASE"
#         elif [ -f "$g/rebase-apply/applying" ]; then
#             r="|AM"
#         else
#             r="|AM/REBASE"
#         fi
#     elif [ -f "$g/MERGE_HEAD" ]; then
#         r="|MERGING"
#     elif [ -f "$g/CHERRY_PICK_HEAD" ]; then
#         r="|CHERRY-PICKING"
#     elif [ -f "$g/REVERT_HEAD" ]; then
#         r="|REVERTING"
#     elif [ -f "$g/BISECT_LOG" ]; then
#         r="|BISECTING"
#     fi

#     if [ -n "$b" ]; then
#         :
#     elif [ -h "$g/HEAD" ]; then
#         # symlink symbolic ref
#         b="$(git symbolic-ref HEAD 2>/dev/null)"
#     else
#         local head=""
#         if ! __git_eread "$g/HEAD" head; then
#             return $exit
#         fi
#         # is it a symbolic ref?
#         b="${head#ref: }"
#         if [ "$head" = "$b" ]; then
#             detached=yes
#             b="$(
#             case "${GIT_PS1_DESCRIBE_STYLE-}" in
#                 (contains)
#                     git describe --contains HEAD ;;
#                 (branch)
#                     git describe --contains --all HEAD ;;
#                 (tag)
#                     git describe --tags HEAD ;;
#                 (describe)
#                     git describe HEAD ;;
#                 (* | default)
#                     git describe --tags --exact-match HEAD ;;
#             esac 2>/dev/null)" ||

#                 b="$short_sha..."
#             b="($b)"
#         fi
#     fi
# fi

# Also think about adding counts for the number of stashed changes.
# This could be useful: https://github.com/magicmonty/bash-git-prompt/blob/master/gitstatus.sh

_vcs_status()
{
    function git_status()
    {
        local ref dirty count ahead behind divergent upstream g differ remote
        local mainline="$(_git_determine_mainline)"
        local nomaster=""

        _has_devtool git || return 1

        g=$(git rev-parse --git-dir 2>/dev/null)
        if [[ -z "$g" ]]; then
                return 1
        fi


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
                ahead=$(git rev-list --count --cherry-pick --right-only --no-merges $mainline... 2>/dev/null || echo "0")
                behind=$(git rev-list --count --cherry-pick --left-only --no-merges $mainline... 2>/dev/null || echo "0")
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
                _git_has_diverged HEAD $mainline
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
            behind="${fg_no_bold_white}behind ${fg_light_red}${behind}${ansi_reset}"
        else
            behind=""
        fi

        if (( ${ahead} > 0 )); then
            ahead="${fg_no_bold_white}ahead ${fg_light_green}${ahead}${ansi_reset}"
        else
            ahead=""
        fi

        if [ "$differ" -ne 0 ]; then
            differ="${fg_light_red}∆${ansi_reset}"
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

        local additional=$(_git_additional)
        if [ -n "$additional" ]
        then
            additional=" {${fg_light_yellow}$additional${ansi_reset}}"
        fi

        ref="${fg_no_bold_yellow}${ref#refs/heads/}${ansi_reset}"
        echo "on ${ref}${dirty}${upstream}${divergent}${additional}"
        return 0
    }

    function svn_status()
    {
        return 1
    }

    function bzr_status()
    {
        return 1
    }

    function hg_status()
    {
        return 1
    }

    git_status || svn_status || bzr_status || hg_status
}
