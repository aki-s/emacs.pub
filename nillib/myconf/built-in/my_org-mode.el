;;; ref.
;; http://e-arrows.sakura.ne.jp/2010/02/vim-to-emacs.html
;; http://orgmode.org/manual/index.html

;; org-mode
(use-package org
  :defter t
  :config
  (setq org-startup-truncated nil)
  (setq org-return-follows-link t)

  ;;------------------------------------------------------------
  ;; org-todo
  ;;------------------------------------------------------------
  (setq org-use-fast-todo-selection t)
  (setq org-todo-keywords
        '((sequence "TODO(t)" "STARTED(s)" "WAITING(w)" "|" "DONE(x)" "CANCEL(c)")
          (sequence "APPT(a)" "|" "DONE(x)" "CANCEL(c)")))

  ;;------------------------------------------------------------
  ;; org-mobile-{pull,push}
  ;;------------------------------------------------------------
;;;; ref.
  ;; http://blog.yakumo.la/
  ;; http://mobileorg.ncogni.to/doc/getting-started/using-dropbox/
  ;; Set to the location of your Org files on your local system
  ;;(setq org-directory "~/org")
  ;; Set to the name of the file where new notes will be stored
  ;;(setq org-mobile-inbox-for-pull "~/org/flagged.org")
  ;;
  (setq org-mobile-inbox-for-pull "~/Dropbox/ToDo/flagged.org")
  ;; Set to <your Dropbox root directory>/MobileOrg.
  (setq org-mobile-directory "~/Dropbox/MobileOrg")
  (setq org-mobile-files   '(
                             "~/.emacs.d/share/org/agendas.org"
                             "~/.emacs.d/share/org/memo.org"
                             "~/.emacs.d/share/org/todo.org"
                             ))
;;;; ref.
  ;; http://d.hatena.ne.jp/kshimo69/20100511/1273562394

;;;; ref.
  ;; http://pukapukasuru84.blogspot.jp/2011/12/iphone4smobileorg.html
  ;; 同期するファイルを指定する。
  (require 'em-glob)
  (setq org-agenda-files   ;(list
        (if (file-exists-p "~/.emacs.d/memo.job/" )
            (eshell-extended-glob "~/.emacs.d/memo.job/*org")))
  ;;------------------------------------------------------------
  ;; Bind keys
  ;;------------------------------------------------------------
  ;; http://stackoverflow.com/questions/10867199/emacs-in-terminal-meta-arrow-keybindings
  (define-key input-decode-map "\e[1;2A" [S-up] )
  (if (equal "xterm" (tty-type))
      (progn
        (define-key function-key-map "\e[1;9A" [M-up]   )
        (define-key function-key-map "\e[1;9B" [M-down] )
        (define-key function-key-map "\e[1;9C" [M-right])
        (define-key function-key-map "\e[1;9D" [M-left] )
        ;;(define-key function-key-map "\e[1;10A" (kbd "M-S-<up>") )
        ;;(define-key function-key-map "\e[1;10B" [M-down] )
        (define-key function-key-map "\e[1;10C" (kbd "M-S-<right>"))
        (define-key function-key-map "\e[1;10D" (kbd "M-S-<left>"))
        ))

  :bind (:map org-mode-map
         ("\C-cl" . org-store-link)
         ("\C-cc" . org-capture)
         ("\C-ca" . org-agenda)
         )
  )

(provide 'my_org-mode)
