#!/bin/bash


die()
{
    echo 1>&2 "ERROR: $@"
    exit 1
}


INSTALL_DEV=


PACKAGES_TO_INSTALL='
    aria2
    bat
    colordiff
    eza
    gawk
    grep
    httpie
    libdvdcss
    md5sha1sum
    netcat
    nmap
    openjdk
    openssh
    patchutils
    pstree
    px
    readline
    ripgrep
    rlwrap
    rsync
    sd
    tmux
    topgrade
    tree
    watch
    wget
    xz
'

DEV_PACKAGES_TO_INSTALL='
    asciidoc
    autoconf
    automake
    ccache
    cmake
    git
    git-delta
    git-gui
    gpp
    graphviz
    grc
    hyperfine
    just
    libtool
    minicom
    nasm
    ninja
    packer
    pkg-config
    quilt
    shellcheck
    universal-ctags
    xcodes
    xmlto
    xmltoman
'

if test -n "$1"
then
    while [ "$1" != "" ]
    do
        case $1 in
            --with-dev)
                INSTALL_DEV=t
                ;;
            *)
                die "Unknown option: $1"
                ;;
        esac
        shift
    done
fi

for package in ${PACKAGES_TO_INSTALL}
do
    brew install ${package}
done

if [ "$INSTALL_DEV" = "t" ]
then
    for package in ${DEV_PACKAGES_TO_INSTALL}
    do
        brew install ${package}
    done
fi
