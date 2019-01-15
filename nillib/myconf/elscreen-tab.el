;;; elscreen-tab.el --- minor mode to display tabs of elscreen  -*- lexical-binding: t; -*-

;; Copyright (C) 2017 Aki Syunsuke

;; Author: Aki Syunsuke <sunny.day.dev@gmail.com>
;; Package-Version: 0.0.2
;; Package-Requires: ((emacs "25") (elscreen "20180321") (dash "2.14.1"))
;; Keywords: elscreen, elscreen-display-tab
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
;; This minor is for users who;
;; - dislike setting `elscreen-display-tab' to `t', because which highjacks `header-line-format'
;;   which you reserved for the other purpose such as `which-func-mode' or alike.
;; - dislike the tab menu is displayed at the top.

;; [Usage]
;; (require 'elscreen-tab)
;; (elscreen-tab-mode)

;;;; TODO:
;;; Improve usability
;; + Test variables defined with `custom-set-variables' can be customized with `customize'.
;; + Update name of current elscreen-tab soon after selected buffer is changed.
;; + Avoid recreating each tab when updating tabs, for performance.
;; + Naturally support using multiple frames by creating a indigenous buffer of elscreen-tab for each frame.
;; + Create interactive function to reset screen-id provided by elscreen.
;;
;;; Bugs to be fixed:
;; + elscreen-tab becomes non-dedicated when ECB is activated.
;; + elscreen-persist fails to restore buffers sometimes.

;;; Code:
(require 'elscreen)

(eval-and-compile
  (require 'cl)
  )
(require 'dash)


(defgroup elscreen-tab nil
  "Extend displaying tab style of elscreen."
  :tag "elscreen-tab-style"
  :group 'elscreen-tab
  :package-version '("elscreen-tab" ("0.0.2" . "25.3")))


(defconst elscreen-tab:tab-window-parameters
  '(window-parameters .
     ((no-other-window . t) (no-delete-other-windows . t) (delete-window . ignore))))
(defconst elscreen-tab:dedicated-tab-buffer-name " *elscreen-tab*")
(defconst elscreen-tab:unmet-condition 'unmet-condition
  "Throw this value if some condition is not met.")

(defcustom elscreen-tab:debug-flag nil
  "Non-nil means showing message about what happened, for debug purpose."
  :type 'boolean
  :group 'elscreen-tab)

(defcustom elscreen-tab:mode-line-position 'bottom
  "Specify where to place the window of elscreen-tab."
  :type '(radio (const top) (const :value bottom))
  :group 'elscreen-tab)

(defcustom elscreen-tab:undesirable-name-regexes
  `(" \\*" "\\*Help\\*" "\\*scratch\\*")
  "Try to avoid using listed names for elscreen-tab in descending order."
  :type '(list string)
  :group 'elscreen-tab)

(defvar elscreen-tab:mode-line-format nil "Remove mode-line for elscreen-tab if nil.")
(defvar elscreen-tab:display-buffer-alist
  `((side . ,elscreen-tab:mode-line-position) (slot . 0) (window-height . 1) (preserve-size . (nil . t))
     ,elscreen-tab:tab-window-parameters))


(defface elscreen-tab:current-screen-face
  '((((class color))
      (:background "yellow" :foreground "red" :box t))
     (t (:underline t)))
  "Face for current screen tab."
  :group 'elscreen-tab)

(defface elscreen-tab:other-screen-face
  '((((type x w32 mac ns) (class color))
      :background "Gray85" :foreground "Gray50" :box t)
     (((class color))
       (:background "blue" :foreground "black" :underline t)))
  "Face for tabs other than current screen one."
  :group 'elscreen-tab)

(defface elscreen-tab:mouse-face
  `((t
      :inherit link
      :background ,(face-attribute 'elscreen-tab:current-screen-face :foreground)
      :foreground ,(face-attribute 'elscreen-tab:current-screen-face :background)
      ))
  "Face for when mouse cursor is over each tab of elscreen.")


(defmacro elscreen-tab:debug-log (form &rest args)
  "[internal] (message FORM ARGS)."
  `(if elscreen-tab:debug-flag (message (concat "[ELSCREEN-TAB]",form) ,@args)))


(defun elscreen-tab:setq-display-buffer-alist ()
  "Configure `display-buffer-alist'."
  ;; ref. https://www.gnu.org/software/emacs/manual/html_node/elisp/Frame-Layouts-with-Side-Windows.html#Frame-Layouts-with-Side-Windows
  (setq display-buffer-alist
    `((,(regexp-quote elscreen-tab:dedicated-tab-buffer-name) .
        (display-buffer-in-side-window . ,elscreen-tab:display-buffer-alist)))))

(defun elscreen-tab:toggle-debug-flag ()
  (interactive)
  (setq elscreen-tab:debug-flag (not elscreen-tab:debug-flag)))

(defun elscreen-tab:dedicated-tab-buffer-name ()
  "[internal] Get or create singleon buffer."
  (get-buffer-create elscreen-tab:dedicated-tab-buffer-name))

(defun elscreen-tab:update-buffer ()
  "Update tab buffer if it has changed."
  (elscreen-tab:debug-log "[%s>%s]called" this-command "elscreen-tab:update-buffer")

  (with-current-buffer (elscreen-tab:dedicated-tab-buffer-name)
    (setq buffer-read-only nil
      mode-line-format elscreen-tab:mode-line-format
      show-trailing-whitespace nil
      )
    (cursor-intangible-mode 1)
    (erase-buffer)
    (insert
      (let ((screen-ids (sort (elscreen-get-screen-list) '<)))
        (mapconcat #'elscreen-tab:create-tab-unit screen-ids "|")))
    ;; Finish
    (setq buffer-read-only t)
    ))

(defun elscreen-tab:create-tab-unit (screen-id)
  "Return text of a tab unit which is added properties for SCREEN-ID."
  (let* ((nickname-or-buf-names (assoc-default screen-id (elscreen-get-screen-to-name-alist)))
          (nickname-or-1st-buffer
            (elscreen-tab:avoid-undesirable-name (split-string nickname-or-buf-names ":")))
          (tab-name
            (elscreen-truncate-screen-name nickname-or-1st-buffer (elscreen-tab-width) t))
          (tab-status (elscreen-status-label screen-id " "))
          (tab-id (concat "[" (number-to-string screen-id) "]"))
          tab-title
          tab-unit)
    ;; colorize tab-id
    (if (eq (elscreen-get-current-screen) screen-id)
      ;; Add face only to currently selected tab.
      (put-text-property 0 3 'face 'elscreen-tab:current-screen-face tab-id)
      (put-text-property 0 3 'face 'elscreen-tab:other-screen-face tab-id))
    (setq tab-title (format "%s%s%s" tab-status tab-id tab-name))
    (setq tab-unit (elscreen-tab:propertize-click-to-jump tab-title screen-id))
    tab-unit))

(defun elscreen-tab:avoid-undesirable-name (name-list)
  "Length of NAME-LIST must be more than 0."
  (cl-loop for name = (pop name-list)
    if (or
         (member-if-not (lambda (e) (string-match e name)) elscreen-tab:undesirable-name-regexes)
         (eq 1 (length name-list)))
    return (or name "?")
    ))

(defun elscreen-tab:propertize-click-to-jump (text screen-id)
  "Return a copy of TEXT having feature to switch to screen of SCREEN-ID by mouse-click."
  (propertize text
    'cursor-intangible t
    'mouse-face 'elscreen-tab:mouse-face
    'help-echo (assoc-default screen-id (elscreen-get-screen-to-name-alist))
    'local-map (elscreen-tab:create-keymap screen-id)))

(defun elscreen-tab:create-keymap (screen-id)
  (let ((keymap (make-sparse-keymap)))
    (define-key keymap (kbd "<mouse-1>")
      (lambda (_)
        (interactive "e")
        (elscreen-goto screen-id)))
    keymap))

(defun elscreen-tab:has-elscreen-tab-name (buffer)
  (equal (buffer-name buffer) elscreen-tab:dedicated-tab-buffer-name))

(defun elscreen-tab:tab-number ()
  "Window number (s) of currently displayed `elscreen-tab:dedicated-tab-buffer-name'."
  (-count #'elscreen-tab:has-elscreen-tab-name
    (mapcar #'window-buffer (window-list))))

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
  (buffer-name (window-buffer window)))

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
        ))
    (setq win (display-buffer-in-side-window buf elscreen-tab:display-buffer-alist))
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
  "Delete window of `elscreen-tab' of current screen, if it exists."
  (let ((window (get-buffer-window (elscreen-tab:dedicated-tab-buffer-name))))
    (if window
      (progn
        (elscreen-tab:debug-log
          "[%s>elscreen-tab:delete-window-if-exists] called for screen[%d]" this-command (elscreen-get-current-screen))
        (delete-window window)))))

(defun elscreen-tab:delete-window (&optional screen-id)
  "Delete `elscree-tab''s window of SCREEN-ID's  if it is specified,\
else delete current window of SCREEN-ID."
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
    ))

(defun elscreen-tab:delete-all-winow ()
  "[Internal] Delete all windows of `elscreen-tab'.
Call this function to disable this mode."
  ;; Remove hook which can affect the following procedure.
  ;; Fixme1: After calling this func, pointer is placed at mini-buffer.
  (elscreen-tab:remove-all-hooks)
  (save-excursion
    (mapc 'elscreen-tab:delete-window (elscreen-get-screen-list)))
  )


;;; Advice
(defadvice elscreen-screen-nickname (after elscreen-tab:elscreen-screen-nickname activate)
  "Advice to update screen-nickname promptly."
  (elscreen-tab:update-buffer)
  )


;;;; Hook

(defvar elscreen-tab:hooks '(elscreen-create-hook elscreen-goto-hook elscreen-kill-hook)
  "A group of hooks to update elscreen-tab.")

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
  "Show tab window of elscreen at `elscreen-tab:mode-line-position' instead of 'header-line.
Because header line is precious and tab is only displayed in
`frame-first-window' in elscreen-mode.
"
  :group 'elscreen-tab
  :global t
  :require 'elscreen ; This line doesn't work?

  (catch elscreen-tab:unmet-condition
    (elscreen-tab:debug-log "elscreen-tab-mode is called when its value is `%s'" elscreen-tab-mode)
    (elscreen-tab:check-prerequisite)
    (elscreen-tab:toggle elscreen-tab-mode)
    ))

(defun elscreen-tab:toggle (boolean)
  "Turn off `elscreen-tab-mode' if BOOLEAN is nil, else turn on."
  (interactive)
  (if (not boolean)
    (progn
      (elscreen-tab:remove-all-hooks)
      (elscreen-tab:clear-objects))
    (progn
      (setq elscreen-display-tab nil) ; Disable original `tab'.
      (elscreen-tab:setq-display-buffer-alist)
      (elscreen-tab:add-all-hooks)
      (elscreen-tab:update-and-display)
      )))

;; Run timer, because calling `elscreen-persist-restore' also restores old `elscreen-tab:dedicated-tab-buffer-name'.
(eval-after-load 'elscreen-persist (run-at-time 10 nil #'elscreen-tab:ensure-one-window))


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
    ))

(provide 'elscreen-tab)
;;; elscreen-tab.el ends here
