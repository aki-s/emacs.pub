;;; my_whitespace.el ---                             -*- lexical-binding: t; -*-

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

;; Require (> emacs-major-version 22)

;;; Code:


(eval-when-compile (require 'whitespace))
(setq
 ;;default '(face tabs spaces trailing lines space-before-tab newline indentation empty space-after-tab space-mark tab-mark newline-mark)
 whitespace-style
 '(face tabs empty lines trailing newline indentation space-before-tab space-after-tab tab-mark newline-mark)
 ;; '(face tabs empty lines trailing newline indentation space-mark space-before-tab space-after-tab tab-mark newline-mark)
 ;;default 80
 whitespace-line-column 80
 ;;default 70
 ;; fill-column

 )
(setq whitespace-space-regexp "\\(^ +\\| +$\\)")
;; (global-whitespace-mode)
(setq whitespace-action '(auto-cleanup)) ; action for 'save-buffer.

;;; Show only wide width of spaces
;;(setq whitespace-space-regexp "\\( +\\|\x3000+|\u3000+\\)")

;; (setq whitespace-display-mappings
;;       '((space-mark ?\u3000 [?\u25a1])
;;         ;;$ WARNING: the mapping below has a problem.
;;         ;;$ When a TAB occupies exactly one column, it will display the
;;         ;;$ character ?\xBB at that column followed by a TAB which goes to
;;         ;;$ the next TAB column.
;;         ;;$ If this is a problem for you, please, comment the line below.
;;         ;; (tab-mark ?\t [?\u00BB ?\t] [?\\ ?\t]))
;;       ))
(defun whitespace-display-mappings-original ()
  (interactive)
  (setq whitespace-display-mappings
        '((space-mark 32 ; space
                      [183]
                      [46]) ; dot
          (space-mark 160
                      [164]
                      [95]) ; under score
          (newline-mark 10 ; LF
                        [36 10]) ; [$ LF]
          (tab-mark 9 ; horizontal tab
                    [187 9]
                    [92 9])))
  )

;; ------------------------------------------------
;; 全角スペースなどを可視化
;; ------------------------------------------------

;; ;; font-lock ON!
(global-font-lock-mode t)

;;$00;; (defface my-face-r-1 '((t (:background "gray15"))) nil)
;;$00;; (defvar my-face-r-1 'my-face-r-1)

(defface my-face-b-1 '((t (:background "gray"))) nil)
(defvar my-face-b-1 'my-face-b-1)

;; (defface my-face-b-2 '((t (:background "gray26"))) nil)
(defface my-face-b-2 '((t (:background "orange"))) nil)
(defvar my-face-b-2 'my-face-b-2)

;; (defface my-face-u-1 '((t (:foreground "SteelBlue" :underline t))) nil)
(defface my-face-u-1 '((t (:background "red1"))) nil)
;; ref. whitespace.el:: whitespace-trailing
(defvar my-face-u-1 'my-face-u-1)

(defadvice font-lock-mode (before my-font-lock-mode ())
  (font-lock-add-keywords
   major-mode
   '(
     ("\t" 0 my-face-b-2 append)
     ("　" 0 my-face-b-1 append) ;; Wide-width space
     ("^[ \t]+$" 0 my-face-u-1 append)
;;$00;; ("[ \t]+$" 0 my-face-u-1 append)  ; not working? better use show-trailing-whitespace
;;$00;; ("[ \t]+\'" 0 my-face-u-1 append) ; match not CR/LF, but EOL ?
;;$00;; ("[\r]*\n" 0 my-face-r-1 append)
;;$00;; ("\r\n" 0 my-face-r-1 append)
     )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)

(setq-default show-trailing-whitespace t) ; emacs built-in variable. buffer-local.

(defun my_whitespace-unload-function ()
   ""
   (interactive)
)

(provide 'my_whitespace)
;;; my_whitespace.el ends here
