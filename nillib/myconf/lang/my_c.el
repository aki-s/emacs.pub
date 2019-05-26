;;; package: --- my_c.el
;;; Commentary:
;;; Code:
(require 'use-package)
;; LSP
(use-package ccls
;  :custom (ccls-executable "/usr/local/bin/ccls")
  :preface
  (defun my_c--ccls-hook()
    (require 'ccls)
    (lsp))
  :custom
  (ccls-args '("--log-file=/tmp/ccls.log" "-v=1"))
  :hook ((c-mode c++-mode objc-mode) . my_c--ccls-hook))

(use-package cquery
  :disabled ; Use ccls.
  :custom (cquery-executable
           (or
            (executable-find "cquery")
            (concat (getenv "HOME") "/local/bin/cquery")))
  :preface
  (defun my_c--cquery-hook()
    (require 'cquery)
    (lsp))
  :hook ((c-mode c++-mode objc-mode) .
         my_c--cquery-hook))
(use-package dap-mode
  :custom
  ;(dap-print-io t)
  (dap-print-io nil) ; default
  (dap-inhibit-io nil)
  :preface
  (defun my_c--dap-mode-hook()
    (require 'dap-lldb)
    (dap-mode 1)
    (dap-ui-mode 1)
    )
  :hook ((c-mode c++-mode objc-mode) . my_c--dap-mode-hook))

;;; compile command
;;  M-h v compile-command
(defun my-c-compile-command ()
  (unless (or (file-exists-p "makefile")
              (file-exists-p "Makefile"))
    (set (make-local-variable 'compile-command)
         (concat "clang -o "
                 (file-name-sans-extension (file-name-nondirectory (buffer-file-name)))
                 " "
                 (file-name-nondirectory (buffer-file-name))
                 ))))

(add-hook 'c-mode-hook 'my-c-compile-command)

;;;; useful
(require 'google-c-style) ;; set of configs to override properties
(add-hook 'c-mode-common-hook 'google-set-c-style)
(add-hook 'c-mode-common-hook 'google-make-newline-indent)

(defun my-c-mode-common-hook ()
  (require 'hideshow)
  (hs-minor-mode 1)

  (require 'my_company)
  (company-mode 1)

  (auto-fill-mode 1)
  (modify-syntax-entry ?_ "w")
  (setq truncate-lines 0)
  (local-set-key (kbd "C-c o") 'ff-find-other-file)
  )

(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

;;$;; (c-file-style)
;;$;; (c-toggle-auto-hungry-state 1)
;;$;; (define-key c-mode-base-map "\C-m" 'newline-and-indent)

(eval-when-compile (load-library "ffap"))
(let ((inc-path (getenv "INCLUDE")))
  (if inc-path (setq ffap-c-path (split-string inc-path ":")))); set to use "INCLUDE" for header search path for find-file-at-point

;;test (setq ffap-c-path (ffap-list-env "INCLUDE")
;; find-file-at-point == ffap
;;; ffap-prompter
;;;; ffap-guesser
;;;;; ffap-file-at-point
;;;;;; ffap-string-at-point


(require 'mode-local)
(require 'my_rtags)
(require 'helm-imenu)
(require 'my_imenu)
(require 'my_simple)

(define-mode-local-override my_imenu-jump c-mode (target) "Overridden `my_imenu-jump'"
  (interactive)
  (let ((ret (if target (or (and rtags-enabled
                                 (or (rtags-find-symbol-at-point)
                                     (rtags-find-references-at-point)))
                            (helm-imenu))
               (helm-imenu))))
    (my_imenu--debug-message "my_imenu-jump-c-mode => %S" ret)
    (setq my_simple--current-buffer (current-buffer))
    (setq my_simple--current-point-marker (point-marker))
    )
  )

(require 'clang-format)
(define-key c-mode-map (kbd "C-M-\\") 'clang-format-region)

(provide 'my_c)
;;; my_c.el ends here
