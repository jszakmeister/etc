# I use this for OSX when installing a new Python.  It makes the default site
# area be ~/.local instead of in ~/Library, thereby letting me keep my sanity
# when switching between Linux and Mac OS X.
import sys
import platform
import os
import site

p = os.path.expanduser(
        '~/.local/lib/python%s/site-packages' % platform.python_version().rsplit('.', 1)[0])
if os.path.exists(p):
    # Make sure the path is treated as a site directory
    site.addsitedir(p)
    # Most importantly, make sure it's near the front of sys.path... which isn't
    # necessarily the case on some platforms.
    sys.path.insert(0, p)
del p
