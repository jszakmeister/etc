virtualenvwrapper_path=$(_find_executable virtualenvwrapper.sh)

if test -z "$virtualenvwrapper_path"; then
    test -e /usr/share/virtualenvwrapper/virtualenvwrapper.sh &&
        virtualenvwrapper_path=/usr/share/virtualenvwrapper/virtualenvwrapper.sh
fi

if test -n "$virtualenvwrapper_path"; then
    . "${virtualenvwrapper_path}"
fi

unset virtualenvwrapper_path

. "$ETC_HOME/shell-common/aliases.sh"
