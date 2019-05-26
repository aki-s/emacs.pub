;;; package: --- ""
;;; Commentary:
;; http://d.hatena.ne.jp/rubikitch/20090207
;; http://d.hatena.ne.jp/mooz/20100421/p1
;; |モダン hook 入門。 - 日々、とんは語る。 | http://d.hatena.ne.jp/tomoya/20100112/1263298132|

;;; Code:
(eval-and-compile
  (require 'lisp-mode)
  (require 'mode-local)
  (require 'cl))

(require 'company-elisp)
(defun my_elisp-mode-hook ()
  (eldoc-mode)
  ;; (auto-install-from-emacswiki "eldoc-extension.el")
  ;;(require 'eldoc-extension nil t)
  (require 'eldoc-extension)
  (setq-default eldoc-idle-delay 0.8)
  (setq-default eldoc-echo-area-use-multiline-p t)
  ;; (turn-on-eldoc-mode);; not working
  (require 'my_paren)
  (show-paren-mode 1)
  ;;(setq ecb-layout-name "emacs-lisp"); my custom layout.
  ;;    (defvar ecb-layout-name "emacs-lisp"); my custom layout.
  (setq mode-name "el");
  (unless default-directory (cd "~/.emacs.d/")) ; For gtags to search tag files
  (when (boundp 'company-backends)
    (add-to-list 'company-backends 'company-elisp))
  )

(find-function-setup-keys);; jump func definition when in elisp mode
(add-hook 'emacs-lisp-mode-hook 'my_elisp-mode-hook)

(use-package eldoc
  :config
  (setq eldoc-minor-mode-string " eld")
  (defun toggle-eldoc-mode ()
    "Toggle eldoc mode"
    (interactive)
    (if eldoc-mode
        (setq eldoc-mode nil)
      (setq eldoc-mode 1)))
  (defun my_elisp:reset-eldoc()
    "Apply function  to \"el\" files, which is adding documentation-function."
    (interactive)
    (cl-loop for el-file
             in (remove-if-not (apply-partially 'string-suffix-p "el")
                               (mapcar 'buffer-name (buffer-list)))
             do (with-current-buffer (set-buffer el-file)
                  (add-function :before-until (local 'eldoc-documentation-function)
                                #'elisp-eldoc-documentation-function)
                  )))
  )

(defun my_elisp-reset_eldoc-documentation-function()
  "Reset to default documentation function.
When ggtags-eldoc-function or something
has broken documentation of eldoc."
  (interactive)
  (setq-mode-local emacs-lisp-mode
                   eldoc-documentation-function #'elisp-eldoc-documentation-function)
  )

(defadvice eldoc-print-current-symbol-info (around turn-off-eldoc-if-err last nil activate)
  "Disable eldoc if 'max-lisp-eval-depth error."
  (condition-case err0
      ad-do-it
    (err0
     (progn (setq eldoc-mode nil)
            (message "Turn off eldoc"))
     )
    )
  )

(require 'my_auto-async-byte-compile)
(require 'lispxmp);show evaled lisp var in annotation

;;; If you don't want to compile elisp file automatically,
;;; reffer and add the next line at the headings.
;;;" wyse50.el --- terminal support code for Wyse 50 -*- no-byte-compile: t -*- "
;; common-lisp-indent-function
;; lisp-indent-function

;;;; code reading for emacs itself
(setq source-directory (expand-file-name "~/.emacs.d/src/emacs/src/"))
(when (require 'etags)
  (setq-mode-local emacs-lisp-mode tags-table-list nil))
(push
 (let ( (etagfile (expand-file-name "~/.emacs.d/TAGS"))  )
   (if (file-exists-p etagfile) etagfile nil))
 tags-table-list
 )

(use-package flycheck-package
  :after flycheck
  :config
  (setq flycheck-emacs-lisp-package-user-dir
        (mapconcat #'identity
         (list user-emacs-directory
               ".cask"
               (concat (number-to-string emacs-major-version)
                       "."
                       (number-to-string emacs-minor-version)
                       )
               "elpa")
         "/"))
  (flycheck-package-setup)
  )

(provide 'my_elisp)
;;; my_elisp ends here
