;;; my_scss-mode.el ---                              -*- lexical-binding: t; -*-

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

;; 1. LSP-mode natively provides support of SCSS.
;; 2. `ruby-sass' provides command named `sass' in Ubuntu.

;;; Code:

(require 'scss-mode)

(setq scss-compile-at-save nil)
;; scss-sass-options
(if (file-directory-p "/tmp" )
    (setq scss-output-directory "/tmp")
)

(defun my_scss-mode-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_scss-mode is unloaded."
   (interactive)
)

(provide 'my_scss-mode)
;;; my_scss-mode.el ends here
