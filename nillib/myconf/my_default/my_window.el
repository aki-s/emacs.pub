;;; my_window.el --- window
;;; Commentary:

;;;; ref. ~/.emacs.d/share/emacs-window-layout/window-layout.el
;;;; ref. https://github.com/5HT/emacs-config/blob/master/.emacs.d/windows/windows.el    by HIROSE Yuuji [yuuji@gentei.org]

;;; Code:

(eval-when-compile (require 'my_macro))

(load-library-nodeps "my_rotate")

(if (> emacs-major-version 23)
    (progn
      (load-library-nodeps "es-windows") ; enable jump to specified window
      (global-set-key (kbd "C-x O") 'esw/select-window)
      (setq esw/be-helpful nil)
      ;; es-windows not working well...
      ))

(defun my_window-popwin-bellow (&optional height target_window)
  "@dev
Split (selected-window) and popup target_window at bottom
@refs. display-buffer-at-bottom
"
  (interactive "P")
  (if (null target_window)
      (setq target_window (selected-window)))
  (if (null height)
      (setq height (/ (window-height target_window) 2)))
  (split-window target_window (- (window-text-height target_window) height)))

(defvar my_window-poped-buffer-height 10 "")
(defvar my_window-poped-buffer-width 50 "")
(defun my_window-display-buffer-stingy (&optional frame lvl width height) ;; (fit-window-to-buffer)
  "@udev
Stingy on display-buffer at least show in less than half size of original size.
  argment lvl is level of stingy"
  (cond ((null lvl )
         )

        ( (= lvl 1)
          ;;$;; minimum height if equal or less than (frame-height)
          (let* (
                 ( half-window-height (/ (window-height) 2))
                 ( buff-size-height (count-lines (point-min) (point-max)) )
                 )
            (if (> buff-size-height half-window-height)
                (progn
                  ;; half-window-height
                  (my_window-popwin-bellow half-window-height)
                  )
              (progn
                ;; buff-size-height
                (my_window-popwin-bellow buff-size-height)
                )
              )
            )
          )

        ( (= lvl 2) ;; fixed width

          ;;(split-window-sensibly (selected-window))
          ;;(split-window (select-window (selected-window))
          (split-window (selected-window) (- (window-height) my_window-poped-buffer-height))
          (other-window 1)
          ;;$;;; ref.
          ;;$;; -- frame
          ;;$;;
          ;;$;; -- frame var
          ;;$;;
          ;;$;; -- window
          ;;$;; window-tree
          ;;$;; window-width window-height window-text-height window-inside-edges
          ;;$;; window-parameter window-parameters
          ;;$;; display-buffer get-buffer-create pop-to-buffer
          ;;$;;
          ;;$;;
          ;;$;; -- window var
          ;;$;; pop-up-frames pop-up-windows
          )

        )
  )


;; face mode-line
;; face mode-line-inactive
(defun my_window-toggle-modeline-color(&optional fore back)
  "@dev Change foreground color and background color of mode-line color of selected window.
"
  (face-remap-add-relative
   ;; 'mode-line '((:foreground "ivory" :background "DarkOrange2") mode-line))
    'mode-line `((:foreground ,fore :background ,back ) mode-line))
  )

;; sticky-buffer-previous-header-line-format

(defvar sticky-buffer-previous-header-line-format)
(define-minor-mode sticky-buffer-mode
  "@dev
Make the current window always display this buffer."
  nil " sticky" nil
  (if sticky-buffer-mode
      (progn
        (set (make-local-variable 'sticky-buffer-previous-header-line-format)
             header-line-format)
        (set-window-dedicated-p (selected-window) sticky-buffer-mode)
        (my_window-toggle-modeline-color "ivory" "DarkOrange2")
        )
    (progn
      (set-window-dedicated-p (selected-window) sticky-buffer-mode)
      (setq header-line-format sticky-buffer-previous-header-line-format)

      ))
  )


;; (defvar my_window-dedicated nil)
;; (make-variable-buffer-local my_window-dedicated)

;; (defun my_window-toggle-window-dedicated ()
;;   "Toggle whether the current active window is dedicated or not"
;;   (interactive)
;;   (message "%s" (window-dedicated-p (get-buffer-window (current-buffer))) )
;;   (setq my_window-dedicated
;;         (set-window-dedicated-p (get-buffer-window (current-buffer)) (not (window-dedicated-p (get-buffer-window (current-buffer)))))
;;         )
;;   (message
;;   (if my_window-dedicated
;;       (prog1
;;         "Window '%s' is dedicated"
;;         (my_window-change-modeline-color)
;;         )
;;     (prog1
;;           "Window '%s' is normal"
;;       (my_window-change-modeline-color)
;;       )
;;     )
;;   (current-buffer)))

;; window.el is not provided
;; (window-dedicated-p )
;; set-window-dedicated-p
;; get-largest-window
;; get-lru-window

;; (defun win-swap ()
;;  "@DEV
;; Swap windows using buffer-move.el"
;; (interactive)
;; (let (
;;       (bright (windmove-find-other-window 'right))
;;       (bleft (windmove-find-other-window 'left))
;;       (cur (selected-window))
;;        )
;; (if (null
;;    (windmove-left)
;;    ()
;; )
(require 'windmove)
(setq windmove-wrap-around t)
(windmove-default-keybindings)
(define-key global-map (kbd "C-M-k") 'windmove-up) ; use `evil-window-up' bound to C-w k
(define-key global-map (kbd "C-M-j") 'windmove-down)
(define-key global-map (kbd "C-M-l") 'windmove-right) ; `xfce4-session-logout' steals this key bind.
(define-key global-map (kbd "C-M-h") 'windmove-left) ; `c-beginning-of-defun' in c-mode overrides this key


(require 'buffer-move)
(global-set-key (kbd "C-M-S-k")     'buf-move-up)
(global-set-key (kbd "C-M-S-j")   'buf-move-down)
(global-set-key (kbd "C-M-S-h")   'buf-move-left)
(global-set-key (kbd "C-M-S-l")  'buf-move-right)

;;;; customize window.el
;; (setq display-buffer-alist
;;       (.)
;; )


(defun count-windows-non-dedicated ()
  "@dev Extension of one-window-p
Consider only non dedicated windows on current frame.
mini-buffer is ignored.
Return the number of non-dedicated windows.
"
  (interactive)
  ;;ver00  (let (
  ;;ver00        (yes 0)
  ;;ver00        (no 0)
  ;;ver00        )
  ;;ver00    (dolist (w (window-list-1))
  ;;ver00      (if (window-dedicated-p w)
  ;;ver00          (incf yes)
  ;;ver00        (incf no)
  ;;ver00        )
  ;;ver00      )
  ;;ver00  no)
  (length (delq t (mapcar 'window-dedicated-p (window-list-1))))
  )


;;(window-tree)
;;
;;(current-window-configuration)
;;;; redirect-frame-focus
;;;; window-persistent-parameters
;;(window-state-put (window-state-get))

(defun my_window-switch-to-buffer-visible (name)
  "@dev
Switch to already visible buffer on some frame."
  ;; get-buffer-window-list
  ;; gnus-select-frame-set-input-focus
  )

(provide 'my_window)
;;; my_window.el ends here
