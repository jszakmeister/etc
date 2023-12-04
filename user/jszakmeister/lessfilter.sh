#!/bin/bash
set -e

PYGMENTIZE="pygmentize -f 256 -O style=native,outencoding=utf-8"


colorize()
{
    if has_executable pygmentize
    then
        ${PYGMENTIZE} "$@" 2>/dev/null
    else
        exit 1
    fi
}


has_executable()
{
    if type -P "$1" > /dev/null 2>&1
    then
        return 0
    fi

    return 1
}


format_xml()
{
    if has_executable xmllint
    then
        xmllint --format - < "$1" | colorize -l xml
    else
        colorize "$1"
    fi
}


is_binary()
{
    local mimetype
    mimetype="$(file -bL --mime "$1")"
    case "$mimetype" in
        *charset=binary)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}


show_binary()
{
    if [ -n "$ETC_LESS_HEXDUMP" ]
    then
        $ETC_LESS_HEXDUMP "$1"
    elif [ -x /usr/bin/hexdump ]
    then
        /usr/bin/hexdump -v -e '"%10_ad (%8_axh):  " 8/1 "%02x " "  " 8/1 "%02x "' -e'"  " 16/1 "%_p" "\n"' "$1"
    else
        exit 1
    fi
}


case "$(basename "$1")" in
    *.zsh*)
        colorize -l sh "$1"
        ;;
    *.mk|Makefile.*|Makefile)
        colorize -l make "$1"
        ;;
    Vagrantfile)
        colorize -l ruby "$1"
        ;;
    *.patch|*.diff)
        if has_executable delta
        then
            delta < "$1"
        elif has_executable colordiff
        then
            colordiff < "$1" | diff-highlight
        else
            colorize "$1" | diff-highlight
        fi
        ;;
    CMakeLists.txt|Dockerfile)
        colorize "$1" 2>/dev/null
        ;;
    *.txt)
        exit 1
        ;;
    *.xml|*.mobileconfig)
        format_xml "$1"
        ;;
    *.plist)
        if [ "$(head -c 6 "$1")" = "bplist" ]
        then
            if has_executable plutil
            then
                plutil -convert xml1 -o - "$1"
            else
                show_binary "$1"
            fi
        else
            format_xml "$1"
        fi
        ;;
    .etcrc*)
        colorize -l sh "$1"
        ;;
    *.*)
        if is_binary "$1"
        then
            show_binary "$1"
        else
            colorize "$1"
        fi
        ;;
    *)
        if is_binary "$1"
        then
            show_binary "$1"
        else
            shebang=$(head -1 "$1")
            shebang=${shebang/#*\/env /}
            shebang=${shebang/#*\//}
            case "$shebang" in
                bash|zsh|sh)
                    colorize -l sh "$1"
                    ;;
                python3|python2|python)
                    colorize -l python "$1"
                    ;;
                *)
                    colorize "$1"
                    ;;
            esac
        fi
esac

exit 0
