#!/bin/sh
case "$1" in
    *.awk|*.groff|*.java|*.js|*.m4|*.php|*.pl|*.pm|*.pod|*.sh|\
    *.ad[asb]|*.asm|*.inc|*.[ch]|*.[ch]pp|*.[ch]xx|*.cc|*.hh|\
    *.lsp|*.l|*.pas|*.p|*.xml|*.xps|*.xsl|*.axp|*.ppd|*.pov|\
    *.py|*.rb|*.sql|*.ebuild|*.eclass|*.vim)
        pygmentize -f 256 -O style=native "$1" 2>/dev/null;;
    .bashrc|.bash_aliases|.bash_environment|*.zsh|.zshrc|.zshenv|.zsh-history)
        pygmentize -f 256 -O style=native -l sh "$1" 2>/dev/null
        ;;
    *.patch|*.diff)
        pygmentize -f 256 -O style=native "$1" 2>/dev/null | diff-highlight
        ;;
    *)
        grep "#\!/bin/bash" "$1" > /dev/null
        if [ "$?" -eq "0" ]; then
            pygmentize -f 256 -O style=native -l sh "$1" 2>/dev/null
        else
            exit 1
        fi
esac

exit 0
