;;; my_package -- ""

;; Copyright (C) 2013  u

;; Author: u
;; Keywords: lisp, abbrev

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
;; Usage: M-x list-packages
;; ~/.emacs.d/elpa/PACKAGES
;; ref. http://d.hatena.ne.jp/naoya/20130107/1357553140

;;; Code:
(when (< emacs-major-version 24)
  (load-library "my_cl-lib"); provide "cl-lib" for emacs23 to be compatible with emacs24.
  )
(require 'package)
;;;; requires external command gpg
;;; Macports: gnupg21

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(setq package-user-dir (concat user-emacs-directory "elpa"))
(package-initialize)

;;  http://d.hatena.ne.jp/tarao/20130303/evil_intro#20130303f2
(defun package-install-with-refresh (package)
  (unless (assq package package-alist)
    (package-refresh-contents))
  (unless (package-installed-p package)
    (package-install package)))

;;eg. install evil
;;  (package-install-with-refresh 'evil)
;; auto install
(require 'cl)
(defvar installing-package-list
  '(
    ;; package list
    ;;      evil
    ;;      evil-leader
    ;;      evil-numbers
    ;;      evil-nerd-commenter
    ))
(let ((not-installed (loop for x in installing-package-list
                           when (not (package-installed-p x))
                           collect x)))
  (when not-installed
    (package-refresh-contents)
    (dolist (pkg not-installed)
      (package-install pkg))))


;; TBD manage the list of installed elisp automatically
;; ref Pallet sync with Cask

(provide 'my_package)
;;; my_package.el ends here
