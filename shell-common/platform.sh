# A handy variable to detect which platform we're running on ('linux', 'darwin',
# 'mingw', etc.).
platform=$(uname -s | tr '[:upper:]' '[:lower:]')
if [[ $platform == mingw* ]]; then
    platform=mingw
fi

if [ "$platform" == 'freebsd' -o "$platform" == 'darwin' ]; then
    function _num_cpus
    {
        sysctl -n hw.ncpu
    }
elif [ "$platform" == 'linux' ]; then
    function _num_cpus
    {
        grep -c ^processor /proc/cpuinfo
    }
else
    function _num_cpus
    {
        echo 1
    }
fi
