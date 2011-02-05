function cdt
{
    local new_dir=`pwd | sed "s|\(.*/projects/[^/]*\).*|\1|"`
    cd $new_dir
}

function find_clj_contrib
{
    local clj_contrib_jar=`ls $HOME/projects/clojure-contrib/modules/standalone/target/standalone-*.jar 2>/dev/null | head -n1`
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

