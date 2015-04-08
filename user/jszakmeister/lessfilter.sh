#!/bin/sh
set -e

if ! command -v pygmentize > /dev/null 2>&1; then
    exit 1
fi

PYGMENTIZE="pygmentize -f 256 -O style=native,outencoding=utf-8"

case "$(basename $1)" in
    *.zsh*)
        ${PYGMENTIZE} -l sh "$1" 2>/dev/null
        ;;
    Vagrantfile)
        ${PYGMENTIZE} -l ruby "$1" 2>/dev/null
        ;;
    *.patch|*.diff)
        if command -v colordiff > /dev/null 2>&1; then
            cat "$1" | colordiff | diff-highlight
        else
            ${PYGMENTIZE} "$1" 2>/dev/null | diff-highlight
        fi
        ;;
    CMakeLists.txt)
        ${PYGMENTIZE} "$1" 2>/dev/null
        ;;
    *.txt)
        exit 1
        ;;
    *.*)
        ${PYGMENTIZE} "$1" 2>/dev/null
        ;;
    *)
        grep -E "#\!/bin/(bash|sh|zsh)" "$1" > /dev/null
        if [ "$?" -eq "0" ]; then
            ${PYGMENTIZE} -l sh "$1" 2>/dev/null
        else
            exit 1
        fi
esac

exit 0
