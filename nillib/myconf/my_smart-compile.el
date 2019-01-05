;;; my_smart-compile.el ---                          -*- lexical-binding: t; -*-

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

(require 'smart-compile)
;; smart-compile doesn't work if 'compile-command is defined.
(add-to-list 'smart-compile-alist
 '(c++-mode . "clang++ -g %f -o %n")
)


(defun my_smart-compile-unload-function ()
   (interactive)
   ""
)

(provide 'my_smart-compile)
;;; my_smart-compile.el ends here
