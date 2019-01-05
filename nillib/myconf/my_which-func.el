(require 'which-func) ;; ~/.emacs.d/src/emacs/lisp/progmodes/which-func.el
;;(setq which-func-modes
;;      ;;;; DONT WORK LIST:
;;      ;;; emacs23
;;      ;; java-mode
;;;;      (append which-func-modes
;;;;              '(cc-mode c++-mode emacs-lisp-mode javascript-mode))
;;;;'(cc-mode c++-mode emacs-lisp-mode javascript-mode))
;;      )
;;;; ref. http://www.gnu.org/software/emacs/manual/html_node/elisp/Attribute-Functions.html
(set-face-attribute 'which-func nil
                    :foreground "yellow")
;;(custom-set-variables
;;For other modes it is disabled.  If this is equal to t,
;;then Which Function mode is enabled in any major mode that supports it."
(setq
 ;;; which-func-mode t ;;  Automatically becomes buffer-local when set in any fashion.
 ;; ref. (which-func-ff-hook)
 which-func-non-auto-modes nil
 which-func-maxout 500000
 which-func-format
 `("["
   (:propertize which-func-current
                local-map ,which-func-keymap
                face which-func
                mouse-face mode-line-highlight
                help-echo "mouse-1: go to beginning\n\
mouse-2: toggle rest visibility\n\
mouse-3: go to end")
   "]")
 )

(defun which-func-mode-on ()
 (interactive)
 (which-func-mode t) ;; Toggle Which Function mode, globally.
)
(which-func-mode-on)
;; under trial ;; (require 'cfm)

;; (custom-set-variables
;;  '(which-func-format )
;; )

(provide 'my_which-func)
;;; my_which-func.el ends here
