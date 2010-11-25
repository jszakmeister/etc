have_slickedit=`which vs`
if [[ $have_slickedit != '' ]]; then
        alias vs='vs -new'
fi

$platform=`uname`
if [[ $platform == 'Darwin' ]]; then
        alias twistd="/System/Library/Frameworks/Python.framework/Versions/Current/Extras/bin/twistd"

        alias du='du -h -d1'
        alias scons='scons -u -j`sysctl -n hw.ncpu`'
        alias make='nice -n 3 make -j`sysctl -n hw.ncpu`'
        alias ps='ps -aux'
        slickedit_path=`\ls -d /Applications/SlickEdit* | sort -rn | head -n 1`
        if [[ $slickedit_path != '' ]]; then
                alias vs='open -a /Applications/SlickEdit2007.app'
        fi
        if [ -d $HOME/Applications/0xED.app]
                alias he='open -a ~/Applications/0xED.app'
        fi
        if [ -d /Developer/Applications/Qt/Designer.app ]; then
                alias qtd='open -a /Developer/Applications/Qt/Designer.app'
        fi
fi

if [[ $platform == 'Linux' ]]; then
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

if [ -f $JAVA_LOCALLIB/clojure.jar ]; then
        alias clj="java -XX:+CMSClassUnloadingEnabled -XX:+CMSPermGenSweepingEnabled -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -cp $JAVA_LOCALLIB/jline.jar:$JAVA_LOCALLIB/clojure.jar:$JAVA_LOCALLIB/clojure-contrib.jar jline.ConsoleRunner clojure.main"
fi

if [-d $HOME/projects/clojure ]; then
        alias dev-clj="java -XX:+CMSClassUnloadingEnabled -XX:+CMSPermGenSweepingEnabled -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -cp $JAVA_LOCALLIB/jline.jar:$HOME/projects/clojure/clojure.jar:$HOME/clojure-contrib.jar jline.ConsoleRunner clojure.main"
fi

alias wget="wget --no-check-certificate"

#alias file='file -L'

alias od='od -A x'
alias traceroute='traceroute -n -w 2'
