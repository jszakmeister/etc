shopt -s extglob progcomp

# Append history, instead of overwriting it
shopt -s histappend

# Record history after every command
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# Make sure COLUMNS is set correctly
shopt -s checkwinsize
