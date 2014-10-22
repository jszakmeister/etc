function find-project-root
{
    local last_found=$(pwd)
    local tmp_path=$(dirname "$last_found")
    while [[ "$tmp_path" != "/" ]];
    do
        if [ -e "$tmp_path/.git" -o -d "$tmp_path/.hg" -o -d "$tmp_path/.bzr" -o -f "$tmp_path/.cdt-stop" ]; then
            last_found="$tmp_path"
            break
        elif [ -d "$tmp_path/.svn" ]; then
            last_found="$tmp_path"
        fi
        tmp_path=$(dirname "$tmp_path")
    done
    echo "$last_found"
}

function search-up-tree
{
    local tmp_path="$(pwd)"
    while [[ "$tmp_path" != "/" ]];
    do
        for file in "$@"
        do
            if [ -e "$tmp_path/$file" ]; then
                echo "$tmp_path/$file"
                return
            fi
        done

        tmp_path="$(dirname "$tmp_path")"
    done
}

function cdt
{
    local project_root=$(find-project-root)
    if [ -n "$1" ]; then
        cd "$project_root/$1"
    else
        cd "$project_root"
    fi
}

function find_clj_contrib
{
    local clj_contrib_jar=$(ls $HOME/projects/clojure-contrib/modules/standalone/target/standalone-*.jar 2>/dev/null | head -n1)
    if [[ "$clj_contrib_jar" != '' ]]; then
        echo $clj_contrib_jar
    else
        echo standalone.jar
    fi
}

function parse_git_branch
{
  declare -F __git_ps1 &>/dev/null && __git_ps1 "[%s]"
  declare -F __git_ps1 &>/dev/null ||
      git branch --no-color 2> /dev/null | \
      sed -e '/^[^*]/d' -e 's/* \(.*\)/[\1]/'
}

function pgl
{
  pygmentize -f terminal "$@" | less
}

function md
{
    mkdir -p "$1"
    cd "$1"
}

function gdb
{
    local gdb_path=$(_find_executable gdb)
    if "$gdb_path" 2>&1 --version | head -n 1 | grep "Apple version" > /dev/null; then
        "$gdb_path" -x "$ETC_HOME/gdb/darwin.gdb" "$@"
    else
        "$gdb_path" -x "$ETC_HOME/gdb/default.gdb" "$@"
    fi
}

# Some git-related setup for completion.

if _has_executable git; then
    if _has_executable git-ffwd; then
        _git_ffwd ()
        {
            __gitcomp_nl "$(__git_remotes)"
        }
    fi

    if _has_executable git-ff || \
            git config --get alias.ff > /dev/null 2>&1; then
        _git_ff ()
        {
            __gitcomp_nl "$(__git_refs)"
        }
    fi

    if _has_executable git-missing; then
        _git_missing ()
        {
            __gitcomp_nl "$(__git_refs)"
        }
    fi
fi

# For clang when running under pip and tox.  This is to help prevent errors from
# unused arguments, and to prevent accidentally selecting gcc when ccache is
# installed, but gcc is not.
[ "$platform" != 'darwin' ] && true || xcode-select -p > /dev/null 2>&1

[ $? -eq 0 ] && cc --version 2>&1 | grep clang > /dev/null 2>&1 && {
    pip() {
        CC=clang CFLAGS=-Qunused-arguments CPPFLAGS=-Qunused-arguments \
            $(_find_executable pip) "$@"
    }

    tox() {
        CC=clang CFLAGS=-Qunused-arguments CPPFLAGS=-Qunused-arguments \
            $(_find_executable tox) "$@"
    }
}
