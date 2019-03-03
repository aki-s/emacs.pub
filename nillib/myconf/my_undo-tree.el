;;; my_undo-tree.el ---                              -*- lexical-binding: t; -*-

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

;; undo-tree-mode-lighter

;;; Code:

(require 'undo-tree)
(setq undo-tree-mode-lighter " UT")
(define-key undo-tree-map (kbd "C-/") nil)
(define-key undo-tree-map (kbd "C-_") nil)

(defun my_undo-tree-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_undo-tree is unloaded."
   (interactive)
)

(provide 'my_undo-tree)
;;; my_undo-tree.el ends here
