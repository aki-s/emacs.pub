;;; package: --- my_autoinsert.
;;; Commentary:
;; autoinsert use 'skeleton.el::skeleton-read internally.
;;; Code:
;; /* http://d.hatena.ne.jp/higepon/20080731/1217491155 */
(require 'autoinsert)
(setq auto-insert-directory "~/.emacs.d/share/insert/")
(setq auto-insert-query t) ; ask whether insert or not.
(add-hook 'find-file-not-found-functions 'auto-insert)
;;temp (defun my_auto-insert ()
;;temp   "Forced to return t to avoid failure in `find-file-not-found-functions'
;;temp Since emacs 24.5.1"
;;temp   (auto-insert)
;;temp   t)
;;temp (add-hook 'find-file-not-found-functions 'my_auto-insert)

;;;; http://blog.livedoor.jp/sparklegate/archives/50227481.html
;;;; http://www.gfd-dennou.org/member/uwabami/cc-env/Emacs/init-autoinsert.html
;;;; http://d.hatena.ne.jp/higepon/20080731/1217491155
;;;; http://www.02.246.ne.jp/~torutk/cxx/emacs/mode_extension.html
;;;; http://stackoverflow.com/questions/433194/starting-any-emacs-buffer-with-a-c-extension-with-a-template
;;; Select template according to each file.

;;;;======================================================================
;;;; RELPACE DEFAULT TEMPLATE 1
;;;;======================================================================

(setq auto-insert-alist
      (nconc '(
               ("\\.c$"     . ["template.c"  my-template])
               ("\\.cpp$"   . ["template.cpp" my-template])
               ("\\.h$"     . ["template.h" my-template])
               ("\.rb$"     . ["rb" my-template])
               ("\.html$"   . ["html" my-template])
               ("\.rhtml$"  . ["rhtml" my-template])
               ) auto-insert-alist))

(eval-when-compile (require 'cl))

;;;; define MACRO
(defvar template-replacements-alists
  '(
    ("%file%"             . (lambda () (file-name-nondirectory (buffer-file-name))))
    ("%file-without-ext%" . (lambda () (setq file-without-ext (file-name-sans-extension (file-name-nondirectory (buffer-file-name))))))
    ;;    ("%bdesc%" . (lambda () (read-from-minibuffer "Brief description: ")))
                                        ;    (cond ((char-equal (\\("cpp"\\|"c++"\\)) (file-name-extension (buffer-file-name)));; .cpp
                                        ;    (cond ((string-equal "cpp" (file-name-extension (buffer-file-name)))
    ("%namespace%" . (lambda ()
                       (cond
;;                        ((string-equal "cpp" (file-name-extension (buffer-file-name)))
;;                         (setq namespace (read-from-minibuffer "namespace: ")))
                        (t ;;default
                         (setq namespace "")
                         (message "not cpp"))
                        )))
    ("%include%" .
     (lambda ()
       (cond ((string= namespace "") (concat "\"" file-without-ext ".h\""))
             (t (concat "<" (replace-regexp-in-string "::" "/" namespace) "/"
                        file-without-ext ".h>")))))
    ("%include-guard%" .
     (lambda ()
       (format "%s_H_"
               (upcase (concat
                        (replace-regexp-in-string "::" "_" namespace)
                        (unless (string= namespace "") "_")
                        file-without-ext)))))
    ;;    ("%include-guard%"    . (lambda () (format "__SCHEME_%s__" (upcase (file-name-sans-extension (file-name-nondirectory buffer-file-name))))))
                                        ;$;    ("%name%" . user-full-name)
                                        ;$;    ("%mail%" . (lambda () (identity user-mail-address)))
    ("%cyear%" . (lambda () (substring (current-time-string) -4)))
    ("%namespace-open%" .
     (lambda ()
       (cond ((string= namespace "") "")
             (t (progn
                  (setq namespace-list (split-string namespace "::"))
                  (setq namespace-text "")
                  (while namespace-list
                    (setq namespace-text (concat namespace-text "namespace "
                                                 (car namespace-list) " {\n"))
                    (setq namespace-list (cdr namespace-list))
                    )
                  (eval namespace-text))))))
    ("%namespace-close%" .
     (lambda ()
       (cond ((string= namespace "") "")
             (t (progn
                  (setq namespace-list (reverse (split-string namespace "::")))
                  (setq namespace-text "")
                  (while namespace-list
                    (setq namespace-text (concat namespace-text "} // " (car namespace-list) "\n"))
                    (setq namespace-list (cdr namespace-list))
                    )
                  (eval namespace-text))))))
    ))

;;;; expand MACRO
(defun my-template ()
  (time-stamp)
  (mapc #'(lambda(c)
            (progn
              (goto-char (point-min))
              (replace-string (car c) (funcall (cdr c)) nil)))
        template-replacements-alists)
  ;;  (goto-char (point-max))
  ;;  (goto-char (+ 3 (point-min)))
  (goto-line 2)
  (message "autoinsert done."))

;;;;======================================================================
;;;; RELPACE DEFAULT TEMPLATE by skelton#skelton-insert
;;;;======================================================================

(defvar my_autoinsert-elisp nil)
(setq my_autoinsert-elisp
      '(
     "Short description: "
     ";;; " (file-name-nondirectory (buffer-file-name)) " --- " str
     (make-string (max 2 (- 80 (current-column) 27)) ?\s)
     "-*- lexical-binding: t; -*-"
     "

;; Copyright (C) " (format-time-string "%Y")
 (getenv "ORGANIZATION") | (progn user-full-name) "

;; Author: " (user-full-name)
'(if (search-backward "&" (line-beginning-position) t)
     (replace-match (capitalize (user-login-name)) t t))
'(end-of-line 1) " <" (progn user-mail-address) ">
;; Maintainer:
;; URL:
;; Package-Version: 0.0.0
;; Package-Requires:
;; Keywords: "
 '(require 'finder)
 ;;'(setq v1 (apply 'vector (mapcar 'car finder-known-keywords)))
 '(setq v1 (mapcar (lambda (x) (list (symbol-name (car x))))
           finder-known-keywords)
    v2 (mapconcat (lambda (x) (format "%12s:  %s" (car x) (cdr x)))
       finder-known-keywords
       "\n"))
 ((let ((minibuffer-help-form v2))
    (completing-read "Keyword, C-h (C-RTET to finish using helm): " v1 nil nil nil nil ""))
    str ", ") & -2 "
;; Created: "(format-time-string "%Y-%m-%d")"
;; Updated: ; # UTC

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

;; " _ "

;;; Code:

;;------------------------------------------------
;; Unload function:

\(defun "(file-name-base)"-unload-function ()
   \"Unload function to ensure normal behavior when feature '"(file-name-base)" is unloaded.\"
   (interactive)
)

\(provide '"
       (file-name-base)
       ")
;;; " (file-name-nondirectory (buffer-file-name)) " ends here\n"
"
;; Local variables:
;; eval: (add-hook 'write-file-functions 'time-stamp)
;; time-stamp-start: \";; Updated:\"
;; time-stamp-format: \" %:y-%02m-%02dT%02H:%02M:%02SZ\"
;; time-stamp-line-limit: 13
;; time-stamp-time-zone: \"UTC\"
;; time-stamp-end: \"; # UTC\"
;; End:
")
) ;; my_autoinsert-elisp

(setf (cdr (assoc '("\\.el\\'" . "Emacs Lisp header") auto-insert-alist)) my_autoinsert-elisp)

(provide 'my_autoinsert)
;;; my_autoinsert.el ends here
