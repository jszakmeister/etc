#!/bin/bash
PACKAGES_TO_INSTALL='
    automake
    autoconf
    libtool
    ninja
    ccache
    tree
    pkg-config
    wget
    patchutils
    colordiff
    md5sha1sum
    minicom
    libdvdcss
'

for package in ${PACKAGES_TO_INSTALL}; do
    brew install ${package}
done

brew install ctags --keep-ctags
