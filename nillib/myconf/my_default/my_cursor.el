;;; my_cursor.el --- http://emacs-fu.blogspot.jp/2009/12/changing-cursor-color-and-shape.html

;; Copyright (C) 2013 

;; Author:
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

(when nil 
  ;; Change cursor color according to mode; inspired by
  ;; http://www.emacswiki.org/emacs/ChangingCursorDynamically
  (defvar djcb-read-only-color       "gray")
  ;; valid values are t, nil, box, hollow, bar, (bar . WIDTH), hbar,
  ;; (hbar. HEIGHT); see the docs for set-cursor-type

  (defvar djcb-read-only-cursor-type 'hbar)
  (defvar djcb-overwrite-color       "red")
  (defvar djcb-overwrite-cursor-type 'box)
  (defvar djcb-normal-color          "yellow")
  (defvar djcb-normal-cursor-type    'bar)

  (defun djcb-set-cursor-according-to-mode ()
    "change cursor color and type according to some minor modes."

    (cond
     (buffer-read-only
      (set-cursor-color djcb-read-only-color)
      (setq cursor-type djcb-read-only-cursor-type))
     (overwrite-mode
      (set-cursor-color djcb-overwrite-color)
      (setq cursor-type djcb-overwrite-cursor-type))
     (t 
      (set-cursor-color djcb-normal-color)
      (setq cursor-type djcb-normal-cursor-type))))

  (add-hook 'post-command-hook 'djcb-set-cursor-according-to-mode)

  ); when

(provide 'my_cursor)
;;; my_cursor.el ends here
