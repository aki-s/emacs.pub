##; @TBD : Generate file list to be deleted.

if [ -z "${CONFLOADED}" ];then
    BINDIR0=`dirname $0`
    . ${BINDIR0}/_publish-emacs-conf.sh
fi

CWD=`pwd`

cd $HOME/.emacs.d
git ls-files  | sed 's:[^/]*$::' | uniq >  ${EDIRLST}
git ls-files  > ${EFILELST}.org   
#; Check if BLACKLIST are excluded.
sed -re "/${BLACKLIST}/d" ${EFILELST}.org > ${EFILELST}
echo ".git/modules" >> ${EFILELST}

cd $CWD
