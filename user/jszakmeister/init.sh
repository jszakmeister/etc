test -e ~/projects/intelesys &&
    _make_dir_complete cdi cd ~/projects/intelesys &&
    _make_dir_complete pdi pushd ~/projects/intelesys
test -e ~/projects/jszakmeister &&
    _make_dir_complete cdj cd ~/projects/jszakmeister &&
    _make_dir_complete pdj pushd ~/projects/jszakmeister
test -e ~/projects &&
    _make_dir_complete cdp cd ~/projects &&
    _make_dir_complete pdp pushd ~/projects
test -e ~/.vim &&
    _make_dir_complete cdv cd ~/.vim &&
    _make_dir_complete pdv pushd ~/.vim

# In ZSH, we need to remove any completions associated with cdc, or this will
# fail.
if [ -n "$ZSH_VERSION" ]; then
    compdef -d cdc
fi
test -e ~/projects/clojure &&
    _make_dir_complete cdc cd ~/projects/clojure &&
    _make_dir_complete pdc pushd ~/projects/clojure

alias tree='tree --charset=ASCII -F -v'

# Turn off xon/xoff flow control.  This also allows the use of CTRL-Q and CTRL-S
# in vim when running at the terminal.
test -t 0 && type -f stty >& /dev/null && stty -ixon -ixoff

# Use vim for the MANPAGER, if vimpager is setup
if [ -e "$ETC_HOME/vimpager/vimpager.sh" ]; then
    export MANPAGER="$ETC_HOME/vimpager/vimpager.sh"
fi
