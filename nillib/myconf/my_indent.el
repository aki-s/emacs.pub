;;; my_indent.el ---                                 -*- lexical-binding: t; -*-

;; Copyright (C) 2014  

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

;; (defun indent-according-to-mode ()
;; indent-line-function c-indent-line
;; indent-region-function c-indent-region
;; indent-relative 
;; indent-relative-maybe
;; comment-indent-function
;; electric-indent-functions

;;; Code:

;;; Trace
;; c-indent-line-or-region
;; c-indent-region
;; c-indent-command

(eval-when-compile (load-library "cc-mode"))

;;;; indent.el
(defun my_basic_func-stingy-tab ()
  "Set buffer-local variables."
  (interactive)
  (setq indent-tabs-mode nil)
  ;; (setq c-basic-offset 2) ;?
  (setq tab-width 1)
  )

(defun my_basic_func-eclipse-tab ()
  "Set buffer-local variables."
  (interactive)
  (setq indent-tabs-mode t)
  (setq c-basic-offset 4) ; test
  (setq tab-width 4)
  )

(defun my_indent-basic-config ()
  "Set with my taste."
  (interactive)
  (setq-default indent-tabs-mode nil) ; always replace tabs with spaces
  (setq-default tab-width 2)
  )

(defun toggle-indent-tabs-mode()
  "@dev should be find-file-hook"
  (interactive)
  (if indent-tabs-mode
      (progn
        (remove-hook 'find-file-hook 'my_basic_func-eclipse-tab)
        (my_basic_func-stingy-tab)
        (add-hook 'find-file-hook 'my_basic_func-stingy-tab)
        )
    (progn ; eclipse compatible
      (remove-hook 'find-file-hook 'my_basic_func-stingy-tab)
      (my_basic_func-eclipse-tab)
      (add-hook 'find-file-hook 'my_basic_func-eclipse-tab)
      )
    )
  (message "( indent-tabs-mode,tab-width) = (%s,%s)" indent-tabs-mode tab-width)
  )

(defun my_indent-show-config ()
  "Use this function if indentation was broken to check."
  (interactive)
  (message "comment-indent-function           : %s" comment-indent-function)
  (message "c-basic-offset                    : %s" c-basic-offset)
  (message "c-insert-tab-function             : %s" c-insert-tab-function)
  (message "c-special-indent-hook             : %s" c-special-indent-hook)
  (message "c-syntactic-indentation           : %s" c-syntactic-indentation )
  (message "c-syntactic-indentation           : %s" c-syntactic-indentation)
  (message "c-syntactic-indentation-in-macros : %s" c-syntactic-indentation-in-macros)
  (message "c-tab-always-indent               : %s" c-tab-always-indent ) 
  (message "c-tab-always-indent               : %s" c-tab-always-indent)
  (message "electric-indent-functions         : %s" electric-indent-functions)
  (message "fill-prefix                       : %s" fill-prefix)
  (message "indent-tabs-mode                  : %s" indent-tabs-mode)
  (message "indent-line-function              : %s" indent-line-function)
  (message "indent-region-function            : %s" indent-region-function)
  (message "tab-always-indent                 : %s" tab-always-indent)
  (message "tab-width                         : %s" tab-width)

  (pop-to-buffer "*Messages*")
  )

;;;; functions
;;  (message "indent-relative                   : %s" indent-relative)
;;  (message "indent-relative-maybe             : %s" indent-relative-maybe)


;; --------------------------------------------------------

(my_indent-basic-config)
(setq tab-always-indent 'complete) ;test

;; --------------------------------------------------------
(defun my_indent-unload-function ()
   ""
   (interactive)
)

(provide 'my_indent)
;;; my_indent.el ends here
