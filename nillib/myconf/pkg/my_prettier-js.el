;;; my_prettier-js.el ---                            -*- lexical-binding: t; -*-

;; Copyright (C) 2019

;; Author:  <>
;; Package-Version: 0.0.0
;; Package-Requires:
;; Keywords:
;; Created: 2019-01-05

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
(require 'prettier-js)

(defun my_prettier-js:enable-minor-mode (my-pair)
  "Enable minor mode if filename match the regexp.  MY-PAIR is a cons cell (regexp . minor-mode)."
  (if (buffer-file-name)
      (if (string-match (car my-pair) buffer-file-name)
      (funcall (cdr my-pair)))))

;;------------------------------------------------
;; Unload function:

(defun my_prettier-js-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_prettier-js is unloaded."
   (interactive)
)

(provide 'my_prettier-js)
;;; my_prettier-js.el ends here
