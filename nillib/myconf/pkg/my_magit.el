;; Magit requires at least GNU Emacs 23.2 and Git 1.7.2.5.
(defvar magit-version-supported "1.7.2.5")
(defvar git-version nil)
(defun my_magit-set-git-version ()
  (let ((str (shell-command-to-string "git --version") ))
    (string-match "\\([0-9]\\.\\)+[0-9]" str)
    (setq git-version (substring str (match-beginning 0)(match-end 0) ))
    ))

(defun my_magit-get-git-version ()
  (interactive)
  (unless git-version (my_magit-set-git-version))
  (message "%s" git-version)
  )

(if (and (> emacs-major-version 22) (> emacs-minor-version 1) (string< magit-version-supported git-version ) )
    (progn ;if0
      (require 'magit)
      (setq magit-repo-dirs "~/.emacs.d" )

      (if (string> magit-version-supported git-version )
          (setq magit-git-standard-options (list "--no-pager")))
      )
  (progn
    (message "[INFO] magit is not supported.")
    );else0
  )

(provide 'my_magit)
