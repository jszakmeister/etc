have_slickedit=`which vs`
if [[ '$have_slickedit' != '' ]]; then
        alias vs='vs -new'
fi

platform=`uname`
if [[ "$platform" == 'Darwin' ]]; then
        alias twistd="/System/Library/Frameworks/Python.framework/Versions/Current/Extras/bin/twistd"

        alias du='du -h -d1'
        alias scons='scons -u -j`sysctl -n hw.ncpu`'
        alias make='nice -n 3 make -j`sysctl -n hw.ncpu`'
        alias ps='ps -aux'
        slickedit_path=`\ls -d /Applications/SlickEdit* | sort -rn | head -n 1`
        if [[ $slickedit_path != '' ]]; then
                alias vs='open -a /Applications/SlickEdit2007.app'
        fi
        if [ -d $HOME/Applications/0xED.app ]; then
                alias he='open -a ~/Applications/0xED.app'
        fi
        if [ -d /Developer/Applications/Qt/Designer.app ]; then
                alias qtd='open -a /Developer/Applications/Qt/Designer.app'
        fi
        alias keychain='open -a /Applications/Utilities/Keychain\ Access.app'
fi

if [[ "$platform" == 'Linux' ]]; then
        alias du='du -bh --max-depth=1'
        alias scons='scons -u -j`cat /proc/cpuinfo | grep processor | wc -l`'
        alias make='nice -n 3 make -j`cat /proc/cpuinfo | grep processor | wc -l`'
        alias ps='ps -ef'
fi

alias ls='ls -hFGA'
alias ll='ls -hFlG'

# cd-related
alias mkisofs='mkisofs -iso-level 3 -J -L -r'
alias cdrecord='cdrecord dev=0,0,0 -v driveropts=burnfree'

if [ -d $HOME/projects/subversion ]; then
        alias fsfsverify='$HOME/projects/subversion/contrib/server-side/fsfsverify.py'
fi

alias em=emacs
alias top='top -o cpu'
alias apg='apg -M SNCL -m8 -n1 -t -a0'
alias svnup='svn up `pwd | sed "s|\(.*/projects/[^/]*\).*|\1|"`'

if [ -d $HOME/local/erlang ]; then
        alias erl="$HOME/local/erlang/bin/erl"
        alias erlc="$HOME/local/erlang/bin/erlc"
fi
if [ -d $HOME/.local/erlang ]; then
        alias erl="$HOME/local/erlang/bin/erl"
        alias erlc="$HOME/local/erlang/bin/erlc"
fi

# Hunt down the installed clojure files
search_paths=$(echo $JAVA_LOCALLIB | tr ":" "\n")
clojure_jar=
clojure_contrib_jar=
jline_jar=

for search_path in $search_paths
do
    if [ -f $search_path/clojure.jar ]; then
        clojure_jar="$search_path/clojure.jar"
        clojure_contrib_jar="$search_path/clojure-contrib.jar"
        break
    fi
done

for search_path in $search_paths
do
    if [ -f $search_path/jline.jar ]; then
        jline_jar="$search_path/jline.jar"
        break
    fi
done

if [[ "$clojure_jar" != '' ]]; then
        alias clj="java -XX:+CMSClassUnloadingEnabled -XX:+CMSClassUnloadingEnabled -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -cp $jline_jar:$clojure_jar:$clojure_contrib_jar jline.ConsoleRunner clojure.main"
fi

if [ -d $HOME/projects/clojure ]; then
        alias dev-clj="java -XX:+CMSClassUnloadingEnabled -XX:+CMSClassUnloadingEnabled -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -cp $JAVA_LOCALLIB/jline.jar:$HOME/projects/clojure/clojure.jar:$HOME/projects/clojure-contrib/modules/complete/target/clojure-contrib-*.jar jline.ConsoleRunner clojure.main"
fi

alias wget="wget --no-check-certificate"

#alias file='file -L'

alias od='od -A x'
alias traceroute='traceroute -n -w 2'
alias netcat=nc

