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
    site.addsitedir(p)
    sys.path.insert(0, p)
del p
