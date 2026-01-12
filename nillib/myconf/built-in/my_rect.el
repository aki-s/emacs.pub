;;; my_rect.el ---                                   -*- lexical-binding: t; -*-

;; Copyright (C) 2014

;; Author:  Syunsuke Aki
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
(eval-when-compile
  (require 'rect)
  (require 'cl)
  )
(declare-function apply-on-rectangle "rect")
(defvar int-rectangle-format nil "Format of integer to be inserted.")

(setq int-rectangle-format "%2d")

(defun int-rectangle (rBegin rEnd int diff format)
  "Sequencially insert numbers starting from INT, incremented by DIFF in specified FORMAT within the region between RBEGIN and REND.
This function is the alternative of function `cua-sequence-rectangle' to avoid use of function `cua-mode'.
@see function
`string-rectangle'
`cua-sequence-rectangle'"
  (interactive
   (progn (barf-if-buffer-read-only)
          (list
           (region-beginning)
           (region-end)
           (string-to-number (read-string "Begin from: (0) " nil nil "0"))
           (string-to-number (read-string "Increment by: (1) " nil nil "1"))
           (read-string (concat "Format: ( " int-rectangle-format " ) ")
                        nil nil int-rectangle-format)
           )))
  (fset 'iii (make-insert-incremented-int int diff format))
  (goto-char
   (apply-on-rectangle 'iii rBegin rEnd))
  )

(defun make-insert-incremented-int (int diff format)
  "Return function 'insert-incremented-int which have internal variable.
INT, DIFF and FORMAT are arguments for function 'insert-incremented-int."
  (lexical-let ( (n int) (d diff) (f format) )
    (defun insert-incremented-int (startcol &optional endcol &rest args)
      "ENDCOL and ARGS are dummy arguments to accustom to function `apply-on-rectangle'."
      (move-to-column startcol t)
      (insert (format f n))
      (setq n (+ n d))
      )
  ))

(global-set-key (kbd "C-x r N") 'int-rectangle)
;;======================================================================

(defun my_rect-unload-function ()
  "Unload function to ensure normal behavior when feature 'my_rect is unloaded."
  (interactive)
  )

(provide 'my_rect)
;;; my_rect.el ends here
