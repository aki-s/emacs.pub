;;; package --- my_yasnippet
;;; Commentary:

;; emmet is successor of yasnippet?
;; Yasnippet
;;;; grate tutorials
;;  http://fukuyama.co/yasnippet

;;; Code:

(eval-and-compile
  (require 'yasnippet))
(require 'dropdown-list) ;elpa

;; [Call Tree]
;; yas-insert-snippet
;;  yas-expand-snippet
;;   yas--snippet-create
;;   ;; Replace place holder like as `$1' to `yas--active-field-overlay' ?; bug here?
;;    yas--snippet-parse-create
;;     yas--simple-mirror-parse-create
;;      yas-wrap-around-region
;;   yas--snippet-fields ; Get overlay to be modified manually by user.
;;   yas--move-to-field ;

;; [Defs]
;; `yas-selected-text' : text to be `wrapped around`
;;

;; [BUG] wrap-around-region does not work about `over-lay' field.
;; Some fragment of a word is deleted? like as 'Writ' ' File'

(setq-default yas-wrap-around-region t)
(add-hook 'yas-after-exit-snippet-hook 'my_yasnippet-after-exit-snippet)
(defun my_yasnippet-after-exit-snippet ()
  "Automatically indent.
 This hook runs before query & replace macros.
"
  (if (and yas-snippet-beg yas-snippet-end)
    (let ((yas--inhibit-overlay-hooks t))
      (indent-region yas-snippet-beg yas-snippet-end))
    )
  )

(cond
 ( (> emacs-major-version  23 )
   (setq yas-snippet-dirs ; used by yas-recompile-all
         '(
           "~/.emacs.d/share/yas/my_snippet"
           "~/.emacs.d/share/yas/snippets_AndreaCrotti"
           "~/.emacs.d/src/yasnippet.git/css-scss-yasnippet/css-mode"
           "~/.emacs.d/src/yasnippet.git/css-scss-yasnippet/scss-mode"
           "~/.emacs.d/src/yasnippet.git/java-mode/snippets"
           ;;         "~/.emacs.d/share/yas/yasnippet/snippets"
           ))
   ;; 既存スニペットを挿入
   (define-key yas-minor-mode-map (kbd "C-x y i") 'yas-insert-snippet)
   ;; 新規スニペットを作成するバッファを用意する
   (define-key yas-minor-mode-map (kbd "C-x y n") 'yas-new-snippet)
   ;; 既存スニペットの閲覧、編集
   (define-key yas-minor-mode-map (kbd "C-x y v") 'yas-visit-snippet-file)
   (define-key yas-minor-mode-map (kbd "<tab>") 'yas-expand) ;; Still overrided by evil?
   (define-key yas-minor-mode-map (kbd "C-x y <tab>") 'yas-expand)

   (setq yas-trigger-key "TAB") ;; After yasnippet ver8.0, @see. (defcustom yas-fallback-behavior 'call-other-command

   (setq yas-prompt-functions '(
                                yas-completing-prompt
                                yas-ido-prompt
                                yas-dropdown-prompt  ; Don't use yas-x-propmt
                                ))
   )
 ( (<= emacs-major-version 23)
   ;; report "'noerror"
   ;; http://stackoverflow.com/questions/2816019/in-lisp-avoid-cannot-open-load-file-when-using-require
   ;;(require 'yasnippet nil 'noerror)

   (setq yas/prompt-functions '(yas/dropdown-prompt))
   (setq yas/root-directory "~/.emacs.d/share/yas")
   (define-key yas/minor-mode-map (kbd "C-x y i") 'yas/insert-snippet)
;;; init
   (yas/initialize)
   (yas/load-directory yas/root-directory)
   (message "%s was loaded" buffer-file-name)
   )
 )

(yas-global-mode 1)

(provide 'my_yasnippet)
;;; my_yasnippet.el ends here
