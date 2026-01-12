EMACSROOT=$HOME/.emacs.d
find ${EMACSROOT}/ -type f -name '*.el' |xargs etags -a -l lisp -o $EMACSROOT/TAGS
