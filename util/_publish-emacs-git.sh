if [ -z "${CONFLOADED}" ];then
    BINDIR0=`dirname $0`
    . ${BINDIR0}/_publish-emacs-conf.sh
fi

CWD=`pwd`
ECHO=echo
if [ `basename $SHELL`="bash" -a ! `uname -s` = "Darwin" ];then
    ECHO="builtin echo -e"
fi

if [ -d "${EPUB}" -a x`cd ${EPUB} 2>/dev/null && git rev-parse --show-toplevel`=x${EPUB} ];then
    cd ${EPUB}
    if [ -e "${EFILELST}" ];then
        ls -l ${EFILELST}
        echo "${EFILELST} exists. rsync to the directory..."
        rsync -av --files-from=${EFILELST} $HOME/.emacs.d/ ${EPUB}
        echo "Delete files listed in ${DELETED_FILE_LST}."
        if [ -s ${DELETED_FILE_LST} ]; then
          cat ${DELETED_FILE_LST} | xargs git rm -rf
        fi
        ${ECHO} "a\n*\nq\n"|git add -i
        git commit -a -m"auto publish. $COMMIT_COMMENT"
        git push -v --progress
    else
        echo "File list \'${EFILELST}\' doesn't exist. Try to create this file."
        ${BINDIR0}/_publish-emacs-genlst.sh
        sh -x $0
    fi
else
    #;; NOTE:
    #;; 1:
    #;; Once the emacs.pub is created at remote server and its the latest, then
    #;; just cloning it is the easiest way...
    #;; If you are creating new repository at remote site, then this script works well
    #;; 2:
    #;; [Setting] Setting tracking info:
    #;;  git branch --set-upstream-to=origin/master master
    #;;  git pull origin -v


    echo "Init ${EPUB}"
    mkdir -p ${EPUB}
    cd ${EPUB}
    git init
    if [ `which git-crypt` ]; then
      if [ -e ~/.ssh/git-crypt.key ];then
        #; When $(git-crypt --version) >= 0.4
        git-crypt unlock ~/.ssh/git-crypt.key || : # Ignore failure.
      fi
    else
        echo "git-crypt doesn't exist. Is this O.K?"
        confirm
    fi
    echo "Copy files from source [~/.emacs.d]..."
    cat ${EDIRLST}  | xargs -P 10 mkdir -p
    #cat ${EFILELST} | while read f; do cp $CPOPT $HOME/.emacs.d/$f ${EPUB}/$f ; done
    cat ${EFILELST} | xargs -P 10 -I'{}' cp $CPOPT $HOME/.emacs.d/'{}' ${EPUB}/'{}'
    echo

    echo "Configure git remote..."
    echo git remote add origin `echo ${REPOS}|awk '{print $1}'`
    git remote add origin `echo ${REPOS}|awk '{print $1}'`
    for REPO in ${REPOS}; do
        echo git remote set-url --add --push origin $REPO
        git remote set-url --add --push origin $REPO
    done
    git config --local user.name aki-s
    git config --local user.email aki-s@dymmy # dummy
    git config --local http.postBuffer 524288000  # only for codebreak?
    ##; If error persists set environmental variables bellow.
    #; export GIT_TRACE_PACKET=1
    #; export GIT_TRACE=1
    #; export GIT_CURL_VERBOSE=1

    echo "Start git add"
    cat ${EFILELST} | xargs git add -f  # parallelization is impossible because of the lock.

    git commit -a -m"init"

    echo "Remotes are "
    git remote -v

    echo "Push the current branch and set the remote as upstream"
    git push -vf --progress -u origin master
fi

cd $CWD
