;;; my_autoload.el --- 

;; Copyright (C) 2014  
;; ------------------------------------------------
;; ------------------------------------------------

;;; Code:

(eval-when-compile 
  (require 'cl) ; eval-when
  )
;; @ref eval-after-load adds entry to after-load-alist 

(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(autoload 'my_ecb "my_ecb" "activate customized ecb" t)
(autoload 'w3m-goto-url-new-session "my_w3m" "activate customized w3m" t)
(autoload 'browse-url "my_w3m" "activate customized w3m" t) ; cclookup
(eval-after-load "browse-url" (load-library "my_w3m") )
(autoload 'my_gtags "my_gtags" "activate customized gtags" t)

(cond 
 ((> emacs-major-version 23)
  (autoload 'js2-mode "js2-mode" "activate customized js" t)
  (autoload 'js2-minor-mode "js2-mode" "activate customized js" t)
  )
 )

;;(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
;;(autoload 'vline-mode "vline" "highlight column vertically" t)
(eval-after-load "term" (load-library "term+") )

;;disable-for-publish (cond
;;disable-for-publish  ;;( (and (= emacs-major-version 23) (> emacs-minor-version 1))
;;disable-for-publish  ( (= emacs-major-version 23) ;; tried to enable js2-mode in emacs23 but failed.
;;disable-for-publish    (autoload 'prog-mode "~/.emacs.d/src/emacs/lisp/progmodes/prog-mode.el" "for emacs version 23" t)
;;disable-for-publish    (defvar lexical-binding nil "for subr.el of emacs24 ")
;;disable-for-publish    ;;(defadvice eval (before eval23 first (form &optional lexical) activate)
;;disable-for-publish    (defadvice eval (before eval23 first (form &optional lexical) activate)
;;disable-for-publish      "arg 1 is flag if you use lexical bindings."
;;disable-for-publish      )
;;disable-for-publish    (defadvice backtrace-frame (before backtrace-frame23 first (nframes &optional base) activate)
;;disable-for-publish      "arg 1 is ..."
;;disable-for-publish      )
;;disable-for-publish    (autoload 'set-advertised-calling-convention "~/.emacs.d/src/emacs/lisp/emacs-lisp/byte-run.el" "for subr.el of emacs24" t)
;;disable-for-publish    (autoload 'pcase "~/.emacs.d/src/emacs/lisp/emacs-lisp/pcase.el" "for macro pcase" t)
;;disable-for-publish    (autoload 'macroexp-let2 "~/.emacs.d/src/emacs/lisp/emacs-lisp/macroexp.el" "for macro macroexp-let2" t) ;; load-with-code-conversion: Invalid read syntax: ". in wrong context"
;;disable-for-publish    (autoload 'define-error "~/.emacs.d/src/emacs/lisp/subr.el" "for emacs version 23" t)
;;disable-for-publish    (autoload 'js-mode "~/.emacs.d/src/emacs/lisp/progmodes/js.el" "for emacs version 23" t)
;;disable-for-publish    )
;;disable-for-publish )

(provide 'my_autoload)
;;; my_autoload.el ends here
