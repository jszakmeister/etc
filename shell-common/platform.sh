# A handy variable to detect which platform we're running on ('linux', 'darwin',
# 'mingw', etc.).
platform=$(uname -s | tr '[:upper:]' '[:lower:]')
