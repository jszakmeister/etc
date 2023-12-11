# jszakmeister@localhost [~/path/to/somewhere] [version-control-status] -------------------------------------------- [something?]

# Make sure perl is available to help trim the path
[ "$ETC_TRIM_PWD" != "0" ] && _has_executable perl && ETC_TRIM_PWD="1"

. "${ETC_HOME}/shell-common/colors.sh"
. "${ETC_HOME}/shell-common/vcs-status.sh"

_jszakmeister_prompt_virtualenv() {
    if [ -n "$VIRTUAL_ENV" ]; then
        echo -ne " ${fg_light_blue}[${fg_red}$(basename "$VIRTUAL_ENV")${fg_light_blue}]${ansi_reset}"
    fi
}

# Turn off virtualenv's prompt facilities... it's in my prompt already
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Attempt to set the terminal's title.
_jszakmeister_prompt_title() {
    # HOSTNAME in some shells, HOST in others
    local host="${HOSTNAME}"
    host="${host:=${HOST}}"

    printf "%$((COLUMNS-1))s\r" ""

    case "$TERM" in
    xterm*|rxvt*)
        echo -ne "\033]0;${USER}@${host%%.*}:${PWD/#$HOME/~}\007"
        ;;
    screen)
        echo -ne "\033_${USER}@${host%%.*}:${PWD/#$HOME/~}\007"
        ;;
    *)
        ;;
    esac
}

_jszakmeister_filter_ansi() {
    if [ -n "$ZSH_VERSION" ]; then
        # Trim out the coloring
        echo "$1" | perl -pe 's|\%\{.*?\%\}||g'
    else
        # Trim out the coloring
        echo "$1" | perl -pe 's|\\\[.*?\\\]||g'
    fi
}

_jszakmeister_prompt() {
    local separator="${fg_light_blue}::${ansi_reset}"
    local user_host vcs_status topline SRMT ERMT regex virtualenv_status
    local user_color="${fg_light_yellow}"
    local ret_code="$1"

    [ -z "$ret_code" ] && ret_code=0

    # HOSTNAME in some shells, HOST in others
    local host="${HOSTNAME}"
    host="${host:=${HOST}}"

    if [ -n "$SSH_TTY" ]; then
        # We're remoted
        SRMT="${fg_no_bold_white}{"
        ERMT="${fg_no_bold_white}}"
    else
        SRMT=""
        ERMT=""
    fi

    if [ "${_etc_platform}" != "mingw" ]; then
        if [ $(id -u) -eq 0 ]; then
            user_color="${fg_bold_red}"
        fi
        [ -z "${USER}" ] && USER="$(id -nu)"
    else
        # If USER is empty, try USERNAME.  This happens on Windows.
        [ -z "${USER}" ] && USER="${USERNAME}"
    fi

    user_host="$SRMT${user_color}${USER}${fg_light_cyan}@${fg_light_blue}${host}$ERMT${ansi_reset}"

    vcs_status=$(_vcs_status)
    [ -n "${vcs_status}" ] && vcs_status=" ${vcs_status}"

    virtualenv_status=$(_jszakmeister_prompt_virtualenv)

    # Take the current working directory, and replace the leading path
    # with ~ if it's under the home directory.  The goofiness surrounding the
    # tilde is because newer bash versions started expanding tilde in the
    # parameter expansion, negating the shortening effect we were looking for.
    # Escaping with a backslash doesn't work because the backslash is visible in
    # zsh.  So we do this trick with quoting to make sure that both bash and zsh
    # see a tilde that should not be expanded.  Note: bash's setting of
    # expand-tilde off did not prevent expansion within a parameter.
    if [ "${HOME/#$HOME/""~""}" == '""~""' ]
    then
        current_dir="${PWD/#$HOME/~}"
    else
        current_dir="${PWD/#$HOME/""~""}"
    fi

    if [ -n "$BASH" -a "$ret_code" -ne 0 ]; then
        last_status="  ${fg_red}$ret_code ↵${ansi_reset} "
    else
        last_status=
    fi

    # This isn't exactly what the topline is going to be.  We're just using it
    # to calculate a length for now
    topline="${user_host} []${virtualenv_status}${vcs_status}${last_status}"

    topline=$(_jszakmeister_filter_ansi "$topline")

    # length now represents how much room we have
    let "length = $COLUMNS - ${#topline}"

    if [[ "$ETC_TRIM_PWD" != "0" ]]; then
        if (( $length < ${#current_dir} )); then
            if [[ $current_dir == "~"/* ]]; then
                # 6 comes from the ~/.../ in the output
                let "length = $length - 6"
                regex="s|^~/.*?(/.{1,$length})$|~/...\1|"
            else
                # 5 comes from the /.../ in the output
                let "length = $length - 5"
                regex="s|^/.*?(/.{1,$length})$|/...\1|"
            fi
            if (( $length > 0 )); then
                current_dir=$(echo -n $current_dir | perl -pe "$regex")
            fi
        fi
    fi

    if [ "$ret_code" -ne 0 ]; then
        let "length = $COLUMNS - ${#topline} - ${#current_dir}"
        if (( $length < 0 )); then
            let "length = 0"
        fi
        last_status="$(printf "%${length}s" "")${last_status}"
    fi

    current_dir="${fg_light_yellow}[${fg_no_bold_magenta}${current_dir}${fg_light_yellow}]${ansi_reset}"
    topline="${user_host} ${current_dir}${virtualenv_status}${vcs_status}${last_status}"

    if [ -n "$BASH" ]; then
        # In bash, we use PROMPT_COMMAND to display the topline... because bash
        # can't embed a function call into a prompt and evaluate the ansi escape
        # codes and bash prompt codes. So, we remove the \[ and \] from the
        # colors.
        topline="${topline//\\[/}"
        topline="${topline//\\]/}"
    fi
    echo -e "$topline"
}

JSZAKMEISTER_PROMPT_PS1="${fg_light_blue}::${ansi_reset} "
