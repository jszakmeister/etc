export WORKON_HOME=$HOME/.virtualenvs
export PAGER=less

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

# Use Vim as a front-end to man.
function man() {
    $(_find_executable man) -P cat "$@" > /dev/null && vim -c "RMan $*"
}

# Put my scripts on the path.
export PATH="$ETC_HOME/user/jszakmeister/scripts/all:$PATH"
