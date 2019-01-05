
;;; css-mode
;; (install-elisp "http://www.garshol.priv.no/download/software/css-mode/css-mode.el")
(when (require 'css-mode nil t)
  (setq cssm-indent-function #'cssm-c-style-indenter)
  (setq cssm-indent-level 2)
  (setq-default indent-tabs-mode nil)
  (setq cssm-newline-before-closing-bracket t))
