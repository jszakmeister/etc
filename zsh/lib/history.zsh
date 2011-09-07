## Command history configuration
HISTFILE=$HOME/.zsh-history
HISTSIZE=100000
SAVEHIST=100000

# Ignore duplication command history list
setopt hist_ignore_dups

# Share command history data
setopt share_history

# Don't just expand... expand and execute
unsetopt hist_verify

# Incrementally add history to the history file.
# share_history does something similar too.
setopt inc_append_history

# Save timestamp in history file
setopt extended_history

# Shouldn't matter because of hist_ignore_dups,
# but if they do appear, expire dups first.
setopt hist_expire_dups_first

# Don't record commands that begin with a space.
# You'll still have the command in local history,
# it just isn't written to disk.
setopt hist_ignore_space

# Don't store invocations of the history command
setopt hist_no_store
