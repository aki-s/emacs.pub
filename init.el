;;; init.el: --- -*-byte-compile-dynamic: nil;-*-
;;; Commentary:
;;; Code:


;;;; Automatically added by Package.el.
;; Next line must come before configurations of installed packages.
;;(package-initialize) ;  Don't delete this line.

(setq inhibit-startup-message t)

(setq keyboard-coding-system 'utf-8)
(setq terminal-coding-system 'utf-8)
(setq buffer-file-coding-system 'utf-8)

(defadvice called-interactively-p
    (after called-interactively-p-ignore-err last (&optional arg))
  "Defadvice at init.el.  To stay away from error such that \
\" called-interactively-p, 1 progn: End of buffer \"."
   (cond
    ((or (eq arg nil) (eq arg 1) (eq arg t))
     (ignore-errors (called-interactively-p)))
   ))

;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;;; == conf for different window-systems ==
;; locate-user-emacs-file is a compiled Lisp function in `subr.el'
(load (locate-user-emacs-file (concat (prin1-to-string window-system) ".el")))

;;; init.el ends here
(put 'list-timers 'disabled nil)
