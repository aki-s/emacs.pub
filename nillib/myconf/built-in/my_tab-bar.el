;;; my_tab-bar.el --- configure tab related packages such as tab-bar-mode -*- lexical-binding: t; -*-

;; Copyright (C) 2026

;; Author:  <>
;; Maintainer:
;; URL:
;; Package-Version: 0.0.0
;; Package-Requires: ((emacs "27.1"))
;; Keywords:
;; Created: 2026-01-07
;; Updated: 2026-01-12T05:10:27Z; # UTC

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

(use-package tab-bar
  :init
  (require 'cl-lib)
  (require 'projectile)
  :config
  (cl-defun my_tab-bar-abbreviate-file-name(name &optional depth)
    "@dev"
    (unless name
      (cl-return-from my_tab-bar-abbreviate-file-name name))
;    (message "[my_tab-bar-abbreviate-file-name] %s %S" name depth)
    (let* ((depth (or depth 3))
           (raw (abbreviate-file-name name))
           (sep "/")
           (parts (split-string raw sep t))
           (len-parts (length parts)))
      (if (>= depth len-parts)
          raw
        (concat "🌈︎" (mapconcat 'identity (seq-subseq parts (- depth len-parts)) sep)))))
  (cl-defun my_tab-bar-tab-name-from-index()
    "Use `explicit-name using 0-indexed number."
    (let* ((tabs (frame-parameter (window-frame) 'tabs))
           (tab (assq 'current-tab tabs)))
      (when tab
        (cl-loop
         for tab2 in tabs
         for i from 1
         thereis
         (when (eq tab tab2)
           (let* ((prj-name (my_tab-bar-abbreviate-file-name (projectile-project-root)))
                 (disp-name (format "🅿️%s🅱️%s" (or prj-name "no-prj") (current-buffer))))
             disp-name))))))

  (setq tab-bar-tab-name-function #'my_tab-bar-tab-name-from-index)
  (setq tab-bar-tab-hints t)

;;  (setq tab-bar-new-tab-choice 'projectile-switch-project)

  (defun my_tab-bar-buffer-groups()
    (interactive)
    (cond
     ((projectile-project-p) (projectile-project-root))
     ((string-match "^\\*[^\\*]+\\*$" (buffer-name)) "*-Emacs-*")
     (t  "no-projectile")))
  (setq tab-bar-new-tab-group 'my_tab-bar-buffer-groups)

  (tab-bar-history-mode 1)
  (tab-bar-mode))

;;------------------------------------------------
;; Unload function:

(defun my_tab-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_tab is unloaded."
   (interactive)
)

(provide 'my_tab-bar)
;;; my_tab.el ends here

;; Local variables:
;; eval: (add-hook 'write-file-functions 'time-stamp)
;; time-stamp-start: ";; Updated:"
;; time-stamp-format: " %:y-%02m-%02dT%02H:%02M:%02SZ"
;; time-stamp-line-limit: 13
;; time-stamp-time-zone: "UTC"
;; time-stamp-end: "; # UTC"
;; End:
