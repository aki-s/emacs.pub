;;; my_persistent-scratch.el --- elisp               -*- lexical-binding: t; -*-

;; Copyright (C) 2019

;; Author:  <>
;; Package-Version: 0.0.0
;; Package-Requires:
;; Keywords:
;; Created: 2019-01-03

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

(require 'persistent-scratch)
(persistent-scratch-setup-default)
(require 'my_files)
(setq persistent-scratch-backup-directory my_files--backupdir)
;;------------------------------------------------
;; Unload function:

(defun my_persistent-scratch-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_persistent-scratch is unloaded."
   (interactive)
)

(provide 'my_persistent-scratch)
;;; my_persistent-scratch.el ends here
