;;; my_spaceline-all-the-icons.el ---                -*- lexical-binding: t; -*-

;; Copyright (C) 2019

;; Author:  <>
;; Maintainer:
;; URL:
;; Package-Version: 0.0.0
;; Package-Requires:
;; Keywords:
;; Created: 2019-04-27
;; Updated: 2019-04-28T12:32:44Z; # UTC

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
(require 'use-package)

(use-package powerline
  :config
  (powerline-default-theme))

(use-package spaceline-config
  :config
  (spaceline-emacs-theme))

(use-package spaceline
  :config
  ;; ref. http://stackoverflow.com/questions/8190277/how-do-i-display-the-total-number-of-lines-in-the-emacs-modeline
  (defvar-local my_spaceline-buffer-line-count nil)
  (defun my_spaceline--count-lines ()
    (setq my_spaceline-buffer-line-count
          (int-to-string (count-lines (point-min) (point-max)))))

  (spaceline-define-segment my_input-info
    "Line & Total lines & Column indicator"
    (propertize (format-mode-line (concat current-input-method-title "%Z" my_spaceline-buffer-line-count ":%2c"))
                'face `(:height ,(spaceline-all-the-icons--height 0.9) :inherit)
                'display '(raise 0.1))
    :tight t)

  :hook ((find-file after-save after-revert dired-after-readin)
         . 'my_spaceline--count-lines))

(use-package spaceline-all-the-icons
  :after (powerline spaceline spaceline-config)
  :config
  (setq spaceline-all-the-icons-clock-always-visible nil)
  (setq spaceline-always-show-segments t)
  (setq spaceline-highlight-face-func #'spaceline-highlight-face-evil-state)
  (set-face-attribute
   'mode-line nil
   :background "gray15"
   :foreground "SpringGreen"
   :weight 'ultra-bold
   )
  (defconst my_spaceline-all-the-icons-theme
    '("%e" (:eval (progn (my_spaceline-dynaic-width)
                         (spaceline-ml-my_all-the-icons)))))
  (defun my_spaceline-dynaic-width ()
    "ref. I may use `spaceline-pre-hook'."
    (if (> (window-width) 90)
        (setq spaceline-all-the-icons-slim-render nil)
      (setq spaceline-all-the-icons-slim-render t)))
  (defun my_spaceline-all-the-icons-theme ()
    "Install the `spaceline-ml-my_all-the-icons'."
    (interactive)
    (spaceline-compile
      "my_all-the-icons"
      ;; left
      '(((all-the-icons-anzu
         all-the-icons-multiple-cursors)
         :face 'mode-line
         :skip-alternate t)

        (my_input-info)

        ((all-the-icons-modified
          all-the-icons-bookmark
          all-the-icons-dedicated
          all-the-icons-eyebrowse-workspace
          ) :face highlight-face :skip-alternate t)

        ((all-the-icons-projectile
         all-the-icons-mode-icon
         ((all-the-icons-buffer-path
           all-the-icons-buffer-id) :separator "")))

        ((all-the-icons-process
          all-the-icons-fullscreen
          all-the-icons-text-scale
          all-the-icons-narrowed)
         :face highlight-face
         :separator (spaceline-all-the-icons--separator spaceline-all-the-icons-primary-separator " "))

        ((all-the-icons-vc-icon
          all-the-icons-vc-status
          ((all-the-icons-git-ahead
            all-the-icons-git-status) :separator " ")
          ((all-the-icons-flycheck-status
            all-the-icons-flycheck-status-info) :separator " ")
          all-the-icons-package-updates)
         :separator (spaceline-all-the-icons--separator spaceline-all-the-icons-secondary-separator " "))

        ((all-the-icons-separator-minor-mode-left
          all-the-icons-minor-modes
          all-the-icons-separator-minor-mode-right)
         :tight t
         :face highlight-face
         :when spaceline-all-the-icons-minor-modes-p))
      ;; right
      '(((all-the-icons-org-clock-current-task
          all-the-icons-battery-status
          all-the-icons-time)
         :separator (spaceline-all-the-icons--separator spaceline-all-the-icons-primary-separator " ")
         :face default-face)))
      (setq-default mode-line-format my_spaceline-all-the-icons-theme))
  (my_spaceline-all-the-icons-theme)
  )

;;------------------------------------------------
;; Unload function:

(defun my_spaceline-all-the-icons-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_spaceline-all-the-icons is unloaded."
   (interactive)
)

(provide 'my_spaceline)
;;; my_spaceline-all-the-icons.el ends here

;; Local variables:
;; eval: (add-hook 'write-file-functions 'time-stamp)
;; time-stamp-start: ";; Updated:"
;; time-stamp-format: " %:y-%02m-%02dT%02H:%02M:%02SZ"
;; time-stamp-line-limit: 13
;; time-stamp-time-zone: "UTC"
;; time-stamp-end: "; # UTC"
;; End:
