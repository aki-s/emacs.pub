;;; my_window.el --- window
;;; Commentary:

;;;; ref. ~/.emacs.d/share/emacs-window-layout/window-layout.el
;;;; ref. https://github.com/5HT/emacs-config/blob/master/.emacs.d/windows/windows.el    by HIROSE Yuuji [yuuji@gentei.org]

;;; Code:

(eval-when-compile (require 'my_macro))

(load-library-nodeps "my_rotate")

(load-library-nodeps "es-windows") ; enable jump to specified window
(global-set-key (kbd "C-x O") 'esw/select-window)

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
  "Change foreground color and background color of mode-line color of selected window.
"
  (face-remap-add-relative
   'mode-line `((:foreground ,fore :background ,back ) mode-line)))

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

(defun my_window--delete-forcibly(&optional window)
  "Forcibly delete WINDOW.
If you want to delete side windows, see `window-toggle-side-windows'"
  (interactive (list (get-buffer-window)))
  (setf (window-parameter window 'delete-window) nil)
  (let ((ignore-window-parameters nil) (buff-name (window-buffer)))
    (delete-window window)
    (message "Window %s bound to `%s' is deleted forcibly" window buff-name)))
(define-key global-map (kbd "C-x 9") #'my_window--delete-forcibly)

(defvar my_window--sticky-buffer-mode--mode-line-color-cookie nil)
(define-minor-mode my_window--sticky-buffer-mode
  "`my_window--sticky-buffer-mode' is the mode to avoid unwanted change of buffer.

Toggle result of `window-dedicated-p' for a buffer."
  :init-value nil
  :lighter " sticky"
  nil
  :global nil
  (let ((buf (current-buffer))
        (win (selected-window)))
    (if my_window--sticky-buffer-mode
        (progn
          (set-window-dedicated-p win t)
          (setq my_window--sticky-buffer-mode--mode-line-color-cookie
                (my_window-toggle-modeline-color "ivory" "DarkOrange2"))
          )
      (progn
        (set-window-dedicated-p win nil)
        (face-remap-remove-relative my_window--sticky-buffer-mode--mode-line-color-cookie)
        ))
    ))

(provide 'my_window)
;;; my_window.el ends here
