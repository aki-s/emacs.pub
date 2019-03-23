;;; my_cedet --- Customize cedet
;;; Commentary:
;;; Code:

;;;;; == about CEDET==
;;$;; CEDET/
;;$;;      +-EDE      : The project system for CEDET,  "Emacs Development Environment".
;;$;;      +-Semantic : The smart completion engine.
;;$;;      +-Cogre    :
;;$;;      +-Speedbar :
;;$;;      +-EIEIO    :
;;$;;      +-Misc Tools:
                                        ;ref. http://www.randomsample.de/cedetdocs/cedet/GNU-Global.html#GNU-Global
;;cedet <- from macports
;;; enable cedet accompanied by emacs23 not from macports
;;(load-library "/opt/local/share/emacs/23.2/lisp/cedet/cedet.elc") ; <- from emacs23
;; ~/.emacs.d/src/emacs/lisp/cedet/cedet.el
(when (locate-library "cedet")
  (require 'eieio nil t)
  ;;; ede must be required before loading semantic-mode
  (require 'ede)
  (if (file-exists-p "~/.emacs.d/src/emacs/lisp/progmodes/autoconf.el" )
    (load-file "~/.emacs.d/src/emacs/lisp/progmodes/autoconf.el")) ; <-was this test?
  (require 'ede/dired)
  ;;(require 'semantic)
  ;;; Currently CEDET issues a warning “Warning: cedet-called-interactively-p called with 0 arguments, but requires 1”, which can be suppressed by adding (setq byte-compile-warnings nil) in your .emacs file before CEDET is loaded
  (setq byte-compile-warnings nil)
  (require 'my_semantic)

  )
(provide 'my_cedet)
;;; my_cedet.el ends here
