;;; my_frame --- Frame setting.
;;; Commentary:
;; Should be called when `window-system' is not nil.
;; Conflict with my_face about font.
;; @see my_face.el

;; Copyright (C) 2013

;; Author:
;; Keywords: lisp

;;; Code:

;;;==============================================================
;;; Define utility functions
;;;==============================================================

;;; 'frame-cmd is usefull to move frame with keybind.
;; (require 'frame-cmds);; require frame-fns
;; ref. (frame-parameter-names) of frame-cmds ;; Return an alist of all available frame-parameter names.

(eval-when-compile (require 'frame))

(defun my_frame-toggle-frame-maximized (&optional frame)
  "@dev
 Copied from frame.el:toggle-frame-maximized
Toggle maximization state of the selected frame.
Maximize the selected FRAME or un-maximize if it is already maximized.
Respect window manager screen decorations.
If the FRAME is in fullscreen mode, don't change its mode,
just toggle the temporary FRAME parameter `maximized',
so the FRAME will go to the right maximization state
after disabling fullscreen mode.
See also `toggle-frame-fullscreen'."
  (interactive)
  (if (memq (frame-parameter frame 'fullscreen) '(fullscreen fullboth))
    (modify-frame-parameters
      frame
      `((maximized
          . ,(unless (eq (frame-parameter frame 'maximized) 'maximized)
               'maximized))))
    (modify-frame-parameters
      frame
      `((fullscreen
          . ,(unless (eq (frame-parameter frame 'fullscreen) 'maximized)
               'maximized))))))


(defun my_frame:show-frame-params ()
  (interactive)
  (let ( (buf (get-buffer-create "*my_frame:show-frame-params*"))
         (p (frame-parameters)) )
    (with-current-buffer buf
      (erase-buffer)
      ;;(insert (pop p))
      (while p
        (insert (prin1-to-string (pop p)) "\n")))
    (display-buffer buf)
    ))

(defun my_frame:fullscreen-fullboth ()
  (interactive)
  ;;$bug;;  (x-send-client-message nil 0 nil "_NET_WM_STATE" 32 '(2 "_NET_WM_STATE_FULLSCREEN" 0))
  (set-frame-parameter nil 'fullscreen 'fullboth);; hides frame (Hides apple mark on top left corner on Darwin)
  )

(defun my_frame:toggle-X11-fullscreen ()
  "Toggle full screen on X11
  http://www.emacswiki.org/emacs/FullScreen"
  (interactive)
  (when (eq window-system 'x)
    (set-frame-parameter
      nil 'fullscreen
      (when (not (frame-parameter nil 'fullscreen)) 'fullboth))))


;;;; Fancy blink cursor
;;;  http://stackoverflow.com/questions/4642835/how-to-change-the-cursor-color-on-emacs
(defvar blink-cursor-colors (list  "#92c48f" "#6785c5" "#be369c" "#d9ca65")
  "On each blink the cursor will cycle to the next color in this list.")

(defvar blink-cursor-count 0)
(defun my_frame:blink-cursor-timer-function ()
  "Zarza wrote this cyberpunk variant of timer `blink-cursor-timer'.
Warning: overwrites original version in `frame'.

This one changes the cursor color on each blink. Define colors in `blink-cursor-colors'.
Use blink-cursor-mode to enable/disable blik cursor.
"
  (when (not (internal-show-cursor-p))
    (when (>= blink-cursor-count (length blink-cursor-colors))
      (setq blink-cursor-count 0))
    (set-cursor-color (nth blink-cursor-count blink-cursor-colors))
    (setq blink-cursor-count (+ 1 blink-cursor-count))
    )
  (internal-show-cursor nil (not (internal-show-cursor-p)))
  )

(advice-add 'blink-cursor-timer-function :override 'my_frame:blink-cursor-timer-function)

;;;==============================================================
;;; Set frame title
;;;==============================================================

(make-face 'frame-title-face)
;;$;; Looks like changing title text is impossible.
(set-face-attribute 'frame-title-face nil :foreground "yellow");; don't work

;; @todo
;; filtered-frame-list visible-frame-list frame-list
(defvar frame-title-format-original frame-title-format "original frame-title-format")

(defun my_frame:dynamically-change-title ()
  "Dynamically change frame title based on my preferred format.
Override frame-parameter `name' previously set (This would be caused by `desktop.el').
"
  (interactive)
  (setq frame-title-format nil)
  (setq-default frame-title-format
      ;;;; ref. http://amitp.blogspot.jp/2011/08/emacs-custom-mode-line.html
                ;; @TBD windows.el break frame title at default.
                '("#" (:eval (format "%d" (length (frame-list))))
                  " "
                  (:eval (format "%s@%s" invocation-name (system-name)))
                  " "
                  (:eval (my_frame:filename-or-directory))
                  " "
                  mode-line-modes  ;; major,minor-mode
                  ))
  (set-frame-parameter nil 'name nil) ; Change frame-tile automatically. ref. Setting `explicit-name' nil by `modify-frame-parameters' didn't work.
  (message "[my_frame:dynamically-change-title] is called.")
  )

(defun my_frame:filename-or-directory ()
  (abbreviate-file-name (or (buffer-file-name) default-directory))
  )

;;;==============================================================
;;;; Set frame parameters
;;; Precedence of configuration is in the following sequence?
;; - frame.el: initial-frame-alist (effective only for initial frame)
;; - frame.el: window-system-default-frame-alist (Window system specific values.)
;; - C: default-frame-alist  ;; function set-xxxx-color use this list?
;;;==============================================================

(defun my_frame-init ()
  "Setting at 'window-system-default-frame-alist would be sufficient..."
  (interactive)
  (message "my_frame:my_frame-init was called.")
  ;; (modify-frame-parameters nil '((fullscreen . maximized))) ;; remain frame. emacs-major-version > 23
  ;;$;; (set-frame-parameter nil 'fullscreen nil);; remain frame
  ;;(set-frame-parameter nil 'scroll-bar-width  10)
  (setq tool-bar-mode nil)
  (tool-bar-mode -1)
  (setq use-dialog-box nil)
  (set-foreground-color "#00ff00") ; Green
  (set-background-color "#050505") ; Gray
  ;; Don't know why but black on (string= window-system 'x)
  (set-border-color "dark orange")
  )

;;; We can also use window-setup-hook, or after-init-hook?
(add-hook 'emacs-startup-hook 'my_frame-init t)

;; note. window-configuration-change-hook may be effective.
;(add-hook 'window-setup-hook 'my_frame:dynamically-change-title) ; Override effect of `elscreen-persist-restore' to `frame-title-format'
(run-at-time 60 nil #'my_frame:dynamically-change-title)
(add-hook 'after-make-frame-functions 'my_frame-toggle-frame-maximized t) ; Maximized frame after C-x 5 2
(add-hook 'after-make-frame-functions 'my_frame-open-last-visited-buffer t) ;; Open last visited buffer in 'elscreen-mode

(defun my_frame-open-last-visited-buffer (&optional frame)
  "Open last visited buffer when elscreen was active and new frame is created.
@see window.el#`switch-to-prev-buffer'."
  (if (and (boundp 'elscreen-frame-confs) (not (null elscreen-frame-confs)))
    (let ((window (get-buffer-window (current-buffer)))
           new-buffer)
      (catch 'found
        (message "%S"(window-prev-buffers window))
        (dolist (entry (window-prev-buffers window))
          (setq new-buffer (car entry))
          (set-window-buffer-start-and-point window new-buffer)
          (throw 'found t))
        ))))


(setq window-system-default-frame-alist ;;;; window config
  '((x
      (menu-bar-lines . 1)
      (tool-bar-lines . 0)
      ;;(fullscreen . fullboth)
      (fullscreen . maximized)
      ;;@TODO
      ;; disable maximizing window if buffer name is "*ediff*"
      )
     ;;   (ns ;; Just setting (ns ) breaks face and font settings!
     ;;     )
     (nil (menu-bar-lines . 0) (tool-bar-lines . 0))))

(setq initial-frame-alist (quote (
                                  (fullscreen . maximized)
                                  (alpha . 83)
                                  )))
;;;==============================================================
;;;==============================================================
;;$ frameset.el
;; frameset-to-register

;;$ frame.el
;; set-frame-configuration

(provide 'my_frame)
;;; my_frame.el ends here
