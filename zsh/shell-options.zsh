autoload -U url-quote-magic
zle -N self-insert url-quote-magic

# Setup the prompt with pretty colors
setopt prompt_subst

# Load and run compinit
autoload -U compinit
compinit -i

# Load the bash compatibility completion engine
autoload -Uz bashcompinit
bashcompinit

. "$ETC_HOME/bash/bash_completion.sh"

# This is necessary for git-completion to work correctly for zsh.
if [ -f /usr/local/etc/bash_completion.d/git-completion.bash ]; then
    zstyle ':completion:*:*:git:*' script \
        /usr/local/etc/bash_completion.d/git-completion.bash
elif [ -f /etc/bash_completion.d/git ]; then
    zstyle ':completion:*:*:git:*' script \
        /etc/bash_completion.d/git
elif [ -f /usr/share/bash-completion/completions/git ]; then
    zstyle ':completion:*:*:git:*' script \
        /usr/share/bash-completion/completions/git
else
    zstyle ':completion:*:*:git:*' script "$ETC_HOME/bash/git-completion.bash"
fi

if _has_executable aws_zsh_completer.sh; then
    . "$(_find_executable aws_zsh_completer.sh)"
fi

autoload colors
colors

# Case sensitive globbing.
setopt case_glob

# Redirection can create files.
setopt clobber

# Want globbing.
setopt glob

# Don't warn about non-matching globs.
unsetopt nomatch

# Don't print stack after push/pop.
setopt pushd_silent

# Allow lines that starts with # to be ignored.  It's nice for
# small screencasts.
setopt interactivecomments

# Split words using IFS just like sh.
setopt shwordsplit

# Remove superfluous blanks from each command line being added
# to the history list.
setopt hist_reduce_blanks

# Use bash word style selection.
autoload -U select-word-style
select-word-style bash
