;;; package: --- ""
;;; Commentary:
;; http://d.hatena.ne.jp/rubikitch/20090207
;; http://d.hatena.ne.jp/mooz/20100421/p1
;; |モダン hook 入門。 - 日々、とんは語る。 | http://d.hatena.ne.jp/tomoya/20100112/1263298132|

;;; Code:
;; Use Emacs23's eldoc
;; (require 'eldoc)
;; ;; (install-elisp-from-emacswiki "eldoc-extension.el")
;; (require 'eldoc-extension)
;; (setq eldoc-idle-delay 0)
;; (setq eldoc-echo-area-use-multiline-p t)
;; (add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
;; (add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)
;; (add-hook 'ielm-mode-hook 'turn-on-eldoc-mode)

;; [Note]

;;

(eval-and-compile (require 'cl))

(defun my_elisp-mode-hook ()
  "."
  ;;(require 'eldoc nil t)
  (eldoc-mode)
  ;; (auto-install-from-emacswiki "eldoc-extension.el")
  ;;(require 'eldoc-extension nil t)
  (require 'eldoc-extension)
  ;;(setq-default eldoc-idle-delay 0.2)
  (setq-default eldoc-idle-delay 0.3)
  (setq-default eldoc-echo-area-use-multiline-p t)
  ;; (turn-on-eldoc-mode);; not working
  (require 'my_paren)
  (show-paren-mode 1)
  ;;(setq ecb-layout-name "emacs-lisp"); my custom layout.
  ;;    (defvar ecb-layout-name "emacs-lisp"); my custom layout.
  (setq mode-name "el");
  (unless default-directory (cd "~/.emacs.d/")) ; For gtags to search tag files
  )

(find-function-setup-keys);; jump func definition when in elisp mode
(require 'eldoc)
(setq eldoc-minor-mode-string " eld")
(add-hook 'emacs-lisp-mode-hook 'my_elisp-mode-hook)

(defun my_elisp:reset-eldoc()
  "Apply function  to \"el\" files, which is adding documentation-function."
  (interactive)
  (cl-loop for el-file in (remove-if-not (apply-partially 'string-suffix-p "el")
                         (mapcar 'buffer-name (buffer-list)))
    do (with-current-buffer (set-buffer el-file)
         (add-function :before-until (local 'eldoc-documentation-function)
           #'elisp-eldoc-documentation-function)
         )
    )
  )

(defun toggle-eldoc-mode ()
  "Toggle eldoc mode"
  (interactive)
  (if eldoc-mode
      (setq eldoc-mode nil)
    (setq eldoc-mode 1)
    )
  )

(eval-and-compile
  (require 'lisp-mode)
  (require 'mode-local))

(defun my_elisp-reset_eldoc-documentation-function()
  "Reset to default documentation function when ggtags-eldoc-function or something
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

(eval-after-load 'flycheck
  '(flycheck-package-setup))

(provide 'my_elisp)
;;; my_elisp ends here
