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
    *.mk|Makefile.*|Makefile)
        ${PYGMENTIZE} -l make "$1" 2>/dev/null
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
        shebang=$(head -1 "$1")
        shebang=${shebang/#*\/env /}
        shebang=${shebang/#*\//}
        case "$shebang" in
            bash|zsh|sh)
                ${PYGMENTIZE} -l sh "$1" 2>/dev/null
                ;;
            python3|python2|python)
                ${PYGMENTIZE} -l python "$1" 2>/dev/null
                ;;
            *)
                exit 1
                ;;
        esac
esac

exit 0
