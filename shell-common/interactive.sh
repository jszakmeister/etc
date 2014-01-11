virtualenvwrapper_path=$(which virtualenvwrapper.sh 2>/dev/null)
if test $? -eq 0; then
    source "${virtualenvwrapper_path}"
fi
unset virtualenvwrapper_path

. "$ETC_HOME/shell-common/aliases.sh"
