#!/bin/bash

if [ -z "${CONFLOADED}" ];then
  BINDIR0=`dirname $0`
  . ${BINDIR0}/_publish-emacs-conf.sh
fi

CWD=`pwd`

#; Publish only files under version control.
cd $HOME/.emacs.d
git ls-files  | sed 's:[^/]*$::' | uniq >  ${EDIRLST}
git ls-files  > ${EFILELST}.org
#; Exclude BLACKLIST_REGEX
#; Exclude directory of submodule
sed -re "\:${BLACKLIST_REGEX}:d" ${EFILELST}.org \
  | grep -vFxf <(git config --file .gitmodules --name-only --get-regexp path | cut -d '.' -f2) \
         > ${EFILELST}

#; - Create a file list of deleted files.
#; - Prevent files not registered in private repository be published.
(
  find ${EPUB} -type f -printf "%P\n" -o -name .git -prune ;
  #; Assure master data is always seen as duplicated.
  cat $EFILELST;
  cat $EFILELST;
)\
  | sort | uniq -u > ${DELETED_FILE_LST}

cd $CWD
