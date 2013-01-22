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

# Attempt to set up Git completion for zsh as documented inside git-completion.zsh
if [ -r "$HOME/.local/etc/git-completion.bash" ] &&
        [ -r "$HOME/.local/etc/git-completion.zsh" ]; then
  zstyle ':completion:*:*:git:*' script $HOME/.local/etc/git-completion.bash

  [ ! -L ~/.zsh/completion/_git ] &&
          mkdir -p ~/.zsh/completion &&
          ln -s $HOME/.local/etc/git-completion.zsh ~/.zsh/completion/_git

  fpath=(~/.zsh/completion $fpath)
elif [ -r "$HOME/.local/etc/completion/git-completion.bash" ] &&
        [ -r "$HOME/.local/etc/completion/git-completion.zsh" ]; then
  zstyle ':completion:*:*:git:*' script $HOME/.local/etc/completion/git-completion.bash

  [ ! -L ~/.zsh/completion/_git ] &&
          mkdir -p ~/.zsh/completion &&
          ln -s $HOME/.local/etc/completion/git-completion.zsh ~/.zsh/completion/_git

  fpath=(~/.zsh/completion $fpath)
fi

autoload colors
colors

setopt case_glob            # case sensitive globbing
setopt clobber              # redirection can create files
setopt glob		    # want globbing
unsetopt nomatch	    # don't warn about non-matching globs
setopt pushd_silent         # don't print stack after push/pop

# Allow lines that starts with # to be ignored.  It's nice for
# small screencasts.
setopt interactivecomments
