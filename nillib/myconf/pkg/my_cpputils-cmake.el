;;; my_cpputils-cmake.el ---                         -*- lexical-binding: t; -*-

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

;; https://github.com/redguardtoo/cpputils-cmake
;; CMakeLists.txt

;;; Code:
(require 'cpputils-cmake)

(setq cppcm-debug t)
(cppcm-reload-all)

(defun my_cpputils-cmake-hook()
  (cppcm-reload-all)
  )

(add-hook 'c-mode-hook 'my_cpputils-cmake-hook);;; @todo move to client file
(add-hook 'c++-mode-hook 'my_cpputils-cmake-hook);;; @todo move to client file

;;------------------------------------------------
;; Unload function:

(defun my_cpputils-cmake-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_cpputils-cmake is unloaded."
   (interactive)
)

(provide 'my_cpputils-cmake)
;;; my_cpputils-cmake.el ends here
