;;; my_company.el ---                                -*- lexical-binding: t; -*-

;; Copyright (C) 2017

;; Author:  <@>
;; Keywords:

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
(use-package company
  :config
  (setq company-idle-delay 10) ; Make start very slow for quick input.
  (setq company-require-match nil)
  (define-key company-active-map (kbd "<tab>") 'company-complete-selection)
  (define-key company-active-map (kbd "C-s") 'company-filter-candidates)
  (make-variable-buffer-local 'company-backends)
  (put 'company-backends 'permanent-local t)
  (delq 'company-semantic company-backends) ; For performance.
  (global-company-mode 1)
  (global-set-key (kbd "C-S-o") 'company-complete)
  (use-package company-flx
    :config (company-flx-mode +1))
  )

(use-package company-quickhelp
  :disabled
  :config
  (defun my_company-quickhelp-toggle()
    "Show or hide pop up shown by `company-quickhelp'.
Under implementation. Don't work as expected.
"
    (interactive)
    (message "%S[%s=>%s]" this-command my_company-quickhelp-on
             (not my_company-quickhelp-on))
    (when my_company-quickhelp-on
      (message "hide %S" company-pseudo-tooltip-overlay)
      ;; (company-quickhelp--hide) ; hide pos-tip
      (company-quickhelp--disable)
      (company-quickhelp-local-mode -1)
      )
    (unless my_company-quickhelp-on
      (message "begin")
      (company-quickhelp-local-mode 1)
      (company-quickhelp-manual-begin)
      )
    (setq my_company-quickhelp-on (not my_company-quickhelp-on))
    )
  (setq company-quickhelp-delay 100)
  (define-key company-active-map (kbd "C-h") #'my_company-quickhelp-toggle)
  (company-quickhelp-local-mode)
  )

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package company-c-headers
  :after cc-mode
  :config
  (defun my_company_company-c-headers-hook()
    (add-to-list 'company-backends 'company-c-headers))
  )

(require 'company-lsp)
(push 'company-lsp company-backends)

;;; Code:

;;------------------------------------------------
;; Unload function:

(defun my_company-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_company is unloaded."
   (interactive)
)

(provide 'my_company)
;;; my_company.el ends here
