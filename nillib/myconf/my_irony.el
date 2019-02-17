;;; my_irony.el ---                                  -*- lexical-binding: t; -*-

;; Copyright (C) 2019

;; Author:  <>
;; Maintainer:
;; URL:
;; Package-Version: 0.0.0
;; Package-Requires:
;; Keywords:
;; Created: 2019-02-10
;; Updated: 2019-02-16T21:42:24Z; # UTC

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

;; irony-mode relies on compile_commands.json file to collect compilation information.
;;
;; $ mkdir build && cd build
;; $ cmake -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ../src

;;; Code:
(require 'irony)
(require 'irony-eldoc)
(add-hook 'irony-mode-hook 'irony-eldoc)

(defun my_irony--setup()
  "Setup `irony'."
  (eval-when-compile (require 'company))
  (add-to-list 'company-backends 'company-irony)
  (irony-cdb-autosetup-compile-options)
  (irony-mode)

  (require 'flycheck-irony)
  (flycheck-irony-setup)
  )

;;------------------------------------------------
;; Unload function:

(defun my_irony-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_irony is unloaded."
   (interactive)
)

(provide 'my_irony)
;;; my_irony.el ends here

;; Local variables:
;; eval: (add-hook 'write-file-functions 'time-stamp)
;; time-stamp-start: ";; Updated:"
;; time-stamp-format: " %:y-%02m-%02dT%02H:%02M:%02SZ"
;; time-stamp-line-limit: 13
;; time-stamp-time-zone: "UTC"
;; time-stamp-end: "; # UTC"
;; End:
