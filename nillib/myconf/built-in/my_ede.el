;;; my_ede.el ---

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

;; EDE (Emacs Development Environment) mode.

;;; Code:

(require 'ede)
(require 'my_global-vars)
(setq ede-project-placeholder-cache-file (concat user-emacs-tmp-dir "/ede-projects.el"))
(global-ede-mode 1) ;; EDE only manages Makefile and Automake? @see `ede-new'

;;; --------------------------------------------------------------------------------
;;; The following lines are nothing completed. (as of 2017/01/04)
;;; --------------------------------------------------------------------------------

;; http://www.gnu.org/software/emacs/manual/html_mono/ede.html

(defvar my_ede:root-flags nil)
(defvar my_ede:root-flags-generic '(".git" "README"))
(defvar my_ede:root-flags-java (append
                             "pom.xml"
                             my_ede:root-flags))
(defvar my_ede:root-flags-eclipse '(".project" ".classpath"))

(defun my_basic_func:locate-root ()
  "@dev
Return estimated project root."
  (interactive)
  (locate-dominating-file "." ".git")
  (defvar my_ede:root nil)
  (make-variable-buffer-local my_ede:root)
  (while my_ede:root
    (let ((last-directory default-directory))
      (if (string-match "\\(\/src\/\\|\/include\/\\)$" default-directory)
          (cd (replace-regexp-in-string "\\(\/src\/\\|\/include\/\\)$" "/" default-directory)))
      (cd last-directory)
      (setq my_ede:root last-directory)
      )
    )
  my_ede:root)

(defun visit-project-root (root)
  (cd root)
  )

(provide 'my_ede)
;;; my_ede.el ends here
