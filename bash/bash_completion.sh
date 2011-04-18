# Check for interactive bash and that we haven't already been sourced.
[ -z "$BASH_VERSION" -o -z "$PS1" -o -n "$BASH_COMPLETION" ] && return

export BASH_COMPLETION=$HOME/projects/etc/bash/bash_completion
export BASH_COMPLETION_DIR=$HOME/projects/etc/bash/bash_completion.d

# Check for recent enough version of bash.
bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}
if [ $bmajor -gt 3 ] || [ $bmajor -eq 3 -a $bminor -ge 2 ]; then
    if shopt -q progcomp && [ -r $HOME/projects/etc/bash/bash_completion ]; then
        # Source completion code.
        . $HOME/projects/etc/bash/bash_completion
    fi
fi
unset bash bmajor bminor
