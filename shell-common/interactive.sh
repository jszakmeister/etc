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

test -d "$ETC_LOCAL_DIR/interactive.sh" &&
    . "$ETC_LOCAL_DIR/interactive.sh"
test -d "$ETC_USER_DIR/interactive.sh" &&
    . "$ETC_USER_DIR/interactive.sh"
test -s "$ETC_HOME/user/$ETC_USER/interactive.sh" &&
    . "$ETC_HOME/user/$ETC_USER/interactive.sh"
