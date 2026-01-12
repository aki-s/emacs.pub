;;; my_ivy-migemo.el ---                             -*- lexical-binding: t; -*-

;; Copyright (C) 2026

;; Author:  <>
;; Maintainer:
;; URL:
;; Package-Version: 0.0.0
;; Package-Requires:
;; Keywords: lisp
;; Created: 2026-01-03
;; Updated: 2026-01-03T07:50:10Z; # UTC

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
(use-package ivy-migemo
  :config
  (define-key ivy-minibuffer-map (kbd "M-f") #'ivy-migemo-toggle-fuzzy)
  (define-key ivy-minibuffer-map (kbd "M-m") #'ivy-migemo-toggle-migemo)

  ;; If you want to defaultly use migemo on swiper and counsel-find-file:
  (setq ivy-re-builders-alist '((t . ivy--regex-plus)
                                (swiper . ivy-migemo-regex-plus)
                                (counsel-find-file . ivy-migemo-regex-plus))
                                        ;(counsel-other-function . ivy-migemo-regex-plus)
        )
  )
;;------------------------------------------------
;; Unload function:

(defun my_ivy-migemo-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_ivy-migemo is unloaded."
   (interactive)
)

(provide 'my_ivy-migemo)
;;; my_ivy-migemo.el ends here

;; Local variables:
;; eval: (add-hook 'write-file-functions 'time-stamp)
;; time-stamp-start: ";; Updated:"
;; time-stamp-format: " %:y-%02m-%02dT%02H:%02M:%02SZ"
;; time-stamp-line-limit: 13
;; time-stamp-time-zone: "UTC"
;; time-stamp-end: "; # UTC"
;; End:
