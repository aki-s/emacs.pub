;;; my_rtags.el ---                                  -*- lexical-binding: t; -*-

;; Copyright (C) 2019

;; Author:  <>
;; Maintainer:
;; URL:
;; Package-Version: 0.0.0
;; Package-Requires:
;; Keywords:
;; Created: 2019-02-10
;; Updated: 2019-02-11T16:15:31Z; # UTC

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

(require 'rtags)
(require 'flycheck)
(defun my_rtags--setup()
  "Setup `rtags' for C and C++."
  ;; "\C-x r" is already used by rectangle edit.
  (rtags-enable-standard-keybindings c-mode-map "\C-x t")
  (rtags-enable-standard-keybindings c++-mode-map "\C-x t")
  (eval-when-compile (require 'company-rtags))
  (add-to-list 'company-backends 'company-rtags)
  (flycheck-select-checker 'rtags)
  (rtags-start-process-unless-running)
  )

(require 'flycheck-rtags)
(defun my_rtags--flycheck-rtags-setup ()
  "Configure flycheck-rtags for better experience."
  (flycheck-select-checker 'rtags)
  (setq-local flycheck-check-syntax-automatically nil)
  (setq-local flycheck-highlighting-mode nil))

(setq rtags-verbose-results nil) ; `rtags-format-results' (match-end 4) returned nil
(setq rtags-completions-enabled t)
(setq rtags-imenu-syntax-highlighting t)
(setq rtags-tracking t)
(setq rtags-display-current-error-as-tooltip t)
(setq rtags-use-multiple-cursors t)

(require 'helm-rtags)
(setq rtags-display-result-backend 'helm)

(defvar my_rtags--debug nil)
(defun my_rtags--debug-log(format &rest args)
  "Write log if `my_rtags--debug' is t. FORMAT and ARGS is the same with `message'."
  (when my_rtags--debug (apply #'message (concat "[my_rtags]" format) args)))

(defvar my_rtags--current-buffer nil)
(defvar my_rtags--current-point-marker nil)

(require 'my_simple)
(defun my_rtags--my_imenu-jump-hook ()
  "Save (point-marker) if buffer has changed by rtags.
Because jumping to different buffer by rtags cause no change of (point)"
  (unless (eq my_rtags--current-buffer (current-buffer))
    (when (markerp my_rtags--current-point-marker)
      (my_simple:push-mark my_rtags--current-point-marker)
      )
    (my_simple:push-mark (point-marker))
    )
  (my_rtags--debug-log
   "my_rtags-jump-c-mode-hook (point-marker,my_rtags--current-point-marker)=(%S,%S)"
   (point-marker) my_rtags--current-point-marker)
  )
(add-hook 'rtags-after-find-file-hook 'my_rtags--my_imenu-jump-hook)

;;-----------------------------------------
;; Unload function:

(defun my_rtags-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_rtags is unloaded."
   (interactive)
)

(provide 'my_rtags)
;;; my_rtags.el ends here

;; Local variables:
;; eval: (add-hook 'write-file-functions 'time-stamp)
;; time-stamp-start: ";; Updated:"
;; time-stamp-format: " %:y-%02m-%02dT%02H:%02M:%02SZ"
;; time-stamp-line-limit: 13
;; time-stamp-time-zone: "UTC"
;; time-stamp-end: "; # UTC"
;; End:
