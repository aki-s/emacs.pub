;; my_linum.el --- adjust linum font size
;;; Commentary:

;;; Note
;; - linum can be unvisible when fringe push it aside.
;; - linum on Emacs25.2.2 doesn't require tweak of linum's fontsize?

;;; Code:

(cond ((>= emacs-major-version 26)
  (setq-default display-line-numbers t))
  (t
    (require 'linum)

    (defcustom my_linum-disabled-modes-list
      '(eshell-mode dired-mode org-mode doc-view-mode pdf-view-mode)
      "* List of modes disabled when global linum mode is on"
      :type '(repeat (sexp :tag "Major mode"))
      :tag " Major mode where linum is disabled: "
      :group 'linum
      )

    (defcustom my_linum-disable-starred-buffers 't
      "* Disable buffers that have stars in them like *Gnu Emacs*"
      :type 'boolean
      :group 'linum)

    (defun linum-on ()
      "Overwrite original function linum-on."
      (unless (or (minibufferp) (member major-mode my_linum-disabled-modes-list )
                (and my_linum-disable-starred-buffers (string-match "*" (buffer-name))))
        (linum-mode 1)))


    ;;------------------------------------------------------------------------------
    ;; main
    ;;------------------------------------------------------------------------------
    (eval-after-load "linum"
      '(set-face-attribute 'linum nil :height 90))

    (global-linum-mode 1)
    ))

(provide 'my_linum)
;;; my_linum.el ends here
