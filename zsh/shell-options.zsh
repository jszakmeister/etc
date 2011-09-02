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

test -s "$ETC_HOME/bash/bash_completion.sh" && . "$ETC_HOME/bash/bash_completion.sh"
test -s "$ETC_HOME/bash/git-autocomplete.sh" && . "$ETC_HOME/bash/git-autocomplete.sh"

autoload colors
colors

setopt no_auto_menu         # don't show menu for completion
setopt auto_list            # show the completion list right away
LISTMAX=1000                # don't prompt for less than 1000 completions
setopt case_glob            # case sensitive globbing
setopt clobber              # redirection can create files
setopt glob		    # want globbing
unsetopt nomatch	    # don't warn about non-matching globs
setopt pushd_silent         # don't print stack after push/pop

