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

(use-package elscreen
  :config
  (setq elscreen-prefix-key (kbd "C-;"))
  (setq elscreen-tab-display-control nil)

  ;; <override elscreen.el>
  (defvar elscreen--update-unlock-idle-timer nil)
  (defun elscreen--unlock-update-lock()
    (setq elscreen--update-unlock-idle-timer nil))
  (defun elscreen-run-screen-update-hook ()
    "Override function of elscreen.el to prevent huge performance issue of redisplay."
    (unless elscreen--update-unlock-idle-timer
      (setq elscreen--update-unlock-idle-timer
            (run-with-idle-timer 1 nil #'elscreen--unlock-update-lock))
      (when elscreen-frame-confs
        (elscreen-notify-screen-modification-suppress
         (run-hooks 'elscreen-screen-update-hook)))
      (remove-hook 'post-command-hook 'elscreen-run-screen-update-hook)
      ))
  (defun elscreen-set-screen-modified ()
    "Override function of elscreen.el to prevent huge performance issue of redisplay."
    (unless elscreen--update-unlock-idle-timer
      (elscreen-set-conf-list 'modified-inquirer nil)
      (add-hook 'post-command-hook 'elscreen-run-screen-update-hook)))
  ;; </override elscreen.el>

  (use-package helm-elscreen
    :bind (:map elscreen-map ("'" . helm-elscreen)))

  (use-package elscreen-tab
    :config
    ;; In case elscreen couldn't remove 'elscreen-run-screen-update-hook.
    (defun my_elscreen:clear-post-command-hook()
      (remove-hook 'post-command-hook 'elscreen-run-screen-update-hook)
      )
    (add-hook 'elscreen-tab--update-buffer-post-hooks #'my_elscreen:clear-post-command-hook)
    )
  )

(require 'elscreen-separate-buffer-list)
(elscreen-separate-buffer-list-mode)

(require 'my_global-vars)
(use-package elscreen-persist
  :config
  (setq elscreen-persist-file
        (concat my_global-vars--user-emacs-tmp-dir "/elscreen.lst"))

  (defun my_elscreen-kill-hook()
    ;; Because width or height of the window for elscreen-tab is too small,
    ;; `elscreen-persist' would fail to restore it.
    (elscreen-persist-mode -1)
    (elscreen-tab-mode -1)
    ;; (Invalid read syntax: "#") is caused by reading (xx . #<frame>) which is obtained by (frame-parameters)
    (elscreen-persist-store)
    )

  (defun elscreen-persist-get-frame-params ()
    "Don't save frame-parameters, because some parameter cause
   `Invalid read syntax: \"#\"'.
  e.g. (company-box-doc-frame . #<frame  0x9d00a20>)
  Overwrited by `my_elscreen'"
    nil)

  (add-hook 'kill-emacs-hook 'my_elscreen-kill-hook)
)

;;; Configure desktop for elscreen
(defun my_elscreen:start()
  "Start elscreen.
Start sequence is important to avoid error on calling `elscreen-persist-restore'"
  (interactive)

  (remove-hook 'elscreen-screen-update-hook 'elscreen-mode-line-update) ; Avoid error when `mode-line' is not default.

  (elscreen-start) ; set `elscreen-set-prefix-key'
  (require 'my_desktop) ; This line is actually not required for elscreen?
  (elscreen-persist-mode 1)

  (custom-set-faces '(elscreen-tab-current-screen-face
                      ((t (:background "yellow" :foreground "red")))))
  (custom-set-faces '(elscreen-tab-other-screen-face
                      ((t :background "Gray85" :foreground "Gray0" :box t))))
  (custom-set-faces `(elscreen-tab-mouse-face
                      ((t
                       :inherit link
                       :background ,(face-attribute 'elscreen-tab-current-screen-face :foreground)
                       :foreground ,(face-attribute 'elscreen-tab-current-screen-face :background)
                       ))))
  (elscreen-tab-mode)
  (run-with-idle-timer
   ;; Calling `elscreen-persist-restore' also restores old
   ;; `elscreen-tab:dedicated-tab-buffer-name', so I need to assure
   ;; one elscreen-tab window by calling this.
   1
   nil
   #'elscreen-tab--ensure-one-window
   )
  )

(condition-case er
    (my_elscreen:start)
  (error "Failed to start elscreen with error: %s" er))


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
