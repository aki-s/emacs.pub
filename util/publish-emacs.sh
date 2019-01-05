#!/bin/sh

# Create public repository

BINDIR=`dirname $0`
CONFLOADED=0 # true 1, false 0
#-------------------------------------
# CONFIG
#-------------------------------------
. ${BINDIR}/_publish-emacs-conf.sh

#-------------------------------------
# defun
#-------------------------------------
. ${BINDIR}/_publish-emacs-defun.sh

#-------------------------------------
# main
#-------------------------------------

check


. ${BINDIR}/_publish-emacs-genlst.sh

. ${BINDIR}/_publish-emacs-git.sh

echo "Exiting $0"
