;;; my_which-key.el ---                              -*- lexical-binding: t; -*-

;; Copyright (C) 2019

;; Author:  <>
;; Maintainer:
;; URL:
;; Package-Version: 0.0.0
;; Package-Requires:
;; Keywords:
;; Created: 2019-02-10
;; Updated: 2019-02-11T14:12:42Z; # UTC

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

(require 'which-key)
(which-key-mode)
(which-key-setup-side-window-right)
(setq which-key-show-docstrings t)
(setq which-key-max-description-length nil)

;; (which-key-setup-side-window-bottom)
;; (which-key-setup-minibuffer)
;; (setq which-key-popup-type 'side-window)

;; (setq which-key-side-window-max-height 0.8)
;; (setq which-key-side-window-max-width 0.8)
;; (setq which-key-side-window-location 'left)

;;------------------------------------------------
;; Unload function:

(defun my_which-key-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_which-key is unloaded."
   (interactive)
)

(provide 'my_which-key)
;;; my_which-key.el ends here

;; Local variables:
;; eval: (add-hook 'write-file-functions 'time-stamp)
;; time-stamp-start: ";; Updated:"
;; time-stamp-format: " %:y-%02m-%02dT%02H:%02M:%02SZ"
;; time-stamp-line-limit: 13
;; time-stamp-time-zone: "UTC"
;; time-stamp-end: "; # UTC"
;; End:
