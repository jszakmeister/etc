# jszakmeister@localhost [~/path/to/somewhere] [version-control-status] -------------------------------------------- [something?]

# Make sure perl is available to help trim the path
[ "$ETC_ZSH_TRIM_PWD" != "0" ] &&
    hash perl > /dev/null 2>&1 && ETC_ZSH_TRIM_PWD="1"

source ${ETC_HOME}/shell-common/jszakmeister-prompt.sh

# Turn off the darn % at the end of a partial line.  Use the technique
# mentioned here:
#     http://zsh.sourceforge.net/FAQ/zshfaq03.html  (3.23)
# to just force us to the next line.
#
# Later versions of zsh support PROMPT_EOL_MARK, but unfortunately
# the zsh that comes with Snow Leopard does not.
unsetopt promptsp

# Attempt to set the terminal's title.
precmd()
{
    _jszakmeister_prompt_title
}

PROMPT="\$(_jszakmeister_prompt)
${JSZAKMEISTER_PROMPT_PS1}"

RPS1="%(?..${fg_red}%? ↵${ansi_reset})"
