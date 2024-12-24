#!/bin/bash -e

has_executable()
{
    type -P "$@" > /dev/null 2>&1
}

platform="$(uname -s | tr '[:upper:]' '[:lower:]')"

# Maybe filter some of these off if Brew is available, such as bat?
CRATES=(
    bandwhich
    cargo-edit
    cargo-update
    dtool
    du-dust
    fd-find
    git-graph
    git-igitt
    git-stack
    hwatch
    lychee
    mcfly
    names
    recursum
    riffdiff
    skim
    xcp
)

if [ "$platform" = "linux" ]
then
    CRATES+=(
        dysk
    )
fi

# If we have brew, use the brew versions instead.
if ! has_executable brew
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
