virtualenvwrapper_path=$(which virtualenvwrapper.sh)
if test $? -eq 0; then
    source "${virtualenvwrapper_path}"
fi
unset virtualenvwrapper_path
