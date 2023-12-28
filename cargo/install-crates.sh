#!/bin/bash -e

_has_executable()
{
    type -P "$@" > /dev/null 2>&1
}

# Maybe filter some of these off if Brew is available, such as bat?
CRATES=(
    cargo-update
    dtool
    du-dust
    fd-find
    git-graph
    git-igitt
    git-stack
    names
    recursum
    skim
    xcp
)

# If we have brew, use the brew versions instead.
if ! _has_executable brew
then
    CRATES+=(
        bat
        bottom
        broot
        eza
        git-delta
        hyperfine
        just
        ripgrep
        rust-parallel
        sd
        topgrade
    )
fi

cargo install "${CRATES[@]}"
