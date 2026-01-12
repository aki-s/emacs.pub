;;; my_projectile.el ---                             -*- lexical-binding: t; -*-

;; Copyright (C) 2020

;; Author:  <>
;; Maintainer:
;; URL:
;; Package-Version: 0.0.0
;; Package-Requires: ((emacs "29.1"))
;; Keywords: lisp
;; Created: 2020-12-30
;; Updated: 2026-01-12T08:00:54Z; # UTC

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
(use-package projectile
  :init
  (require 'cl-lib)
  :config
  (defun my_projectile_switch-project-action()
    (interactive "P")
    ;; Just open project root.
    (dired default-directory)
    (projectile-find-file)
    ;; Make explicit switching of project assign explict-name to the tab.
    (when tab-bar-mode
      (let* ((tabs (frame-parameter (window-frame) 'tabs))
             (tab (assq 'current-tab tabs)))
        (setf
         (alist-get 'name tab)
         (format "🅿️%s🅱️%s"
                 (projectile-project-name (projectile-project-root default-directory))
                 (current-buffer)))
        (setf (alist-get 'explicit-name tab) t))
      )
    )
  (setq projectile-switch-project-action #'my_projectile_switch-project-action)
  (when (locate-library "helm")
    (setq projectile-completion-system 'helm))
;; F: (projectile-discover-projects-in-search-path)
  (setq projectile-project-search-path (list '("~/git.d/github.com" . 2)))

  (setq my_projectile-project-root-fallback-list
        (list
         ".tool-versions"
         "package.json"
         ".envrc"
         ;; If 2-parent dir-visiting of visiting file matches "~/Documents/jobs/"
         ;; then seen it as a project.
         ;; (e.g. "~/Documents/jobs/yyyy/{kind}/file"
         ;; => "~/Documents/jobs/yyyy/{kind}" ),
         '("~/Documents/jobs/" . 2)
         ))
  (defun my_projectile-parent(file up-cnt)
    (setq up-cnt (or up-cnt 1)
          file (expand-file-name file))
    (while (and (> up-cnt 0) (file-exists-p file))
      (setq up-cnt (1- up-cnt))
      (setq file (file-name-directory (directory-file-name file))))
    file)

  (defun my_projectile-root-fallback(file &optional list)
;    (message "[my_projectile-root-fallback] => %s %S" file list)
    (let* ((dir-visiting (expand-file-name (if (directory-name-p file)
                                     file
                                     (file-name-directory file))))
          (res
           (cl-loop for var in my_projectile-project-root-fallback-list
                    for idx from 0
                    do
                    (pcase var
                      ((pred consp)
                       (let* (
                              (dir-pattern (expand-file-name (car var)))
                              (up-cnt (cdr var))
                              (dir-actual (my_projectile-parent dir-visiting up-cnt)))

;    (message "[my_projectile-root-fallback] cons %s %s" dir-pattern dir-actual)
                         (if (and (file-exists-p dir-pattern) (string= dir-pattern dir-actual))
                             (cl-return dir-visiting))))
                      ((pred stringp)
                         (if (file-exists-p (file-name-concat dir-visiting var))
                             (cl-return dir-visiting))
                         )
                       (_ nil))
                    )))
;      (message "[my_projectile-root-fallback] <= %s" res)
      res)
    )
  (defun my_projectile-root-match--2(dir-visiting &optional list)
    "@wip"
;    (message "[my_projectile-root-match--2] %s %S" dir-visiting list)
    nil)

;; F: (projectile-clear-known-projects)
;; F: dired-find-file
;; V: projectile-known-projects-file

  (setq projectile-project-root-functions
        '(
          my_projectile-root-fallback ;; using here causes strage results
          projectile-root-local
          projectile-root-marked
          projectile-root-bottom-up
;;          my_projectile-root-fallback ;; working ?
          projectile-root-top-down
          projectile-root-top-down-recurring
 my_projectile-root-match--2
          ))

  (projectile-mode 1))

;;------------------------------------------------
;; Unload function:

(defun my_projectile-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_projectile is unloaded."
   (interactive))

(provide 'my_projectile)
;;; my_projectile.el ends here

;; Local variables:
;; eval: (add-hook 'write-file-functions 'time-stamp)
;; time-stamp-start: ";; Updated:"
;; time-stamp-format: " %:y-%02m-%02dT%02H:%02M:%02SZ"
;; time-stamp-line-limit: 13
;; time-stamp-time-zone: "UTC"
;; time-stamp-end: "; # UTC"
;; End:
