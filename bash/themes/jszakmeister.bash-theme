source ${ETC_HOME}/shell-common/jszakmeister-prompt.sh

# Put part of the prompt in PROMPT_COMMAND, because bash doesn't evaluate
# escape sequences when returned from functions in PS1
PROMPT_COMMAND="echo \"\$(_jszakmeister_prompt)\"; $PROMPT_COMMAND"
PS1="${JSZAKMEISTER_PROMPT_PS1}"
