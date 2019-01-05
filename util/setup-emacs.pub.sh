#!/bin/sh
#set -e

#----------------------
# def var
#----------------------
EMACS=
EMACSDIR=$HOME/.emacs.d
CASK=
CURL=
GIT=
PYTHON=

SUBMOD="src\/emacs "
SUBMOD=${SUBMOD}"share\/deferred "
SUBMOD=${SUBMOD}"share\/eclim "
SUBMOD=${SUBMOD}"share\/malabar-mode"
SUBMOD=${SUBMOD}

#----------------------
# def func
#----------------------
separate () {
    echo "----------------"
}

setcmd () {
    which $2 >/dev/null
    if [ $? = 0 ];then
        eval $1=$2
        echo $1 is $2
    else
        echo $2 doesn\'t exist
        exit 1
    fi
}

rmOmitOK () {
    echo " # Actually not all of submodule is required to just try a bit."
    echo " # Raw git repo make installation slow and eats disk size."
    echo " # I needed raw git repo for development. I'm sorry for inconvenience ..."
git rm $SUBMOD
    local f=$1
    if [ -e "$f" ];then
        # -i option may not be implemented
        mv $f $f.bak
        for o in $SUBMOD;do
            #  '/(^\[\|$)/{x; /<IF_INCLUDE_THEN_PRINT>/p;d}; H'  # 2014/07/11
            sed -e '$a\\n' $f.bak |\
      sed -n \
                -re  ' {
            /(\[|^[ 	]*$)/ {
                x;
                /'$o'/!p;
                d;
            }
            /^[ 	]*[^\n]+$/{
                H;
            }
        }
        ' >$f
        done
        if [ `diff -B $f $f.bak >/dev/null 2>&1;` ]; then
            mv $f.bak $f
        else
            git commit -a -m"Modified $f by $THIS" # commit change of $f
            git rm --cached `echo $SUBMOD|tr -d '\\\\'`
            git commit -a -m"Modified $f by $THIS"
        fi
    fi
}

checkoutExternal () {
    cd ${EMACSDIR}
    rmOmitOK .gitmodules
    ${GIT} submodule foreach --recursive ${GIT} checkout master
    ${GIT} submodule update --init  # This process should be concurrent
    ${GIT} submodule foreach --recursive ${GIT} submodule update --init  # This process should be concurrent
}

#----------------------
# main
#----------------------
THIS=$0
echo "This process would take c.a. 10 min. with effective network speed of 300 [Kbyte/sec]"

setcmd CURL   curl
setcmd EMACS  emacs
setcmd GIT    git
setcmd PYTHON python

if [ -n "$GIT" ];then
    checkoutExternal
else
    separate
    echo "External libraries required is not installed."
    echo "emacs wouldn't work as expected"
    echo "Plese do the following."
    type checkoutExternal | sed  -e 's:${GIT}:git:g' -re '/(function|echo|(\{|\})[:space:]*|\(\))/d'
    separate
fi

if [ -z "$CASK" -a ! -d $HOME/.cask ];then
    sh -x ${EMACSDIR}/util/setup-cask.sh
fi
$HOME/.cask/bin/cask

echo "Starting byte compile to speed up boot ...."
#; emacs --batch -l ${EMACSDIR}/nil.el -f  '(byte-recompile-directory ' ${EMACSDIR}  ' 0 t)'
emacs   --batch -l ${EMACSDIR}/nillib/my_load-path.el -l ${EMACSDIR}/nillib/myconf/my_cask.el --eval '(byte-recompile-directory ' \"${EMACSDIR}/nillib\" ' 0 t)'

echo "End of " $0
echo "Let's type $EMACS"
