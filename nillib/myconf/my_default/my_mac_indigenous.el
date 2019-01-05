;;; package: --- MacOSX indigenous spec
;;; Commentary:
;;; Code:
;; share clipboard

(defun copy-from-osx ()
  "Copy clipboard from OSX."
;;  (unless (or (getenv "TMUX") (getenv "SCREEN"))
    (shell-command-to-string "pbpaste"))
;;  )

(defun paste-to-osx (text &optional push)
  "Environmental variable LANG must be set properly to avoid illegal characlter before using this function."
;;  (unless (or (getenv "TMUX") (getenv "SCREEN"))
    (let ((process-connection-type nil))
      (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
        (process-send-string proc text)
        (process-send-eof proc))))
;;  )

(setq interprogram-cut-function 'paste-to-osx)
(setq interprogram-paste-function 'copy-from-osx) ; test

(defun copy-visited-files ()
  "Add paths of all opened files to kill ring"
  (interactive)
  (kill-new (mapconcat 'identity
                       (delq nil (mapcar 'buffer-file-name (buffer-list)))
                       "\n"))
  (message "List of files copied to kill ring"))

(provide 'my_mac_indigenous)
;;; my_mac_indigenous ends here
