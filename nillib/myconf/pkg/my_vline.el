;;; my_vline.el ---                                  -*- lexical-binding: t; -*-

;; Copyright (C) 2016

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

;;

;;; Code:

;;;==============================================================
;;$;; (vline-mode) (follow-mode) is useful !!
;;$;; col-highlight-mode is useless.
(require 'vline)
(setq
  ;; work on black backgrond
  vline-idle-time 1
  ;; '(vline-visual
  ;;  '((t (:background "cyan")))) ;; color for trancated line
  ;;$;; '(vline-style 'compose)
  ;;$;; '(vline-style 'mixed)
  ;;$;; '(vline-style 'visual)
  vline-visual
  ;;'((t (:background "gray10")))) ;; color for trancated line?
  '((t (:background "cyan"))) ;; color for trancated line
  vline-face
  '((t (:background "navy"))) ;; color for main
  )

;;------------------------------------------------
;; Unload function:

(defun my_vline-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_vline is unloaded."
   (interactive)
)

(provide 'my_vline)
;;; my_vline.el ends here
