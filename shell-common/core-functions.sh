function _has_executable
{
    _find_executable "$@" > /dev/null 2>&1
}

function prepend_path
{
    if [[ "$1" == '' ]]; then
        echo $2
    else
        echo $2:$1
    fi
}

function append_path
{
    if [[ "$1" == '' ]]; then
        echo $2
    else
        echo $1:$2
    fi
}
