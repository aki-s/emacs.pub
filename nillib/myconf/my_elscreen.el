;;; my_elscreen.el ---                               -*- lexical-binding: t; -*-

;; Copyright (C) 2015

;; Author:  <@>
;; Keywords: elisp

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
(require 'elscreen)
;;; Avoid startup error for version '(Revised:  April 11, 2012 by Emanuel Evans).
;;; This may cause `helm-elscreen' not work.
;; (setq elscreen-display-screen-number nil)
(setq elscreen-prefix-key (kbd "C-;"))
(setq elscreen-tab-display-control nil)

(require 'elscreen-separate-buffer-list)
(elscreen-separate-buffer-list-mode)

(require 'my_global-vars)
(require 'elscreen-persist nil t) ; 'elscreen-persist doesn't exist on Elpa.
(setq elscreen-persist-file (concat user-emacs-tmp-dir "/elscreen.lst"))

;;; Configure desktop for elscreen

(defun my_elscreen:start()
  "Start elscreen.
 Start sequence is important to avoid error on calling `elscreen-persist-restore'"
  (interactive)

  (remove-hook 'elscreen-screen-update-hook 'elscreen-mode-line-update) ; Avoid error when `mode-line' is not default.

  (elscreen-start) ; set `elscreen-set-prefix-key'
  (require 'my_desktop) ; This line is actually not required for elscreen?
  (elscreen-persist-mode 1)
  )

(condition-case er
  (my_elscreen:start)
  (error "Failed to start elscreen with error: %s" er))

(require 'elscreen-tab)
(elscreen-tab-mode)
(setq elscreen-tab:debug-flag t)


(defvar my_elscreen:debug nil "Show messages related to elscreen if t.")
(if my_elscreen:debug
  (progn
    (defadvice elscreen-persist-restore (around my_elscreen-debug activate)
      "Debug elscreen-persist."
      (message "Start elscreen-persist-restore")
      ad-do-it
      (message "End elscreen-persist-restore")
      )
    (eval-and-compile (require 'edebug))
    (edebug-on-entry 'elscreen-persist-restore t)
    (defun my_elscreen-cleanup-elscreen-persist()
      "Disable elscreen-persist
Delete `elscreen-persist-file'"
      (interactive)
      (elscreen-persist-mode -1)
      (delete-file elscreen-persist-file)
      )
    ))

;; Unload function:

(defun my_elscreen-unload-function ()
  "Unload function to ensure normal behavior when feature 'my_elscreen is unloaded."
  (interactive)
  )

(provide 'my_elscreen)
;;; my_elscreen.el ends here
