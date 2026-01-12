;;;; Utility to mapp between directory tree and 'project'.
;; The 'project' needs project specific emacs configuration.
;; Usefull when used with flymake-mode, gtags-mode,
;; Project list is 

(defvar my_project-dbfile "~/.my_project-dbfile.el")
;;(concat user-emacs-directory "/")

;;;; Impl.
;;; hashmap/assoc/alist

;;;; TODO
;; show current project at mode-line or title-bar.
;; gtags, flymake

(defgroup my_project nil
  ""
  :prefix "my_project-")

(define-minor-mode my_project-minor-mode
  ""
  :global t
  )

(provide 'my_project)
