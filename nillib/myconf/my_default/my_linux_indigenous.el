;;; package: --- my_linux_indigenous.el --- gnu/linux
;;; Commentary:

;; Copyright (C) 2013

;; Author:
;; Keywords:

;;; Code:
(when (executable-find "xclip")
  ;;   (defun copy-from-x ()
  ;;     (shell-command-to-string "xclip -o"))
  ;;
  ;;   (defun paste-to-x (text &optional push)
  ;;     (let* (
  ;;      (proc (start-process "xclip" "*Messages*" "xclip" " -i -selection PRIMARY"))
  ;;      (process-connection-type nil))
  ;;       (message "%s" text)
  ;;       (process-send-string proc text)
  ;;       (process-send-eof proc)))
  ;;
  ;;   (setq interprogram-cut-function 'paste-to-x)
  ;;   (setq interprogram-paste-function 'copy-from-x)
  ;;
  (eval-and-compile (require 'xclip))
  (turn-on-xclip)
  )
(setenv "C_INCLUDE_PATH"
        (concat (getenv "$C_INCLUDE_PATH" )
                "/usr/include/X11/")
        )
(provide 'my_linux_indigenous)
;;; my_linux_indigenous.el ends here
