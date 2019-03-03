;;; my_lsp-mode.el ---                               -*- lexical-binding: t; -*-

;; Copyright (C) 2019

;; Author:  <>
;; Maintainer:
;; URL:
;; Package-Version: 0.0.0
;; Package-Requires:
;; Keywords:
;; Created: 2019-03-02
;; Updated: 2019-03-03T15:15:15Z; # UTC

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

(require 'lsp-mode)
(add-hook 'prog-mode-hook #'lsp)
(add-hook 'lsp-mode-hook 'lsp-ui-mode)

(use-package lsp-ui
  :custom-face (lsp-ui-sideline-global ((t (:background "blue")))))

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
