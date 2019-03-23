;;; my_simple.el ---                                 -*- lexical-binding: t; -*-

;; Copyright (C) 2014

;; Author:  <@> Syunsuke Aki
;; Keywords: simple

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

;; Tried to extend list-processes and list-processes+, but ibuffer may be sufficient.

;;; Code:
(require 'simple)
(require 'dash)

(defvar process-menu-mode-map
  "@dev"
  ;; tabulated-list-mode
  (let ((map (make-sparse-keymap))
        (define-key map )
        )
))

(defvar my_simple--debug nil)
(defun my_simple--debug-log(format &rest args)
  "Write log if `my_simple--debug' is t. FORMAT and ARGS is the same with `message'."
  (when my_simple--debug (apply #'message (concat "[my_simple]" format) args)))

(defvar my_simple--current-buffer nil)
(defvar my_simple--current-point-marker nil)

(defun my_simple--push-mark-for-async ()
  "Save (point-marker) if buffer has surely changed but selected point has not changed.
This case happened in `rtags-find-symbol-at-point'.
Jumping to different buffer by rtags caused no change of (point).
This would be happened by calling back async process."
  (unless (eq my_simple--current-buffer (current-buffer))
    (when (markerp my_simple--current-point-marker)
      (my_simple:push-mark my_simple--current-point-marker)
      )
    (my_simple:push-mark (point-marker))
    )
  (my_simple--debug-log
   "my_simple-jump-c-mode-hook (point-marker,my_simple--current-point-marker)=(%S,%S)"
   (point-marker) my_simple--current-point-marker)
  )

(defvar my_simple:jump-marks-max 256 "Maximum number of marks to be remembered.")
(defvar my_simple:jump-marks nil "Stack of markers for all successful jumps.")
(defun my_simple:push-mark (&optional mark)
  "Push MARK to `my_simple:jump-marks'.
MARK is optional and default to current `point-marker'."
  (interactive (list (mark (point-marker))))
  (setq my_simple:jump-marks (cons mark  my_simple:jump-marks))
  (when (> (length my_simple:jump-marks) my_simple:jump-marks-max)
    (setq my_simple:jump-marks (-take my_simple:jump-marks-max my_simple:jump-marks))
    ))

(defun my_simple:pop-mark ()
  "Pop mark from `my_simple:jump-marks'."
  (interactive)
  ;; Pop entries which refer to non-existent buffers.
  (while (and my_simple:jump-marks (not (marker-buffer (car my_simple:jump-marks))))
    (setq my_simple:jump-marks (cdr my_simple:jump-marks)))
  (catch 'no-mark
    (unless my_simple:jump-marks (message "%S:no more mark" this-command)
      (throw 'no-mark nil))
    (let* ((marker (car my_simple:jump-marks))
            (buffer (marker-buffer marker))
            (position (marker-position marker))
            )
      (setq my_simple:jump-marks (cdr my_simple:jump-marks))
      (switch-to-buffer buffer)
      (goto-char position)
      )))

(global-set-key (kbd "M-I") 'my_simple:pop-mark) ; global-set-key is weaker than XXX-mode-map ?

(defun my_simple-unload-function ()
   (interactive)
   ""
)

(provide 'my_simple)
;;; my_simple.el ends here
