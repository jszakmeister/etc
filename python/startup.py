# Add a line like the following to your .bashrc:
#  export PYTHONSTARTUP="$HOME/projects/etc/python/startup.py"

import readline, atexit, os, rlcompleter
 
historypath = os.path.expanduser("~/.pyhistory")
editrcpath = os.path.expanduser("~/.editrc")

try:
    readline.read_init_file(editrcpath)
except:
    readline.parse_and_bind("bind ^I rl_complete")
    readline.parse_and_bind("bind ^[[A ed-search-prev-history")
    readline.parse_and_bind("bind ^[[B ed-search-next-history")

def save_history(historypath=historypath):
    import readline
    readline.write_history_file(historypath)
           
if os.path.exists(historypath):
    readline.read_history_file(historypath)
                
atexit.register(save_history)
                 
del os, atexit, readline, save_history, historypath, editrcpath, rlcompleter

