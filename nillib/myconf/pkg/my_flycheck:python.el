;;; my_flycheck:python.el --- flycheck checker for python  -*- lexical-binding: t; -*-

;; Copyright (C) 2016

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

;; Checker for python is sufficient with python-flake8 using `flake8'.
;; [Install] $ pip install flake8 flake8-import-order
;; [Customize] # Edit "~/.flake8rc"

;;; Code:
(eval-when-compile
  (require 'flycheck)
  (require 'python))

(declare-function flycheck-define-command-checker "flycheck")
(setq flycheck-flake8rc "~/.flake8rc")

(eval-and-compile (require 'mode-local))
(setq-mode-local python-mode flycheck-checker 'python-flake8)

;;;

(flycheck-define-checker my_flycheck:python-import-order
  "Python: check import order.
[setup] $ pip install import-order
"
  :modes python-mode
  :command ("import-order" "--only-file" source)
  ;; import-order outputs color code.
  :error-patterns ((warning "[35m" (file-name) "[39m:" line "-" (1+ (in "0-9")) ":" (message) line-end))
  :next-checkers (python-pylint)
  )
(add-to-list 'flycheck-checkers 'my_flycheck:python-import-order)

(flycheck-define-checker my_flycheck:python
  "Python: start chain of checkers."
  :modes python-mode
  :command ("echo" "DUMMY") ; Dummy executable
  :error-patterns ((error "NOERROR"))
  :next-checkers (my_flycheck:python-import-order)
  )
(add-to-list 'flycheck-checkers 'my_flycheck:python)

;;------------------------------------------------
;; Unload function:

(defun my_flycheck:python-unload-function ()
  "Unload function to ensure normal behavior when feature 'my_flycheck:python is unloaded."
  (interactive)
  )

(provide 'my_flycheck:python)
;;; my_flycheck:python.el ends here
