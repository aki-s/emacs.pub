;;; my_emacs-version --- Make safely startup multi version of Emacs
;;; Commentary:
;;; Code:
(defvar my_emacs-main-version-file "~/.emacs-main-version.el" "Your preferred Emacs version info is defined.")
(cond ((file-exists-p my_emacs-main-version-file)
        ;; When multiple version of emacs are installed,
        ;; prevent loading unintended byte-compiled file by setting the flag
        ;; my_emacs-main-version.
        (load-file  my_emacs-main-version-file)
        (message   "%s was loaded" my_emacs-main-version-file))
      ;;;
  (t (with-temp-buffer
       (insert (prin1-to-string `(defvar my-emacs-main-version ,emacs-major-version "My preferred version of emacs")))
       (write-file my_emacs-main-version-file))))

(if (eq emacs-major-version 23) ;; @todo : like `cask' create byte file for each version of Emacs
  (setq load-suffixes '(".el" ".elc"))
  )
(provide 'my_emacs-version)
;;; my_emacs-version ends here
