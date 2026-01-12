;;=============================================================================
;; http://www.emacswiki.org/cgi-bin/wiki/BrowseUrl#toc7
(require 'browse-url)
;;; Code:
(when (boundp 'user-real-login-name)
;;;; (getenv "$USER") is alternative.
  (add-to-list 'browse-url-filename-alist
    (cons (concat "/Users/" user-real-login-name "/Sites/")
      (concat "http://localhost/~" user-real-login-name))
    )
  )

(unless browse-url-generic-program
  (cond ((executable-find "google-chrome")
          (setq-default browse-url-generic-program "google-chrome")
          )
    )
  )

(defun my-browse-url:external-browser (url &rest args)
  (cond
   ((eq system-type 'darwin) (browse-url-default-macosx-browser url))
   ((member system-type '(windows-nt cygwin))     (browse-url-generic url))
   ((eq system-type 'gnu/linux) (browse-url-generic url))
   (t (message "No matching system-type %s" system-type))
   ))

(provide 'my_browse-url)
;;; my_browse-url ends here
