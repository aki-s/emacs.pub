;;; my_editorconfig.el ---                           -*- lexical-binding: t; -*-

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

;;; Code:
(require 'editorconfig)

(unless (executable-find editorconfig-exec-path)
  (message "[WARN] No command named 'editorconfig found.")
  )
(defvar my_editorconfig-user-specific-conf-file  "~/.editorconfig")
(unless (file-exists-p my_editorconfig-user-specific-conf-file)
   (message "[WARN] No config file \"%s\" found." my_editorconfig-user-specific-conf-file)
 )

;;; Overrides defcustom
(setq editorconfig-exclude-modes
  '(
     ))

;;;
(editorconfig-mode)
;;------------------------------------------------
;; Unload function:

(defun my_editorconfig-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_editorconfig is unloaded."
   (interactive)
)

(provide 'my_editorconfig)
;;; my_editorconfig.el ends here
