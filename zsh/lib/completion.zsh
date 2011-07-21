# Turns on completion for . and .. directories.
# Here's a bug report on the issue:
#    http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=514152
zstyle ':completion:*' special-dirs true

# Setup a cache so that apt and dpkg completions are usable
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zcache
