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

(provide 'my_browse-url)
;;; my_browse-url ends here
