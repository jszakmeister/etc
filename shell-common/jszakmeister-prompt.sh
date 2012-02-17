# jszakmeister@localhost [~/path/to/somewhere] [version-control-status] -------------------------------------------- [something?]

# Make sure perl is available to help trim the path
[ "$ETC_TRIM_PWD" != "0" ] &&
    hash perl > /dev/null 2>&1 && ETC_TRIM_PWD="1"

source ${ETC_HOME}/shell-common/colors.sh
source ${ETC_HOME}/shell-common/vcs-status.sh

# Attempt to set the terminal's title.
_jszakmeister_prompt_title() {
    # HOSTNAME in some shells, HOST in others
    local host="${HOSTNAME}"
    host="${host:=${HOST}}"

    print -nP "${(l:$((COLUMNS-1)):::):-}\r"

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


_jszakmeister_prompt() {
    local separator="${fg_bold_blue}::${ansi_reset}"
    local user_host vcs_status topline SRMT ERMT regex
    
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
    user_host="$SRMT${fg_bold_yellow}${USER}${fg_bold_cyan}@${fg_bold_blue}${host}$ERMT${ansi_reset}"
    vcs_status=$(_vcs_status)

    # Take the current working directory, and replace the leading path
    # with ~ if it's under the home directory.
    current_dir="${PWD/#$HOME/~}"

    if [[ "$ETC_TRIM_PWD" != "0" ]]; then
        # This isn't exactly what the topline is going to be.  We're just using it
        # to calculate a length for now
        topline="${user_host} ${vcs_status} "

        if [ -n "$ZSH_VERSION" ]; then
            # Trim out the coloring
            topline=$(echo "$topline" | perl -pe 's|\%\{.*?\%\}||g')
        else
            # Trim out the coloring
            topline=$(echo "$topline" | perl -pe 's|\\\[.*?\\\]||g')
        fi

        # length now represents how much room we have (square brackets already
        # accounted for with the 2)
        let "length = $COLUMNS - ${#topline} - 2"

        if (( $length < ${#current_dir} )); then
            if [[ $PWD == ~/* ]]; then
                # 6 comes from the ~/.../ in the output
                let "length = $length - 6"
                regex="s|^~/.*?(/.{1,$length})$|~/...\1|"
            else
                # 5 comes from the /.../ in the output
                let "length = $length - 5"
                regex="s|^/.*?(/.{1,$length})$|/...\1|"
            fi
            current_dir=$(echo -n $current_dir | perl -pe "$regex")
        fi
    fi

    current_dir="${fg_bold_yellow}[${fg_no_bold_magenta}${current_dir}${fg_bold_yellow}]${ansi_reset}"
    topline="${user_host} ${current_dir} ${vcs_status}"

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

JSZAKMEISTER_PROMPT_PS1="${fg_bold_blue}::${ansi_reset} "
