;;; my_lsp-mode.el ---                               -*- lexical-binding: t; -*-

;; Copyright (C) 2019

;; Author:  <>
;; Maintainer:
;; URL:
;; Package-Version: 0.0.0
;; Package-Requires:
;; Keywords:
;; Created: 2019-03-02
;; Updated: 2021-04-10T08:14:14Z; # UTC

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:
(require 'use-package)

(use-package lsp-mode
  :after (my_lsp-mode)
  :hook
  ((prog-mode . lsp)
   (lsp-mode . lsp-ui-mode))
  :bind
  (:map lsp-mode-map ("C-c r" . lsp-rename))
  :custom
  (lsp-eldoc-enable-hover nil) ; Using mini-buffer cause flicker.
  (lsp-enable-symbol-highlighting t)
  (lsp-prefer-flymake nil)
  :config
  (require 'my_dap-mode)
  ;; Use checker named `lsp-ui'.
  (setq-default flycheck-disabled-checkers
                '(c/c++-clang c/c++-cppcheck c/c++-gcc))
  (setq read-process-output-max (* 256 4096)) ; 1mb. ref. `lsp-doctor'
  (use-package lsp-clients
    :config
    ;; Prevent 'clangd only to use 'ccls, because finding header
    ;; has failed.
    (remhash 'clangd lsp-clients)
    )
  (use-package lsp-ui
    :custom-face (lsp-ui-sideline-global ((t (:background "blue"))))
    :custom
    (lsp-ui-doc-use-webkit nil)
    (lsp-ui-doc-use-childframe nil)
    (lsp-ui-doc-delay 0.2)
    :bind (:map lsp-mode-map ("C-c h" . my_lsp-mode--lsp-ui-bulk-toggle))
    :preface
    (defun my_lsp-mode--lsp-ui-bulk-toggle ()
      (interactive)
      (if lsp-ui-doc-mode
          (progn
            (lsp-ui-doc-mode -1)
            (lsp-ui-doc--hide-frame)
            (lsp-ui-sideline-mode -1)
            (message "Disable lsp-ui-doc-mode"))
        (lsp-ui-doc-mode 1)
        (lsp-ui-sideline-mode 1)
        (setq lsp-ui-sideline-show-hover t)
        (lsp-ui-sideline--run)
        (message "Enable lsp-ui-doc-mode")))
    )
  (use-package company-lsp
    :custom
    (company-lsp-cache-candidates 'auto) ;; always use cache
    (company-lsp-async t)
    (company-lsp-enable-recompletion nil))
  )


;;------------------------------------------------
;; Unload function:

(defun my_lsp-mode-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_lsp-mode is unloaded."
   (interactive)
)

(provide 'my_lsp-mode)
;;; my_lsp-mode.el ends here

;; Local variables:
;; eval: (add-hook 'write-file-functions 'time-stamp)
;; time-stamp-start: ";; Updated:"
;; time-stamp-format: " %:y-%02m-%02dT%02H:%02M:%02SZ"
;; time-stamp-line-limit: 13
;; time-stamp-time-zone: "UTC"
;; time-stamp-end: "; # UTC"
;; End:
