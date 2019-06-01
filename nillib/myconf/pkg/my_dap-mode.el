;;; my_dap-mode.el ---                               -*- lexical-binding: t; -*-

;; Copyright (C) 2019

;; Author:  <>
;; Maintainer:
;; URL:
;; Package-Version: 0.0.0
;; Package-Requires:
;; Keywords:
;; Created: 2019-05-29
;; Updated: 2019-05-29T13:51:59Z; # UTC

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
  :config
  (define-key dap-mode-map (kbd "<f7>") #'dap-step-in)
  (define-key dap-mode-map (kbd "<S-f8>") #'dap-step-out)
  (define-key dap-mode-map (kbd "<f8>") #'dap-next)
  (define-key dap-mode-map (kbd "<f9>") #'dap-continue)

  (setq dap-lldb-debugged-program-function
        (lambda ()
          (pcase major-mode
            ((or c-mode c++-mode)
             (file-name-sans-extension (buffer-file-name)))
            (_ (read-file-name "Select target file: ")) )))

  :hook ((c-mode c++-mode objc-mode) . my_c--dap-mode-hook))
;;------------------------------------------------
;; Unload function:

(defun my_dap-mode-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_dap-mode is unloaded."
   (interactive)
)

(provide 'my_dap-mode)
;;; my_dap-mode.el ends here

;; Local variables:
;; eval: (add-hook 'write-file-functions 'time-stamp)
;; time-stamp-start: ";; Updated:"
;; time-stamp-format: " %:y-%02m-%02dT%02H:%02M:%02SZ"
;; time-stamp-line-limit: 13
;; time-stamp-time-zone: "UTC"
;; time-stamp-end: "; # UTC"
;; End:
