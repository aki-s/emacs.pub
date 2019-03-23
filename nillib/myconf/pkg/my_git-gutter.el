;;; my_git-gutter.el ---                             -*- lexical-binding: t; -*-

;; Copyright (C) 2015

;; Author:  <@>
;; Keywords: lisp

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

;; git-gutter use `left-margin-width' to display diff.

;;; Code:
(require 'use-package)

(use-package git-gutter
  :after (my_git-gutter)
  :init
  (global-display-line-numbers-mode)
  :config
  ;; If you enable global minor mode
  (global-git-gutter-mode t)
  :bind (("C-x C-g" . git-gutter-mode)
         ("C-x v p" . git-gutter:popup-hunk)
         ;; Jump to next/previous hunk
         ("C-x p" . git-gutter:previous-hunk)
         ("C-x n" . git-gutter:next-hunk)
         ;; Stage current hunk
         ("C-x v s" . git-gutter:stage-hunk)
         ;; Revert current hunk
         ("C-x v r" . git-gutter:revert-hunk))
  :hook
  (git-gutter:update-hooks . focus-in-hook)
  (git-gutter:update-commands . other-window)
  )

;;------------------------------------------------
;; Unload function:

(defun my_git-gutter-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_git-gutter is unloaded."
   (interactive)
)

(provide 'my_git-gutter)
;;; my_git-gutter.el ends here
