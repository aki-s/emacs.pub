;;; my_pdf-tools.el ---                              -*- lexical-binding: t; -*-

;; Copyright (C) 2016

;; Author:  <@>
;; Keywords: lisp

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

;; Alternative to `doc-view-mode'.
;; (ref. doc-view-mode required command `gsc' of ghostscript.
;; and just view-only
;; )
;;
;;  - Requires 'poppler'
;;  - Need to set PKG_CONFIG_PATH to compile `epdfinfo'

;;; Code:

(require 'package)
(require 'pdf-tools)

(let ((pdfinfo (executable-find "pdfinfo"))
       (epdfinfo (executable-find "epdfinfo"))
       )
  (unless  pdfinfo ; judge that poppler is installed
    (message "[WARN][my_pdf-tools] poppler seems to be not installed, or PATH is incorrect."))
  (unless epdfinfo
    (message "[WARN][my_pdf-tools] Executable `epdfinfo' to be installed by pdf-tools.el is not installed.
Please run `pdf-tools-install'")
    )
  )

(ignore-errors
  ;; Case OSX HomeBrew
  ;; ref. https://github.com/politza/pdf-tools/issues/38
  ;; $ brew tap homebrew/dupes && brew install zlib
  (unwind-protect
    (when (eq system-type 'darwin)
      (when (executable-find "brew")
        (let ((org-pkg-conf-path (getenv "PKG_CONFIG_PATH"))
               (tmp-pkg-conf-path "/usr/local/opt/zlib/lib/pkgconfig"))

          (setenv "PKG_CONFIG_PATH" tmp-pkg-conf-path)
          ;; Compile && install binary `epdfinfo' of pdf-tools. Setup auto-mode-alist
          ;; Compile epdfinfo and enable `pdf-view-mode'
          (pdf-tools-install nil nil t) ;; 2nd arg only works if `apt' is available
          (setenv "PKG_CONFIG_PATH" org-pkg-conf-path))
        ) ; brew
      ) ; darwin
    )
  )

;;------------------------------------------------
;; Unload function:

(defun my_pdf-tools-unload-function ()
  "Unload function to ensure normal behavior when feature 'my_pdf-tools is unloaded."
  (interactive)
  (pdf-tools-uninstall)
  )

(provide 'my_pdf-tools)
;;; my_pdf-tools.el ends here
