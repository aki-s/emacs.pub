;;; package --- ;
;;; Commentary:
;;; Code:
(eval-and-compile
  (require 'mode-local)
  (require 'markdown-mode)
  )
(define-key markdown-mode-map (kbd "<tab>") 'markdown-cycle) ;; make work on evil state 'normal.
(if
    (cond
     ( (executable-find markdown-command)
       ;; `markdown' command.
       ;; Homebrew $ brew install markdown
       )
     ( (executable-find "mdown")
      (setq markdown-command "mdown")
      ) ;;github/node.js: sudo npm install gh-markdown-cli -g
     ( (file-exists-p "~/.emacs.d/util/Markdown.pl") ;; Official Markdown: http://daringfireball.net/projects/markdown/ $ perl Markdown.pl --html4tags foo.text
       (setq markdown-command "perl ~/.emacs.d/util/Markdown.pl"))
     );cond

    (progn
      (require 'my_w3m nil t)
      ;; I don't want to use w3m for  markdown-preview
      ;; browse-url in browse-url.el

;;;;<notworking> @TBD make mode-local variable browse-url-browser-function work in markdown-mode
      (defvar-mode-local markdown-mode browse-url-browser-function 'my-external-browser) ;; notwork?
      ;;break-my_w3m.el (setq browse-url-browser-function 'my-external-browser)
      ;;(setq browse-url-browser-function 'browse-url-default-browser)
      (setq-mode-local markdown-mode
                       ;; browse-url-browser-function 'browse-url-default-browser  ; noworking
                       ;; browse-url-browser-function 'browse-url-generic
                       ;; browse-url-generic-program  'choose-browser

                       browse-url-browser-function '(("file:" . my-external-browser)) ; setq-mode-local noworking?
                       )
;;;;</notworking>
      (cond ((eq system-type 'darwin)
            (setq markdown-open-command "open"))
            ((eq system-type 'gnu/linux)
             (setq markdown-open-command "xdg-open")
             )
            )
      )
  (progn
    (t (message "No markdwon-command."))
    )
  );if

;;; my_markdown-mode-markdown-preview
;; browse-url-of-buffer
;; browse-url-of-file
;; browse-url-file-url
;;  browse-url-filename-alist
;; browse-url


(setq-default markdown-hide-urls nil) ; Avoid auto shrink of link.

(provide 'my_markdown-mode)
;;; my_markdown-mode ends here
