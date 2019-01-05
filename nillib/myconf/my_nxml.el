;;; my_nxml.el ---                                   -*- lexical-binding: t; -*-

;; Copyright (C) 2014

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

;;; Code:

(defun imenu--xmlparse-function ()
  "@dev: Generate imenu-index for ECB.
@TBD: 
;;;; ref:
;;;; http://www.emacswiki.org/emacs/XmlParserExamples
;; imenu-create-index-function
"
  (let* ((root (xml-parse-file (expand-file-name "hoge.xml" )))
         (posts (car root))
         (post (xml-node-children posts)))
    (dolist (p post)
      (when (listp p)
        (let ((attrs (xml-node-attributes p)))
          (print (cdr (assoc 'description attrs)))))))
  )

;;------------------------------------------------
;; Unload function:

(defun my_nxml-unload-function ()
  "Unload function to ensure normal behavior when feature 'my_nxml is unloaded."
  (interactive)
  )

(provide 'my_nxml)
;;; my_nxml.el ends here
