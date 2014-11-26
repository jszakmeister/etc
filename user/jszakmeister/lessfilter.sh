#!/bin/sh
set -e

if ! command -v pygmentize > /dev/null 2>&1; then
    exit 1
fi

PYGMENTIZE="pygmentize -f 256 -O style=native,outencoding=utf-8"

case "$(basename $1)" in
    *.awk|*.groff|*.java|*.js|*.m4|*.php|*.pl|*.pm|*.pod|*.sh|\
    *.ad[asb]|*.asm|*.inc|*.[ch]|*.[ch]pp|*.[ch]xx|*.cc|*.hh|\
    *.lsp|*.l|*.pas|*.p|*.xml|*.xps|*.xsl|*.axp|*.ppd|*.pov|\
    *.py|*.rb|*.sql|*.ebuild|*.eclass|*.vim|*.cmake|CMakeLists.txt|Makefile)
        ${PYGMENTIZE} "$1" 2>/dev/null
        ;;
    *.mk)
        ${PYGMENTIZE} -l make "$1" 2>/dev/null
        ;;
    .bashrc|.bash_aliases|.bash_environment|*.zsh|.zshrc|.zshenv|.zsh-history)
        ${PYGMENTIZE} -l sh "$1" 2>/dev/null
        ;;
    *.patch|*.diff)
        if command -v colordiff > /dev/null 2>&1; then
            cat "$1" | colordiff | diff-highlight
        else
            ${PYGMENTIZE} "$1" 2>/dev/null | diff-highlight
        fi
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
