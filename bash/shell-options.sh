shopt -s extglob progcomp

# Append history, instead of overwriting it
shopt -s histappend

# Record history after every command
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# Make sure COLUMNS is set correctly
shopt -s checkwinsize

# Don't store duplicates and ignore commands with a leading space
export HISTCONTROL=ignoreboth

# Remember 100,000 lines of history
export HISTSIZE=100000
export HISTFILESIZE=10000
