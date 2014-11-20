# _start_ansi and _end_ansi must be defined for your shell.
fg_black="${_start_ansi}$(echo -ne "\033[22;30m")${_end_ansi}"
fg_red="${_start_ansi}$(echo -ne "\033[22;31m")${_end_ansi}"
fg_green="${_start_ansi}$(echo -ne "\033[22;32m")${_end_ansi}"
fg_yellow="${_start_ansi}$(echo -ne "\033[22;33m")${_end_ansi}"
fg_blue="${_start_ansi}$(echo -ne "\033[22;34m")${_end_ansi}"
fg_magenta="${_start_ansi}$(echo -ne "\033[22;35m")${_end_ansi}"
fg_cyan="${_start_ansi}$(echo -ne "\033[22;36m")${_end_ansi}"
fg_white="${_start_ansi}$(echo -ne "\033[22;37m")${_end_ansi}"
fg_bold="${_start_ansi}$(echo -ne "\033[1m")${_end_ansi}"
fg_no_bold="${_start_ansi}$(echo -ne "\033[22m")${_end_ansi}"
fg_no_bold_black=$fg_black
fg_no_bold_red=$fg_red
fg_no_bold_green=$fg_green
fg_no_bold_yellow=$fg_yellow
fg_no_bold_blue=$fg_blue
fg_no_bold_magenta=$fg_magenta
fg_no_bold_cyan=$fg_cyan
fg_no_bold_white=$fg_white
fg_bold_black="${_start_ansi}$(echo -ne "\033[1;30m")${_end_ansi}"
fg_bold_red="${_start_ansi}$(echo -ne "\033[1;31m")${_end_ansi}"
fg_bold_green="${_start_ansi}$(echo -ne "\033[1;32m")${_end_ansi}"
fg_bold_yellow="${_start_ansi}$(echo -ne "\033[1;33m")${_end_ansi}"
fg_bold_blue="${_start_ansi}$(echo -ne "\033[1;34m")${_end_ansi}"
fg_bold_magenta="${_start_ansi}$(echo -ne "\033[1;35m")${_end_ansi}"
fg_bold_cyan="${_start_ansi}$(echo -ne "\033[1;36m")${_end_ansi}"
fg_bold_white="${_start_ansi}$(echo -ne "\033[1;37m")${_end_ansi}"

if [ "$platform" == "mingw" ]; then
    # Default to bolding under Windows
    fg_light_black="${fg_bold_black}"
    fg_light_red="${fg_bold_red}"
    fg_light_green="${fg_bold_green}"
    fg_light_yellow="${fg_bold_yellow}"
    fg_light_blue="${fg_bold_blue}"
    fg_light_magenta="${fg_bold_magenta}"
    fg_light_cyan="${fg_bold_cyan}"
    fg_light_white="${fg_bold_white}"
else
    fg_light_black="${_start_ansi}$(echo -ne "\033[90m")${_end_ansi}"
    fg_light_red="${_start_ansi}$(echo -ne "\033[91m")${_end_ansi}"
    fg_light_green="${_start_ansi}$(echo -ne "\033[92m")${_end_ansi}"
    fg_light_yellow="${_start_ansi}$(echo -ne "\033[93m")${_end_ansi}"
    fg_light_blue="${_start_ansi}$(echo -ne "\033[94m")${_end_ansi}"
    fg_light_magenta="${_start_ansi}$(echo -ne "\033[95m")${_end_ansi}"
    fg_light_cyan="${_start_ansi}$(echo -ne "\033[96m")${_end_ansi}"
    fg_light_white="${_start_ansi}$(echo -ne "\033[97m")${_end_ansi}"
fi

ansi_reset="${_start_ansi}$(echo -ne "\033[0m")${_end_ansi}"
