#!/bin/bash
PACKAGES_TO_INSTALL='
    autoconf
    automake
    ccache
    colordiff
    gettext
    libdvdcss
    libtool
    md5sha1sum
    minicom
    ninja
    nmap
    patchutils
    pkg-config
    rsync
    tmux
    tree
    wget
    xz
'

for package in ${PACKAGES_TO_INSTALL}; do
    brew install ${package}
done

brew install ctags --keep-ctags
