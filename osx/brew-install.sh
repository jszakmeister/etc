#!/bin/bash
PACKAGES_TO_INSTALL='
    asciidoc
    autoconf
    automake
    ccache
    colordiff
    gawk
    gettext
    grep
    httpie
    libdvdcss
    libtool
    md5sha1sum
    minicom
    nasm
    netcat
    ninja
    nmap
    patchutils
    pkg-config
    quilt
    rsync
    tig
    tmux
    tree
    wget
    xmlto
    xmltoman
    xz
'

for package in ${PACKAGES_TO_INSTALL}; do
    brew install ${package}
done

brew install ctags --keep-ctags
brew install homebrew/dupes/openssh --with-keychain-support --with-ldns
brew install zmq --universal --with-pgm
