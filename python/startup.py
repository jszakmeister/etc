# Add a line like the following to your .bashrc:
#  export PYTHONSTARTUP="$ETC_HOME/python/startup.py"

import readline, atexit, os, rlcompleter, sys


historypath = os.path.expanduser("~/.pyhistory")
editrcpath = os.path.expanduser("~/.editrc")
inputrcpath = os.path.expanduser("~/.inputrc")

if 'darwin' in sys.platform:
    if not os.path.exists(editrcpath):
        readline.parse_and_bind("bind ^[[A ed-search-prev-history")
        readline.parse_and_bind("bind ^[[B ed-search-next-history")

    readline.parse_and_bind("bind ^I rl_complete")

elif 'linux' in sys.platform:
    if not os.path.exists(inputrcpath):
        readline.parse_and_bind(r'"\e[A": history-search-backward')
        readline.parse_and_bind(r'"\e[B": history-search-forward')

    readline.parse_and_bind("tab: complete")

def save_history(historypath=historypath):
    import readline
    readline.write_history_file(historypath)

if os.path.exists(historypath):
    readline.read_history_file(historypath)

atexit.register(save_history)

del os, sys, atexit, readline, save_history, historypath
del inputrcpath, editrcpath, rlcompleter
