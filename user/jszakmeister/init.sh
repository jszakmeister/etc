test -e ~/projects/intelesys &&
    _make_dir_complete cdi cd ~/projects/intelesys &&
    _make_dir_complete pdi pushd ~/projects/intelesys
test -e ~/projects/jszakmeister &&
    _make_dir_complete cdj cd ~/projects/jszakmeister &&
    _make_dir_complete pdj pushd ~/projects/jszakmeister
test -e ~/projects &&
    _make_dir_complete cdp cd ~/projects &&
    _make_dir_complete pdp pushd ~/projects

# In ZSH, we need to remove any completions associated with cdc, or this will
# fail.
if [ -n "$ZSH_VERSION" ]; then
    compdef -d cdc
fi
test -e ~/projects/clojure &&
    _make_dir_complete cdc cd ~/projects/clojure &&
    _make_dir_complete pdc pushd ~/projects/clojure

alias tree='tree --charset=ASCII -F -v'
