# Create public repository

#-------------------------------------
# CONFIG
#-------------------------------------
EDIRLST=/tmp/emacs.dir.lst
EFILELST=/tmp/emacs.file.lst
EPUB=$HOME/.emacs.d.pub
## REPOS: list of repository to be published to
REPOS=""
REPOS="$REPOS ssh://git@github.com/aki-s/emacs.pub.git"    # Primary
CPOPT= # Option for `cp` command to copy .emacs.d to ${EPUB}
COMMIT_COMMENT=${COMMIT_COMMENT} # comment for git commit

BLACKLIST="(elnode\/|src\/(cedet|emacs|jdee|maven)|share\/dict\/.*eijirou.*\.sdic|memo\/|\.tar\.(gz|bz2)$|\.zip$|\/\.git\/)"


#-------------------------------------
# body
CONFLOADED=1
set -e  # Prevent unintended push
if [ `set +o pipefail 2>/dev/null`  ];then
 set +o pipefail # failed on Ubuntu bash4.3.11
fi

# echo "Select repository to be published to."
# _index=0
# for i in $REPOS; do
#     echo "${_index} : $i"
#     let _index++
# done
# 
# read _selected;
# echo "${_selected} is selected"
# for i in $REPOS; do
#     if [ "x$i" == "${_selected}" ];then
#         REPOS=$i
#     fi 
# done
