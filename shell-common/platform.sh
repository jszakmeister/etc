# A handy variable to detect which _etc_platform we're running on ('linux', 'darwin',
# 'mingw', etc.).
_etc_machine="$(uname -m | tr '[:upper:]' '[:lower:]')"
_etc_platform=$(uname -s | tr '[:upper:]' '[:lower:]')
if [[ $_etc_platform == mingw* ]]; then
    _etc_platform=mingw
fi

if [ "$_etc_platform" == 'freebsd' -o "$_etc_platform" == 'darwin' ]; then
    function _num_cpus()
    {
        sysctl -n hw.ncpu
    }
elif [ "$_etc_platform" == 'linux' ]; then
    function _num_cpus()
    {
        grep -c ^processor /proc/cpuinfo
    }
else
    function _num_cpus()
    {
        echo 1
    }
fi

# For compatibility... this will eventually go away.
platform="$_etc_platform"
