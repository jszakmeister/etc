PATHS_TO_PREPEND=
PATHS_TO_APPEND=

__etc_prepend_path()
{
    test -d "$1" && PATHS_TO_PREPEND=$(append_path "$PATHS_TO_PREPEND" "$1")
}

__etc_append_path()
{
    test -d "$1" && PATHS_TO_APPEND=$(append_path "$PATHS_TO_APPEND" "$1")
}

__etc_prepend_search_paths()
{
    __etc_prepend_path "$1/$platform"
    __etc_prepend_path "$1/all"
}

if [ -x /usr/libexec/path_helper ]; then
    PATH=""
    eval $(/usr/libexec/path_helper -s)
fi

__etc_prepend_path "$HOME/bin"
__etc_prepend_path "$HOME/.local/bin"
__etc_prepend_path "$HOME/local/bin"

# Support Rust's ~/.cargo/bin.
__etc_prepend_path "$HOME/.cargo/bin"

# Put user script directories on the path.
__etc_prepend_search_paths "$ETC_LOCAL_DIR/scripts"
__etc_prepend_search_paths "$ETC_USER_DIR/scripts"
__etc_prepend_search_paths "$ETC_HOME/user/$ETC_USER/scripts"

__etc_prepend_path "$ETC_HOME/git-addons"
__etc_prepend_search_paths "$ETC_HOME/scripts"

if [ "$platform" = 'darwin' ]; then
    _update_python_paths()
    {
        local python_bin="$1"
        local python_version=$("$python_bin" -c "import sys; print '%d.%d' % sys.version_info[:2]" 2>/dev/null ||
                               "$python_bin" -c "import sys; print('{}.{}'.format(*sys.version_info[:2]))" 2>/dev/null)
        local library_path="/Library/Python/$python_version/bin"
        local library_fw_path="/Library/Frameworks/Python.framework/Versions/$python_version/bin"
        local system_path="/System/Library/Frameworks/Python.framework/Versions/$python_version/bin"
        local user_path="$("$python_bin" -m site --user-base)/bin"

        __etc_prepend_path "$user_path"
        __etc_append_path "$library_path"
        __etc_append_path "$library_fw_path"
        __etc_append_path "$system_path"
    }

    # Prefer MacVim over system Vim.
    if [ -d /Applications/MacVim.app/Contents/bin ]
    then
        __etc_prepend_path /Applications/MacVim.app/Contents/bin
    fi

    # To get features of a newer unzip executable, if Homebrew is installed.
    __etc_prepend_path "/usr/local/opt/unzip/bin"

    # We compute the path to the standard framework area in the user's area
    # because site.USER_SITE lies in Python 2.6 and less (it points to the posix
    # user's location, which should be picked up by adding ~/.local/bin to the
    # path).  So we compute it manually.  Also, we do a bit of a dance to cope
    # with Python 3 being the default python implementation.
    if _has_executable python3; then
        _update_python_paths python3
    fi
    if _has_executable python; then
        _update_python_paths python
    fi

    __etc_append_path /opt/local/bin
    __etc_append_path "/usr/local/texlive/2009/bin/universal-darwin"

    __etc_prepend_path /usr/local/git/bin
    __etc_prepend_path "$HOME/Library/Haskell/bin"
fi

# Put ccache links on the path, if they're available.
__etc_prepend_path /opt/homebrew/opt/ccache/libexec
__etc_prepend_path /opt/homebrew/lib/ccache
__etc_prepend_path /usr/local/opt/ccache/libexec
__etc_prepend_path /usr/local/lib/ccache
__etc_prepend_path /usr/lib/ccache

# Homebrew
__etc_prepend_path /opt/homebrew/bin

# It turns out there are some brain-dead apps out there that expect /usr/bin to
# come before /usr/sbin, like mock.
__etc_prepend_path /usr/local/bin
__etc_prepend_path /usr/bin
__etc_prepend_path /bin
__etc_prepend_path /usr/local/sbin
__etc_prepend_path /usr/sbin
__etc_prepend_path /sbin

if [ "$PATHS_TO_PREPEND" != '' ]; then
    export PATH=$PATHS_TO_PREPEND:$PATH
fi

if [ "$PATHS_TO_APPEND" != '' ]; then
    export PATH=$PATH:$PATHS_TO_APPEND
fi

# Set term if we're running under tmux.
test -n "$TMUX" && export TERM="screen-256color"

# A few times I've run into the locale not being set correctly...
# So fix that.  This also fixes an issue with ZSH and RPS1 containing
# a UTF-8 character.  When ssh'ing into a box, if the locale wasn't
# UTF-8 compatible, it would mess up the prompt.
export LANG="en_US.UTF-8"

# Quite often, I want to see the last output of less on the screen...
# Stop the default behavior of wiping the screen
# e - exit at the end of the file
# F - Quit automatically if there is only one screen worth of data
# R - Only show ANSI raw characters.  Allows color to work, while still
#     maintaining the format of the screen.
# X - Stop termcap init and deinit.  It tends to clear the screen, and I
#     don't like that.
export LESS=eFRX

export GDKUSEXFT=1

# Point X at the truetype fonts... Mac's OS X seems to really want this,
# but it doesn't hurt for Linux either, IIRC
export TTFPATH=/usr/X11/lib/X11/fonts/truetype

export EDITOR=$(_find_executable vim)

# Add a default LS_COLORS
if [ "$TERM" != "dumb" -a "$TERM" != "cygwin" ]; then
  if [ -x /usr/bin/dircolors ]; then
      eval "$(dircolors -b)"
  else
      LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:';
      export LS_COLORS
  fi
fi

if [ "$platform" == "darwin" -o "$platform" == "linux" ]; then
    if [ -e "$ETC_HOME/python/startup.py" ]; then
        export PYTHONSTARTUP="$ETC_HOME/python/startup.py"
    fi
fi

# Ignore duplicate entries, and the exit command.
export HISTIGNORE="&:exit"

# Turn on colors for minicom.
export MINICOM='-c on'

# Setup up TMPDIR correctly when SSH'd into your machine.
if [ "$platform" = "darwin" ]; then
    # SSH sessions don't have this properly set.  As a result, you can't connect
    # to tmux instances started in a local shell.  This resolves that issue.
    test -z "$TMPDIR" &&
        export TMPDIR=$(getconf DARWIN_USER_TEMP_DIR)
fi

# Setup less as the default pager.
export PAGER=less
