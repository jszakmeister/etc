# I use this for OSX when installing a new Python.  It makes the default site
# area be ~/.local instead of in ~/Library (if ~/.local directories are
# present), thereby letting me keep my sanity when switching between Linux and
# Mac OS X.  This also makes sure that the user directories show up ahead of
# the system and Homebrew directories.
#
# I typically symlink the file in place with something like:
#     ln -s ~/.etc/python/usercustomize.py ~/Library/Python/X.Y/lib/python/site-packages/usercustomize.py
#
# where X.Y is the version of Python you want to install it for.
#
# Note: this is only necessary on macOS.

def adjust_paths():
    import sys
    import platform
    import os
    import site

    # Don't do this adjustment for jython.
    if not sys.platform.startswith('java'):
        # It's unfortunate, but the equivalent of /usr/local (/Library) on Mac
        # OS X seems to come after /usr (/System) in sys.path.  Let's fix that.
        locations = []

        p = os.path.expanduser(
                '~/.local/lib/python%s/site-packages' % platform.python_version().rsplit('.', 1)[0])
        if os.path.exists(p):
            locations.append(p)

        lib_prefix = os.path.expanduser('~/Library/Python')
        for path in sys.path:
            if path.startswith(lib_prefix):
                locations.append(path)

        for path in sys.path:
            if path.startswith('/Library'):
                locations.append(path)

        locations.reverse()

        for path in locations:
            # Make sure the path is treated as a site directory
            site.addsitedir(path)

            # Most importantly, make sure it's near the front of sys.path...
            # which isn't necessarily the case on some platforms.
            while path in sys.path:
                sys.path.remove(path)
            sys.path.insert(0, path)

adjust_paths()
del adjust_paths
