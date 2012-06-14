test -e ~/projects/intelesys &&
    _make_dir_complete cdi ~/projects/intelesys
test -e ~/projects/jszakmeister &&
    _make_dir_complete cdj ~/projects/jszakmeister
test -e ~/projects &&
    _make_dir_complete cdp ~/projects

# In ZSH, we need to remove any completions associated with cdc, or this will
# fail.
if [ -n "$ZSH_VERSION" ]; then
    compdef -d cdc
fi
test -e ~/projects/clojure &&
    _make_dir_complete cdc ~/projects/clojure
