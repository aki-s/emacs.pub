;;; my_replace.el ---                                -*- lexical-binding: t; -*-

;; Copyright (C) 2014

;; Author:  Syunsuke Aki
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

;;

;;; Code:

;; (defvar my_occur-max-buf 2 "Maximun number of occur buffer to be maintained.")
;; (defvar my_occur-buf-register nil "List of buffer name of occur")

(eval-when-compile (load-library "replace"))
;;;; occur is defined at replace.el
(add-hook 'occur-hook 'occur-rename-buffer)
(add-hook 'occur-hook 'my_occur-hooks t)

(defgroup occur nil
  "Group for occur"
  :prefix "occur-" :group 'convenience)

(defface occur-face-target-line
  '((t :background "#0000ee" :foreground "#ffffff"))
  "Target line face"
  :group 'occur)

(defvar occur-overlay nil)

;; ref (defun occur-mode-display-occurrence ()
(defun occur-display (num)
  "Jump to point corresponding to selected `occur-overlay'.
NUM must be integer.
Works only on emacs keybinding mode."
  (interactive)
  (if (> num 0)
    (occur-next)
    (occur-prev)
    )
  (let* (
          (pos (occur-mode-find-occurrence))
          window)
    (setq window (display-buffer (marker-buffer pos) t))
    (save-selected-window
      (select-window window)
      (goto-char pos)
      (if occur-overlay (move-overlay occur-overlay pos (point-at-eol))
        (setq occur-overlay (make-overlay pos (point-at-eol))))
      (overlay-put  occur-overlay 'face 'occur-face-target-line)
      (run-hooks 'occur-mode-find-occurrence-hook)))
  )

(declare-function which-func-update "which-func")
(defun occur-which-func-update ()
  "Update `which-func' when `occur-overlay' is selected."
  (eval-when-compile (require 'cl))
  (lexical-let ((ws (list (previous-window) (next-window))))
  ;;  (message "Windows %S" ws) ;debug
    (loop for w in ws
    do
    (with-selected-window w
      (which-func-update))))
  )

(defun occur-next-display ()
  "Select 1 next occur."
  (interactive)
  (occur-display 1)
  (occur-which-func-update)
  )

(defun occur-prev-display ()
  "Select 1 previous occur."
  (interactive)
  (occur-display -1)
  (occur-which-func-update)
  )

(define-key occur-mode-map (kbd "j") 'occur-next-display)
(define-key occur-mode-map (kbd "k") 'occur-prev-display)

(defun my_occur-hooks ()
  " @need improvement
Need to be after 'occur-rename-buffer
shrink-window-if-larger-than-buffer didn't work..., so i have implemented by myself.
shrink-window-if-larger-than-buffer would be sufficient...
"
  (let* (
          (win        (get-buffer-window)) ; require window.el
          (win-height (window-height win)) ; require window.el
          (buf-height (count-lines (point-min) (point-max)))
                                        ;(buf-height (+ 2 (count-lines (point-min) (point-max))))
          )
    (if (> win-height buf-height)(set-window-text-height win buf-height))
    ))

(add-hook 'occur-hook
          (lambda ()
            (save-selected-window
              (pop-to-buffer "*Occur*")
              (fit-window-to-buffer))))

(provide 'my_replace)
;;; my_replace.el ends here
