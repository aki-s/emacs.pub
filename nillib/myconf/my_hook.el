;;;; package --- hook for modes
;;; Commentary:
;;; Central place to use `add-hook' function to XXX-mode-hook for maintainability.
;;;
;;;  Adding (require 'LANG-config-mode) in hook is not bad practice, because
;;; language mode file like as `sql.el' seems to be loaded when Emacs boots, even if related file is not opened.
;;;
;;; Hook function added here should be used for resetting buffer local variable.
;;; So, this file must be loaded at the end of init phase.

;;; Code:

;;;; Prevent barbling derived from keyboard-coding-system and terminal-coding-system.

(add-hook 'server-visit-hook
          (if (eq system-type 'cygwin)
              (> 2 1) ;;;;; suspicious
            (lambda ()
              (set-keyboard-coding-system 'utf-8)
              (set-terminal-coding-system 'utf-8)
              )
            )
          )

;; (defmacro my_hook-generator (name arglist &optional docstring &rest body)
;;   "@dev"
;;   (declare (indent 2))
;;   (fset (intern (concat "my-" name "-hook"))
;;         #'(lambda ()
;;             (require '(intern (concat "my_" name)))
;;             ))
;;   ;;  (require ',lib)
;;   (add-hook (intern (concat name "-hook")) (intern (concat "my-" name "-hook")))
;;   )
;; (my_hook-generator "css-mode" nil)

;;;; Orderr hooks in alphabetically.

(defun my-c-mode-hook ()
  (require 'my_c)
  (my_gtags-update-gtagslibpath)
  )
(add-hook 'c-mode-hook 'my-c-mode-hook t)

(defun my-c++-mode-hook ()
  (require 'my_c)
  (require 'my_c++)
  (my_gtags-update-gtagslibpath)
  (require 'my_gtags) (ggtags-mode t)
  (message "my-c++mode-hook called")
  ;; only c-mode-common-hook is working?
 )
(add-hook 'c++-mode-hook 'my-c++-mode-hook t)

(defun my-dired-mode-hook ()
  (require 'my_dired)
  ;;; (define-key dired-mode-map (kbd "^") (lambda () (interactive) (find-alternate-file ".."))
  )
(add-hook 'dired-mode-hook 'my-dired-mode-hook t)

(defun my-emmet-mode-hook ()
  (require 'my_emmet-mode)
  (emmet-mode 1)
)
(add-hook 'web-mode-hook  'my-emmet-mode-hook t)
;; (add-hook 'sgml-mode-hook 'emmet-mode)
;; (add-hook 'css-mode-hook  'emmet-mode)
(add-hook 'html-mode-hook  'emmet-mode t)

(defun my-elisp-mode-hook ()
  (require 'my_elisp)
  (my_gtags-update-gtagslibpath)
  (eval-when-compile (require 'mode-local) (require 'elisp-mode))
  (setq-mode-local emacs-lisp-mode
    eldoc-documentation-function #'elisp-eldoc-documentation-function)
  ;; (setenv "GTAGSROOT" (expand-file-name "~/.emacs.d/")) ; just switching buffer to the other mode cause error.
  (message "my-elisp-mode-hook was called")
  )
(add-hook 'emacs-lisp-mode-hook 'my-elisp-mode-hook t)

(defun my-java-mode-hook ()
  (require 'my_gtags)
  (my_gtags-update-gtagslibpath)
  (require 'my_java)
  (setq-local imenu-create-index-function #'imenu-default-create-index-function)
  (require 'my_yasnippet)
  (declare-function yas-minor-mode-on "my_yasnippet")
  (yas-minor-mode-on)
  )
(add-hook 'java-mode-hook 'my-java-mode-hook t)

(defun my-js-mode-hook ()
  (require 'my_js)
  ;; xref
  (define-key js-mode-map (kbd "M-.") nil) ; Use xref's keybind.
  (define-key js2-mode-map (kbd "M-.") nil) ; Use xref's keybind.
  (add-hook 'xref-backend-functions #'xref-js2-xref-backend nil t)
  ;; importjs
  (my_import-js:import-js-init)
  (define-key js-mode-map (kbd "M-RET") #'my_import-js:import-js-goto)
  (define-key js2-mode-map (kbd "M-RET") #'my_import-js:import-js-goto)
  ;; imenu
  (js2-imenu-extras-mode t)
  (require 'my_imenu) (my_imenu:js2-setup-imenu)
  ;; Tern
  (require 'my_tern)
  (my_tern:setup)
  ;; Formatter (prettier-js)
  (require 'my_prettier-js)
  (prettier-js-mode)
  (message "my-js-mode-hook was called")
  ;; eslint
  (require 'my_eslint)
  )
(add-hook 'js-mode-hook 'my-js-mode-hook t) ; hook for javascript-mode
(add-hook 'js2-mode-hook 'my-js-mode-hook t) ; hook for javascript-mode

(defun my-markdown-mode-hook ()
  (set (make-local-variable 'whitespace-action) nil))
(add-hook 'markdown-mode-hook 'my-markdown-mode-hook t)

(defun my-org-mode-hook ()
  (require 'my_org-mode)
  )
(add-hook 'org-mode-hook 'my-org-mode-hook t)

(defun my-perl-mode-hook ()
  (require 'my_perl)
  )
(add-hook 'perl-mode-hook 'my-perl-mode-hook t)
(add-hook 'cperl-mode-hook 'my-perl-mode-hook t)

(defun my-python-mode-hook ()
  (require 'my_python)
  (require 'my_gtags) (ggtags-mode t)
  (my_gtags-update-gtagslibpath)
  )
(add-hook 'python-mode-hook 'my-python-mode-hook t)

(defun my-php-mode-hook ()
  (require 'my_php-mode)
  )
(add-hook 'php-mode-hook 'my-php-mode-hook t)


(defun my-R-mode-hook ()
  (require 'my_R)
  )
(add-hook 'R-mode-hook 'my-R-mode-hook t)

(defun my-ruby-mode-hook ()
  (require 'my_ruby)
  (robe-mode)
  (eldoc-mode)
  (my_ruby-prepare-robe-start)
  ;;
  (require 'my_imenu) (my_imenu:ruby-setup-imenu)
  )
(add-hook 'ruby-mode-hook 'my-ruby-mode-hook t)

(defun my-rjsx-mode-hook ()
  "@dev"
  (interactive)
  (message "my-rjsx-mode-hook begein")
  (run-mode-hooks 'my-emmet-mode-hook)
  (message "my-rjsx-mode-hook end")
  )
(add-hook 'rjsx-mode-hook 'my-rjsx-mode-hook)
(add-hook 'js2-jsx-mode-hook 'my-rjsx-mode-hook)

(defun my-scala-mode-hook ()
  (require 'my_scala)
  (ensime-mode 1)
  )
(add-hook 'scala-mode-hook 'my-scala-mode-hook t)

(defun my-scss-mode-hook ()
  (require 'my_scss-mode)
  )
(add-hook 'scss-mode-hook 'my-scss-mode-hook t)

(defun my-sdic-mode-hook ()
  (require 'my_migemo)
)
(add-hook 'sdic-mode-hook 'my-sdic-mode-hook t)

(defun my-web-mode-hook ()
  (interactive)
  (setq comment-start "<%-- ")
  (setq comment-end   " --%>")
  ;; Formatter (prettier-js)
  (require 'my_prettier-js)
  (my_prettier-js:enable-minor-mode
    '("\\.jsx?\\'" . prettier-js-mode)
    )
  )
(add-hook 'web-mode-hook  'my-web-mode-hook t)

(defun my-xml-mode-hook ()
  (require 'my_yasnippet nil t)
  (require 'my_emmet-mode)
  )
(add-hook 'xml-mode-hook 'my-xml-mode-hook t)

(defun my-yatex-mode-hook()
              (require 'my_yatex))
(add-hook 'yatex-mode-hook 'my-yatex-mode-hook t)

;;;http://stackoverflow.com/questions/5748814/how-does-one-disable-vc-git-in-emacs
;; (remove-hook 'find-file-hooks 'vc-find-file-hook)

(defun my_hook-unload-function ()
  (interactive)
  ;;@TBD
  ;;(remove-hook 'xml-command-hook 'my-xml-mode-hook)
  )

(provide 'my_hook)
;;; my_hook.el ends here
