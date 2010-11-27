PATHS_TO_PREPEND=$HOME/bin:$HOME/.local/bin:$HOME/local/bin:/usr/local/bin
PATHS_TO_APPEND=

platform=`uname`
if [[ "$platform" == 'Darwin' ]]; then
        python_version=`python -c "import sys; print '%d.%d' % sys.version_info[:2]"`
        PATHS_TO_PREPEND=$PATHS_TO_PREPEND:$HOME/Library/Python/$python_version/bin
        PATHS_TO_APPEND=$PATHS_TO_APPEND:/Library/Python/$python_version/bin:/System/Library/Frameworks/Python.framework/Versions/$python_version/bin

        slickedit_path=`\ls -d /Applications/SlickEdit* ~/Applications/SlickEdit* 2>/dev/null | sort -rn | head -n 1`
        if [[ $slickedit_path != '' ]]; then
            if [ -f $slickedit_path/Contents/slickedit/bin/vs ]; then
                PATHS_TO_APPEND=$PATHS_TO_APPEND:$slickedit_path/Contents/slickedit/bin
            fi
            if [ -f $slickedit_path/Contents/MacOS/vs ]; then
                PATHS_TO_APPEND=$PATHS_TO_APPEND:$slickedit_path/Contents/MacOS
            fi
        fi
        
        if [ -d /opt/local/bin ]; then
                PATHS_TO_APPEND=$PATHS_TO_APPEND:/opt/local/bin
        fi

        if [ -d /usr/local/texlive/2009/bin/universal-darwin ]; then
                PATHS_TO_APPEND=$PATHS_TO_APPEND:/usr/local/texlive/2009/bin/universal-darwin
        fi
fi
if [[ "$platform" == 'Linux' ]]; then
        if [ -d /opt/slickedit ]; then
                PATHS_TO_PREPEND=$PATHS_TO_PREPEND:/opt/slickedit/bin
        fi
        if [ -d $HOME/.local/slickedit ]; then
                PATHS_TO_PREPEND=$PATHS_TO_PREPEND:$HOME/.local/slickedit/bin
        fi
fi

if [[ "$PATHS_TO_PREPEND" != '' ]]; then
        export PATH=$PATHS_TO_PREPEND:$PATH
fi

if [[ "$PATHS_TO_APPEND" != '' ]]; then
        export PATH=$PATH:$PATHS_TO_APPEND
fi

have_slickedit=`which vs`
if [[ "$have_slickedit" != '' ]]; then
        export VSLICKXNOPLUSNEWMSG=1
        
        if [ -f /usr/local/share/firefox/firefox ]; then
                export VSLICKHELP_WEB_BROWSER=/usr/local/share/firefox/firefox
        fi
fi

# Quite often, I want to see the last output of less on the screen...
# Stop the default behavior of wiping the screen
export LESS=erX

export GDKUSEXFT=1

# Don't descend into Subversion's admin areas
export GREP_OPTIONS='--exclude=\*.svn\*'

# For use by some of my aliases
export JAVA_LOCALLIB=$HOME/.local/lib/java:$HOME/local/lib/java

# Setup a default classpath so that I don't have to type it all the time
export CLASSPATH=$JAVA_LOCALLIB:/usr/lib/java/lib

# Point X at the truetype fonts... Mac's OS X seems to really want this,
# but it doesn't hurt for Linux either, IIRC
export TTFPATH=/usr/X11/lib/X11/fonts/truetype

export EDITOR=`which vim`

