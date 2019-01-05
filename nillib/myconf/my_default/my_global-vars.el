;;; my_global-vars.el ---

;; Copyright (C) 2014

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

(defvar my_global-startup-time (format-time-string "%d-%m-%Y_%Hh%Mm") "Startup time of Emacs is started.")

(defvar user-emacs-tmp-dir
  (locate-user-emacs-file (concat "tmp/" system-configuration))
  "User specific temporary directory of Emacs.")
(mkdir user-emacs-tmp-dir t)
;;#;;  auto-install
;;#;;  auto-save-list
;;#;;  backup
;;#;;  image-dired
;;#;;	.anything-c-javadoc-classes.cache
;;#;;	.anything-c-javadoc-indexes.cache
;;o;;	ac-comphist.dat
;;#;;	ede-projects.el
;;#;; history
;;#;;	semanticdb/
;;#;;	session.104d7d06bc4e5ff736137551565058894100000038170057
;;#;;	tramp

(provide 'my_global-vars)
;;; my_global-vars.el ends here
