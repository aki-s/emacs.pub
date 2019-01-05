;;; elscreen-tab.el --- minor mode to display tabs of elscreen  -*- lexical-binding: t; -*-

;; Copyright (C) 2017 Aki Syunsuke

;; Author: Aki Syunsuke <sunny.day.dev@gmail.com>
;; Package-Version: 0.0.1
;; Package-Requires: ((elscreen "2012-09-21"))
;; Keywords: elscreen
;; Created: 2017-02-26

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

;; [Usage]
;; (require 'elscreen-tab)
;; (elscreen-tab-mode)
;;
;; [Note]
;; Referenced `ecb-layout.el', `evil-commands.el' to create this.
;; (setq ecb-layout-debug-mode t) ; to track window management of ECB.

;;;; TODO: Fix bugs
;;; Improve usability
;; + [Severity 1]
;; - Display useful info with mod-line of 'elscreen-tab'.
;;
;;; Bugs
;; + [Severity 1]
;; - Update screen-tab soon after buffer is changed.
;; - title dosen't change directly after [C-; A]
;;
;; + [Severity 2]
;; - Check if elscren-persist-mode work with this mode?
;; - Switch buffer
;;   - "Cannot switch to dedicated window" happens sometimes.
;; - Screen name
;;   - Use better title for new screen.  It always seems to be '*elscreen-tab*' by default.
;;     -  (Last visited buffer is at the top of list, ant it it '*elscreen-tab*?)
;;
;; + It is annoying to show elscreen-tab buffer;
;;  - When `minibuffer-completion-help' is called.
;; + Handle with following functions properly
;; - `set-window-dedicated-p'  has no effect when ECB is activated.
;;

;;; Code:
(require 'elscreen)
(require 'dash)

(eval-and-compile
  (require 'cl)
  )


(defgroup elscreen-tab nil
  "Extention for elscreen."
  :tag "ElT"
  :group 'elscreen-tab
  :package-version '("ElT" ("0.0.0" . "24.5.1"))
  )


(defcustom elscreen-tab:debug-flag t
  "Message what happened if true, for debug purpose."
  :type 'x
  :group 'elscreen-tab)


(defvar elscreen-tab:display-buffer-ignore nil "Ignore advice in this buffer.")
(setq elscreen-tab:display-buffer-ignore '("*helm-mode-switch-to-buffer*"))
(defvar elscreen-tab:dedicated-tab-window nil "Window object is not singleton.")

(defconst elscreen-tab:tab-window-parameters '(window-parameters .
                                                ((no-other-window . t) (no-delete-other-windows . t))))
(defconst elscreen-tab:dedicated-tab-buffer-name "*elscreen-tab*" "Singleton.")
(defconst elscreen-tab:unmet-condition 'unmet-condition "Throw this value if some condition is not met.")

(defun elscreen-tab:setq-display-buffer-alist ()
  "Configure `display-buffer-alist'."
  ;; ref. https://www.gnu.org/software/emacs/manual/html_node/elisp/Frame-Layouts-with-Side-Windows.html#Frame-Layouts-with-Side-Windows
  (setq display-buffer-alist
    `((,elscreen-tab:dedicated-tab-buffer-name display-buffer-in-side-window
        (side . bottom) (slot . 0) (window-height . 1) (preserve-size . (t . nil))
        ,elscreen-tab:tab-window-parameters
        ))
    ))


(defface my_elscreen-tab-current-screen-face
  '((((class color))
      (:background "yellow" :foreground "black"))
     (t (:underline t)))
  "Face for current screen tab."
  :group 'elscreen)


(defmacro elscreen-tab:debug-log (form &rest args)
  "[internal] (message FORM ARGS)."
  `(if elscreen-tab:debug-flag (message (concat "[ELSCREEN-TAB]",form) ,@args))
  )

(defun elscreen-tab:toggle-debug-flag ()
  (interactive)
  (setq elscreen-tab:debug-flag (not elscreen-tab:debug-flag))
  )

(defun elscreen-tab:dedicated-tab-buffer-name ()
  "[internal] Get or create singleon buffer."
  (get-buffer-create elscreen-tab:dedicated-tab-buffer-name))

(defun elscreen-tab:update-buffer ()
  "Update tab buffer if it has changed."
  (elscreen-tab:debug-log "[%s>%s]called" this-command "elscreen-tab:update-buffer")

  (with-current-buffer (elscreen-tab:dedicated-tab-buffer-name)
    (setq buffer-read-only nil)
    (erase-buffer)
    (insert
      (let ((screen-ids (sort (elscreen-get-screen-list) '<))
             (screen-to-name-alist (elscreen-get-screen-to-name-alist)))
        (mapconcat
          (lambda (screen-id)
            (let* ((buf-names (assoc-default screen-id screen-to-name-alist))
                    ;; or use `elscreen-get-screen-nickname'?
                    (1st-buffer (car (split-string buf-names ":")))
                    (title
                      (format "%s[%d]%s" (elscreen-status-label screen-id " ")
                        screen-id 1st-buffer)))
              (put-text-property 1 4 'face 'elscreen-tab-other-screen-face title) ; colorize id
              title))
          screen-ids "|")))
    ;; Add face to currently selected tab.
    (goto-char (point-min))
    (while (re-search-forward (concat "\\[" (number-to-string (elscreen-get-current-screen)) "\\]") nil t)
      (put-text-property (match-beginning 0) (match-end 0)
        'face 'my_elscreen-tab-current-screen-face)
      )
    ;; Finish
    (setq buffer-read-only t)
    )
  )

(defun elscreen-tab:get-buffer-tree (wintree)
  "Extracts the buffer tree from a given window tree WINTREE \
by Omitting (left top right bottom) from tree."
  (if (consp wintree)
    (cons (car wintree) (mapcar #'elscreen-tab:get-buffer-tree (cddr wintree)))
    (window-buffer wintree)))

(defun elscreen-tab:restore-window-tree (window tree)
  "Restore windows in WINDOW from window tree TREE."
  (if (bufferp tree)
    (set-window-buffer window tree)
    (if (not (cddr tree))
      (elscreen-tab:restore-window-tree window (cadr tree))
      ;; tree is a regular list, split recursively
      (let ((newwin (split-window window nil (not (car tree)))))
        (elscreen-tab:restore-window-tree window (cadr tree))
        (elscreen-tab:restore-window-tree newwin (cons (car tree) (cddr tree)))))))

(defun elscreen-tab:has-elscreen-tab-name (buffer)
  (equal (buffer-name buffer) elscreen-tab:dedicated-tab-buffer-name))

(defun elscreen-tab:tab-number ()
  "Window number (s) of currently displayed `elscreen-tab:dedicated-tab-buffer-name'."
  (-count #'elscreen-tab:has-elscreen-tab-name
    (mapcar #'window-buffer (window-list)))
  )

(defun* elscreen-tab:ensure-one-window ()
  "Delete elscreen-tab if it is not side window. "
  (elscreen-tab:debug-log "[%s>%s]called" this-command "elscreen-tab:ensure-one-window")
  (when (= (elscreen-tab:tab-number) 1)
    (return-from elscreen-tab:ensure-one-window))
  (let* ((win-list (window-list)))
    (loop for win in win-list do
      (when (and (elscreen-tab:has-elscreen-tab-name (window-buffer win))
              (not (window-at-side-p win)))
        (delete-window win)
        ))))

(defun elscreen-tab:window-buffer-name (window)
  "Get buffer name for WINDOW."
  (buffer-name (window-buffer window))
  )

(defun elscreen-tab:get-window ()
  "Create or get `elscreen-tab:dedicated-tab-buffer-name' in\
current visible display."
  (elscreen-tab:debug-log "[%s>%s]called" this-command "elscreen-tab:get-window")
  (let* ((buf (elscreen-tab:dedicated-tab-buffer-name))
          (win (get-buffer-window buf)))
    (unless win
      (with-current-buffer buf
        ;; Hide header-line
        (setq header-line-format nil)
        (setq buffer-read-only t)
        ;; Directly calling `display-buffer-in-side-window' may keep displaying mode-line?
        (setq win (display-buffer-in-side-window buf
                    `((side . bottom) (slot . 0) (window-height . 1) (preserve-size . (t . nil))
                       ,elscreen-tab:tab-window-parameters)))
        ))
    (elscreen-tab:stingy-height win) ; It seems `display-buffer-in-side-window didn't make window less than window-min-height.
    (set-window-dedicated-p win t) ; Because newly created window is not dedicated.
    (elscreen-tab:ensure-one-window)
    win))

(defun elscreen-tab:update-and-display ()
  "[Internal]."
  (elscreen-tab:get-window)
  (elscreen-tab:update-buffer)
  )

(defun* elscreen-tab:stingy-height (window)
  "Set WINDOW height as small as possible."
  (unless window (return-from elscreen-tab:stingy-height "Invalid argument: window must not be nil"))
  (with-selected-window window
    (let* ((expected-height 1)
            (delta (- expected-height (window-body-height)))
            (delta-allowed (window-resizable window delta nil window)))
      (with-demoted-errors "Unable to minimize %s"
        (window-resize window delta-allowed nil t)
        (window-preserve-size window nil t)
        (setq window-size-fixed t)
        )))
  )

(defun elscreen-tab:delete-window-if-exists ()
  "[Internal] Delete `elscreen-tab:dedicated-tab-window' in current screen if exists."
  (let ((window (get-buffer-window (elscreen-tab:dedicated-tab-buffer-name))))
    (if window
      (progn
        (elscreen-tab:debug-log
          "[%s>elscreen-tab:delete-window-if-exists] called for screen[%d]" this-command (elscreen-get-current-screen))
        (delete-window window)))))

(defun elscreen-tab:delete-window (&optional screen-id)
  "[Internal] Delete SCREEN-ID's `elscreen-tab:dedicated-tab-window' if specified, else current window's one."
  (let (org-screen-id)
    (if screen-id
      (progn
        (setq org-screen-id (elscreen-get-current-screen))
        (elscreen-goto-internal screen-id)
        (elscreen-tab:delete-window-if-exists)
        (elscreen-set-window-configuration screen-id (elscreen-current-window-configuration))
        (elscreen-goto-internal org-screen-id)
        )
      (elscreen-tab:delete-window-if-exists))
    )
  )

(defun elscreen-tab:delete-all-winow ()
  "[Internal] Delete all `elscreen-tab:dedicated-tab-window'.
Call this function to disable this mode."
  ;; Remove hook which can affect the following procedure.
  ;; Fixme1: After calling this func, pointer is placed at mini-buffer.
  (elscreen-tab:remove-all-hooks)
  (save-excursion ;testing this line to fix "Fixme1".
    (mapc 'elscreen-tab:delete-window (elscreen-get-screen-list)))
  )


;;; Advice
(defadvice elscreen-screen-nickname (after elscreen-tab:elscreen-screen-nickname activate)
  "Advice to update screen-nickname promptly."
  (elscreen-tab:update-buffer)
  )


;;;; Hook

(defvar elscreen-tab:hooks nil "A group of hooks to update elscreen-tab.")
(setq elscreen-tab:hooks '(elscreen-create-hook elscreen-goto-hook elscreen-kill-hook))

(defun elscreen-tab:manage-hook (choice func hooks)
  "CHOICE (add/remove) FUNC to/from HOOKS.
All argument must be given as symbol.
CHOICE is either 'add or 'rm.
HOOKS is such as '(hook1 hook2) or 'hook3."
  (catch elscreen-tab:unmet-condition
    (unless (functionp func) (throw elscreen-tab:unmet-condition "2nd arg must be function."))
    (let ((add-or-rm (case choice
                       (add 'add-hook)
                       (rm 'remove-hook)
                       (t (throw elscreen-tab:unmet-condition "Specify 'add or 'rm")))))
      (mapc
        (lambda (hook)
          (let ((preposition (case choice ('add "to") ('rm "from"))))
            (elscreen-tab:debug-log "%s `%s' %s `%s'" choice func preposition hook))
          (funcall add-or-rm hook func)
          )
        (if (atom hooks) (list hooks) hooks))))
  )

(defun elscreen-tab:remove-all-hooks ()
  "Remove hooks."
  (elscreen-tab:manage-hook 'rm 'elscreen-tab:update-and-display elscreen-tab:hooks)
  )

(defun elscreen-tab:add-all-hooks ()
  "Add hooks."
  (elscreen-tab:manage-hook 'add 'elscreen-tab:update-and-display elscreen-tab:hooks)
  )

(defun elscreen-tab:clear-objects ()
  "Delete all GUI objects related to elscreen-tab."
  ;; Kill the tab buffer.
  (let* ((buf (get-buffer elscreen-tab:dedicated-tab-buffer-name))
          (win (get-buffer-window buf)))
    (set-window-dedicated-p win nil)
    (kill-buffer buf))
  ;; Delete windows.
  (elscreen-tab:delete-all-winow)
  )


;;;; Mode
(defun elscreen-tab:check-prerequisite ()
  "Throw `elscreen-tab:unmet-condition' if prerequisite to start elscreen-tab-mode is not met."
  (unless (boundp 'elscreen-version) ; Check if elscreen is active.
    (throw elscreen-tab:unmet-condition "`elscreen' seems to be not loaded."))
  t)

(define-minor-mode elscreen-tab-mode
  "Show tabs of elscreen at the bottom window instead of 'header-line.
Because header line is precious and tab is only displayed in
`frame-first-window' in elscreen-mode.
@note: `elscreen-select-and-goto' bound to [\\[elscreen-select-and-goto]] may be sufficient.
"
  :group 'elscreen
  :global t
  :require 'elscreen ; This line doesn't work?

  (catch elscreen-tab:unmet-condition
    (elscreen-tab:debug-log "elscreen-tab-mode is called when its value is `%s'" elscreen-tab-mode)
    (elscreen-tab:check-prerequisite)
    (elscreen-tab:toggle elscreen-tab-mode)
    )
  )

(defun elscreen-tab:toggle (boolean)
  "Turn off `elscreen-tab-mode' if BOOLEAN is nil, else turn on."
  (interactive)
  (if (not boolean)
    (progn
      (elscreen-tab:remove-all-hooks)
      (elscreen-tab:clear-objects)
      )
    (progn
      (setq elscreen-display-tab nil) ; Disable original `tab'.
      (elscreen-tab:setq-display-buffer-alist)
      (elscreen-tab:add-all-hooks)
      (elscreen-tab:update-and-display)
      )
    )
  )

; Run timer, because calling `elscreen-persist-restore' also restores old `elscreen-tab:dedicated-tab-buffer-name'.
(run-at-time 60 nil #'elscreen-tab:ensure-one-window)


;; Utility for debug:
(defun elscreen-tab:debug:pp-buffer-and-window ()
  "Debug Wrong type argument `window-[valid|live]-p`."
  (interactive)
  (cl-labels (
               (tuplize (buf) (cons (buffer-name buf) (get-buffer-window buf)))
               (window-bound-p (e1 e2)
                 (pcase `(,e1 ,e2)
                   (`((,e11 . ,e12) (,e21 . ,e22))
                     (cond
                       ((or (and e12 e22) (and (null e12) (null e22))) (string< e11 e21))
                       ((null e12) nil)
                       ((null e22) t)
                       ))))
               )
    (let* ((buffer-window (map 'list #'tuplize (buffer-list)))
            (res (seq-sort #'window-bound-p buffer-window)))
      (pp res (get-buffer-create "*elscreen-tab:debug*"))
      (switch-to-buffer-other-window "*elscreen-tab:debug*")
      )))

;; Unload function:
(defun elscreen-tab-unload-function ()
  "Unload function to ensure normal behavior when feature 'elscreen-tab is unloaded."
  (interactive)
  (ignore-errors
    (elscreen-tab:clear-objects)
    )
  )

(provide 'elscreen-tab)
;;; elscreen-tab.el ends here
