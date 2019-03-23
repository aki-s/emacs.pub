;;; my_go.el ---                                     -*- lexical-binding: t; -*-

;; Copyright (C) 2019

;; Author:  <>
;; Maintainer:
;; URL:
;; Package-Version: 0.0.0
;; Package-Requires:
;; Keywords:
;; Created: 2019-03-05
;; Updated: 2019-03-04T17:31:31Z; # UTC

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
(require 'use-package)
(use-package go-mode
  :config
  (use-package company-go)
  )

(defvar my_go--get-lst
  '("github.com/saibing/bingo"
  "github.com/rogpeppe/godef"
  "github.com/nsf/gocode"
  "github.com/golang/lint/golint"
  "github.com/kisielk/errcheck"))

(defvar my_go--buffer-name " *my_go*")
(defun my_go--setup-log(str)
  (with-current-buffer (get-buffer-create my_go--buffer-name)
    (goto-char (point-max))
    (insert str)))

(defun my_go--setup()
  "Provision packages."
  (interactive)
  (let ((buf (get-buffer-create my_go--buffer-name)))
    (with-current-buffer buf (erase-buffer))
    (display-buffer buf))
  (cl-loop
   for pkg in my_go--get-lst
   do (progn
        (my_go--setup-log (format "Try to install %S\n" pkg))
        (make-process
         :name pkg
         :buffer (get-buffer-create pkg)
         :command `("go" "get" "-u" ,pkg)
         :sentinel #'my_go--setup-sentinel)
        )))

(defun my_go--setup-sentinel(proc event)
  (my_go--setup-log
   (format "%s => %s" (process-name proc) event)))

;;------------------------------------------------
;; Unload function:

(defun my_go-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_go is unloaded."
   (interactive)
)

(provide 'my_go)
;;; my_go.el ends here

;; Local variables:
;; eval: (add-hook 'write-file-functions 'time-stamp)
;; time-stamp-start: ";; Updated:"
;; time-stamp-format: " %:y-%02m-%02dT%02H:%02M:%02SZ"
;; time-stamp-line-limit: 13
;; time-stamp-time-zone: "UTC"
;; time-stamp-end: "; # UTC"
;; End:
