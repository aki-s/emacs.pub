;;; my_symbol-overlay.el ---                         -*- lexical-binding: t; -*-

;; Copyright (C) 2019

;; Author:  <>
;; Maintainer:
;; URL:
;; Package-Version: 0.0.0
;; Package-Requires:
;; Keywords:
;; Created: 2019-05-25
;; Updated: 2019-05-26T11:20:44Z; # UTC

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
(use-package symbol-overlay
  :config
  (global-set-key (kbd "M-s h") 'symbol-overlay-put)
  (global-set-key (kbd "M-s o") 'my_replace-symbol-occur)
  ;; Disable `symbol-overlay-map-help' for `evil-backward-char'
  (define-key symbol-overlay-map (kbd "h") nil)
  (define-key symbol-overlay-map (kbd "o") 'my_replace-symbol-occur))

;;------------------------------------------------
;; Unload function:

(defun my_symbol-overlay-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_symbol-overlay is unloaded."
   (interactive)
)

(provide 'my_symbol-overlay)
;;; my_symbol-overlay.el ends here

;; Local variables:
;; eval: (add-hook 'write-file-functions 'time-stamp)
;; time-stamp-start: ";; Updated:"
;; time-stamp-format: " %:y-%02m-%02dT%02H:%02M:%02SZ"
;; time-stamp-line-limit: 13
;; time-stamp-time-zone: "UTC"
;; time-stamp-end: "; # UTC"
;; End:
