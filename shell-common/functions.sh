function find-project-root
{
    local last_found=$(pwd)
    local tmp_path=$(dirname "$last_found")
    while [[ "$tmp_path" != "/" ]];
    do
        if [ -d "$tmp_path/.svn" ]; then
            last_found="$tmp_path"
        elif [ -e "$tmp_path/.git" -o -d "$tmp_path/.hg" -o -d "$tmp_path/.bzr" ]; then
            last_found="$tmp_path"
            break
        fi
        tmp_path=$(dirname "$tmp_path")
    done
    echo "$last_found"
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

function parse_git_branch {
  declare -F __git_ps1 &>/dev/null && __git_ps1 "[%s]"
  declare -F __git_ps1 &>/dev/null || git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/[\1]/'
}

function pgl {
  pygmentize -f terminal $* | less
}

function md {
    mkdir -p "$*"
    cd "$*"
}
