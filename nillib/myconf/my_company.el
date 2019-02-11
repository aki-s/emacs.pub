;;; my_company.el ---                                -*- lexical-binding: t; -*-

;; Copyright (C) 2017

;; Author:  <@>
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
(require 'company)
(global-company-mode 1)
(global-set-key (kbd "C-S-o") 'company-complete)
(setq company-idle-delay 0.5)
(setq company-require-match nil)
(define-key company-active-map (kbd "C-n") 'company-select-next)
(define-key company-active-map (kbd "C-p") 'company-select-previous)
(define-key company-search-map (kbd "C-n") 'company-select-next)
(define-key company-search-map (kbd "C-p") 'company-select-previous)
(define-key company-active-map (kbd "<tab>") 'company-complete-selection)

(require 'company-c-headers)
(add-to-list 'company-backends 'company-c-headers)

;;; Code:

;;------------------------------------------------
;; Unload function:

(defun my_company-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_company is unloaded."
   (interactive)
)

(provide 'my_company)
;;; my_company.el ends here
