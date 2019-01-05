;;; package --- my_flycheck.el

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
(require 'flycheck)

;;--------------------------------------------------------------------------------
;; Basic func
;;--------------------------------------------------------------------------------
(defun my_flycheck-keybind ()
  "Append keybinding if flycheck is enabled."
  (interactive)
  (when flycheck-mode  ; (boundp nil) returns t
    (local-set-key (kbd "M-P") 'flycheck-previous-error)
    (local-set-key (kbd "M-N") 'flycheck-next-error)
    )
  )

(add-hook 'after-init-hook #'global-flycheck-mode)
(add-hook 'find-file-hook #'my_flycheck-keybind t)

(defvar my_flycheck-debug nil "Flag for debug message.")
(defun toggle-my_flycheck-debug ()
  (interactive)
  (if my_flycheck-debug
    (setq my_flycheck-debug nil)
    (setq my_flycheck-debug t)
    )
  (message "Set my_flycheck-debug to %s" my_flycheck-debug)
  )

;;--------------------------------------------------------------------------------
;; Macro
;;--------------------------------------------------------------------------------
;; http://stackoverflow.com/questions/15585133/elisp-macro-passing-by-symbol-instead-of-list
;; https://github.com/flycheck/flycheck
(defmacro flycheck-define-clike-checker (name command modes)
  (let ((command (eval command)))
    `(flycheck-declare-checker ,(intern (format "flycheck-checker-%s" name))
       ,(format "A %s checker using %s" name (car command))
       :command '(,@command source-inplace)
       :error-patterns
       '(("^\\(?1:.*\\):\\(?2:[0-9]+\\):\\(?3:[0-9]+\\): error: \\(?4:.*\\)$"
           error)
          ("^\\(?1:.*\\):\\(?2:[0-9]+\\):\\(?3:[0-9]+\\): warning: \\(?4:.*\\)$"
            warning))
       :modes ',modes)))

(require 'flycheck-pos-tip)
(custom-set-variables
  '(flycheck-display-errors-function #'flycheck-pos-tip-error-messages))
(setq flycheck-pos-tip-timeout 20)

;;--------------------------------------------------------------------------------
;; C/C++
;;--------------------------------------------------------------------------------

(defun my_flycheck-set-clang-std (version)
  "Set `flycheck-clang-language-standard'."
  (interactive
    (list (read-from-minibuffer (format "e.g. c++11 (current:%S)" flycheck-clang-language-standard))))
  (setq flycheck-clang-language-standard version)
  )
;;
;; (if (string< "3.3" (clang_version "clang++"))
;;              (setq-default flycheck-clang-language-standard "c++11") ; buffer-local
;;              )

(defun my_flycheck-cc-include ()
  "Flycheck include path for c/c++ mode."
  (interactive)
  (setq flycheck-clang-include-path
    (append
      ;; From shell env
      (split-string (or (getenv "INCLUDE") "") ":" t)
      ;; From system specific
      (let ((inc (intern (concat "my_flycheck-cc-include-" (symbol-name system-type)))))
        ;; my_flycheck-cc-include-gnu/linux
        (if (and (boundp inc) inc )
          (symbol-value inc)
          )
        )
      )))
(defvar my_flycheck-cc-include-darwin '("/opt/local/include/")
  "List of include directory for MacOSX.")

(add-hook 'c-mode-hook   'my_flycheck-cc-include)
(add-hook 'c++-mode-hook 'my_flycheck-cc-include)


;;--------------------------------------------------------------------------------
;; SCSS
;;--------------------------------------------------------------------------------

;; (defvar flycheck-sass-load-path nil)
(flycheck-def-option-var flycheck-sass-load-path nil sass
  ""
  :package-version '(my_flycheck . "")
  )

;;@dev
(setq flycheck-sass-load-path
  (let (p (getenv "SASS_PATH"))
    (if p p ""))
  )

(defun sass-get-import-from-buffer  ()
  ""
  (interactive)
  (mapconcat #'(lambda (x) (concat "--load-path " x) )
    (sass-get-full-path
      (sass-search-import-from-buffer (current-buffer))) " ")
  )

(defun sass-get-full-path (list)
  "Get full path of the gem for each element of list."
  (mapcar #'(lambda (x)
              (apply 'start-process "sass-get-full-path" "*sass-get-full-path*" "bundle" `("show" ,x) )
              ) list )
  )

(defun sass-search-import-from-buffer (buf)
  "Create list of import from buffer BUF.
Return list of import.
This function doesn't consider if @import is inside comment statement or not."
  (interactive (list (current-buffer)))
  (with-current-buffer buf
    (save-excursion
      (goto-char (point-min))
      (let ((libs '()))
        (while (not (eobp))
          (let* ((line (buffer-substring-no-properties (point) (point-at-eol)))
                  (idx
                    (string-match
                      "@import[\t ]+\\([\'\"-_A-Za-z0-9]+\\)[\t ]*;"
                      line))
                  )
            (when idx
              (push (match-string 1 line) libs)
              )
            )
          (beginning-of-line 2))
        libs)
      )))
;;  config/initializers/sass.rb
;; bundle list --paths
;; $ find  `rbenv prefix`/lib/ruby/gems/[0-9].[0-9].[0-9]/gems/ -name assets

(flycheck-define-checker sass
  "Overwrited default.
@dev
Impl. idea 1
(setf (plist-get :command) ...)
"
  :command ("sass"
            "--cache-location" (eval (flycheck-sass-scss-cache-location))
            (option-flag "--compass" flycheck-sass-compass)
            ;;(option-flag "--load-path " flycheck-sass-load-path)
(eval (sass-get-import-from-buffer))
"-c" source)
:error-patterns
((error line-start "Syntax error on line " line ": " (message))
  (warning line-start "WARNING on line " line " of " (file-name)
    ":" (optional "\r") "\n" (message) line-end)
  (error line-start
    "Syntax error: "
    (message (one-or-more not-newline)
      (zero-or-more "\n"
        (one-or-more " ")
        (one-or-more not-newline)))
    (optional "\r") "\n        on line " line " of " (file-name)
    line-end))
:modes sass-mode)


;;--------------------------------------------------------------------------------
;; Java
;;--------------------------------------------------------------------------------

(defun my_java-get-package-name (&optional buf)
  ""
  (interactive)
  (save-excursion
    (unless buf (setq buf (current-buffer)))
    (set-buffer buf)
    (goto-char (point-min))
    (let ((case-fold-search nil)
           (regexp "^[\\s ]*package[\\s ]+\\([a-zA-Z_0-9]+\\(\\.[a-zA-Z_0-9]+\\)*\\)")
           )
      (if (re-search-forward regexp nil t)
        (progn
          (match-string-no-properties 1)
          )))))
(defun my_java-get-package-as-dir-format (pkg)
  "Just replace \\.   of PKG with /."
  (if pkg (replace-regexp-in-string "\\." "/" pkg)
    nil)
  )

(defun my_java-get-pkgroot-dir ()
  "Return package root for a java file.
If no package is found, return `default-directory'"
  (interactive)
  (save-excursion
    (let* ( (buf (current-buffer))
            (fname (buffer-file-name buf))
            (pkg (my_java-get-package-name buf))
            )
      (if fname
        (if pkg
          (substring-no-properties
            buffer-file-name nil
            (string-match
              (my_java-get-package-as-dir-format pkg)
              buffer-file-name
              ))
          default-directory
          )
        (message "no file for buffer %s" buf)
        ))))

(require 'xml)
(eval-when-compile
  (require 'cl-lib) ; `cl-defstruct'
  (require 'cl) ; incf
  )

(defvar-local my_flycheck-pom nil)

;; (cl-defstruct (pom)
;;   (:constructor par-new)
;;   lib
;;   )
;; (defun my_java-parse-pom.xml (fname)
;;   "@dev"
;;   (if (file-exists-p fname)
;;       (setq pom (xml-parse-file fname))
;;     )
;;   (pom-new :lib )
;;   )

(cl-defstruct (eclipse-classpath
                (:constructor eclipse-classpath-new))
  eclipse-prj-root ; where .classpath is located
  con ; container
  lib ; lib
  path2output ; mapper between file path to output directory
  )
;;tmp (make-variable-buffer-local eclipse-classpath)

(defvar-local eclipse-classpath nil)

(defun my_java-parse-.classpath (fname)
  "Parse a FILE of eclipse format and update environmental variable CLASSPATH
FNAME is .classpath file of eclipse format and must be absolute path.
Return struct eclipse-classpath.
"
  (let*  (
           (xml (xml-parse-file fname))
           (xnn (xml-node-name xml))
           (xnc (xml-node-children xnn))
           (x 0)
           (root (file-name-directory fname))
           con
           lib
           path2output
           )
    (dolist (e xnc)
      (when (and (listp e) (equal (car e) 'classpathentry))
        (incf x)
        ;; destructuring-bind
        ;;        (message "%S" (cdr (caadr e)))
        ;;        (setq value (cdar (cdadr e)))
        (let (
               (ekind (xml-get-attribute-or-nil e 'kind))
               (epath (xml-get-attribute-or-nil e 'path))
               )
          (pcase ekind
            ("src" ; -sourcepath
              (add-to-list 'path2output (cons epath (xml-get-attribute-or-nil e 'output)))
              (message "[%02d]%s|%s" x ekind epath)
              )
            ("lib" ; -classpath CLASSPATH
              (add-to-list 'lib epath)
              (message "[%02d]%s|%s" x ekind epath)
              )
            ("output" ; -d
              (message "[%02d]%s|%s" x ekind epath)
              (add-to-list 'path2output (cons t epath))
              )
            ("con"
              (cond ((string= "org.eclipse.m2e.MAVEN2_CLASSPATH_CONTAINER" epath)
                      (cond
                        ((getenv "org.eclipse.m2e.MAVEN2_CLASSPATH_CONTAINER")
                          ;; @TBD
                          ;; (parse-container) ;
                          )
                        ((getenv "M2_REPO")
                          (let ((m2 (getenv "M2_REPO")))
                            (add-to-list 'con m2)
                            ;;@todo my_java-parse-pom.xml
                            (let* ((pom (xml-parse-file  (concat root "/pom.xml") ))
                                    (post (xml-node-children (car pom)))
                                    (jar "")
                                    )
                              (dolist (p post)
                                (when (and (listp p) (equal (car p) 'dependencies))
                                  (let ((deps (xml-node-children p))
                                         )
                                    (dolist (d deps)
                                      (when (listp d)
                                        (let* (
                                                (c (xml-node-children d))
                                                (gid (caddr (assoc 'groupId c)))
                                                (id (caddr (assoc 'artifactId c)))
                                                (ver (caddr (assoc 'version c)))
                                                (pkg-dir (replace-regexp-in-string "\\." "/" gid))
                                                (jar (concat m2 "/" pkg-dir "/" id "/" ver "/" id "-" ver ".jar"))
                                                )
                                          (message "%S" (concat pkg-dir "/" id "/" ver "/" id "-" ver ".jar"))
                                          ;;
                                          (add-to-list 'lib jar)
                                          ;;
                                          ))
                                      )
                                    )
                                  )))
                            ))
                        (t
                          (error "No definition found for environmental variable. M2_REPO")
                          )
                        );cond
                      )
                )
              )
            ("excluding"
              ;; @TBD
              )
            ("maven.pomderived" ; Flag that .classpath is subordinate to pom.xml.
              ;; delegate to pom.xml
              )
            (t
              ;;(message "t\n")
              )
            )
          ) ;let
        ) ;when
      ) ;dolist
    (setq eclipse-classpath (eclipse-classpath-new :eclipse-prj-root (file-name-directory fname)
                              :con con
                              :lib lib
                              :path2output path2output
                              ))
    eclipse-classpath);let
  )


(defvar my_java-cache-dir "/tmp/emacs" "Output directory of class files by java checker.")

(flycheck-define-checker java
  "Java must consider 'package xx.yy.zz' to compile a file.
Need to keep directory structure.
"
  :command (
             "my_java-lint" ; $1
             (eval
               (let* ( (prjroot (or
                                  (my_java-get-pkgroot-dir)
                                  (locate-dominating-file default-directory ".classpath") ; src lib output
                                  (locate-dominating-file default-directory "build.xml") ; <path id="classpath">, org.eclipse.jst.j2ee.internal.web.container
                                  (locate-dominating-file default-directory "pom.xml")
                                  (locate-dominating-file default-directory ".project")
                                  ;; (locate-dominating-file "." ".git")
                                  ))
                       (pkg (my_java-get-package-name))
                       (pkg-dir-form (my_java-get-package-as-dir-format pkg))
                       ;; (fp (concat prjroot "/.pom.xml"))
                       (fc (concat prjroot "/.classpath"))
                       ;; data-pom
                       data-cpath
                       cpath
                       (outdir my_java-cache-dir)
                       cmd-opts ;; (nth N cmd-opts) is equivalent to $N for shell argument.
                       )
                 (if pkg-dir-form (setq pkg-dir-form (concat "/" (my_java-get-package-as-dir-format pkg))))
               ;;;; respect eclipse classpath
                 (if (file-exists-p fc)
                   (progn
                     (if my_flycheck-debug (message ".classpath is %S" fc))
                     (setq data-cpath (my_java-parse-.classpath fc))
                     (if my_flycheck-debug (message "eclipse-classpath is %S" data-cpath))
                     (setq cpath (mapconcat 'cdr (eclipse-classpath-path2output data-cpath) ":"))
                     (let ((dir (assoc pkg-dir-form (eclipse-classpath-path2output data-cpath))))
                       (if dir (setq outdir (concat outdir "/" (cdr dir)))
                         (setq outdir (concat outdir "/" (cdr (assoc 't (eclipse-classpath-path2output data-cpath)))))
                         ))
                     (if data-cpath
                       (setq cpath (concat cpath ":" (mapconcat 'identity (eclipse-classpath-lib data-cpath) ":"))))
                     ))
               ;;;;
                 (if pkg-dir-form
                   (let ((dir (concat outdir "/" pkg-dir-form)))
                     (setq outdir dir)
                     )
                   )
               ;;;;
                 (setq cmd-opts (list "-r" prjroot))
                 (make-directory outdir t)
                 ;;    (setq cmd-opts (append cmd-opts '("-c") (list cpath) '("-d") (list outdir) ))
                 (setq cmd-opts (append cmd-opts (if cpath '('("-c") (list cpath))) '("-d") (list outdir) ))
                 (if my_flycheck-debug (message "my_flycheck|cmd-opts:%S|tmpfiles:%S" cmd-opts flycheck-temporaries))
                 cmd-opts);let
               );eval ; $2
             ;;            source ; $3
             source-original ; $3
             ;;            source-inplace ; $3
             )
  :next-checkers
  ((t . java-checkstyle)); TBD Separate javac and checkstyle.
  :modes (java-mode)
  ;; :predicate (lambda () (flycheck-buffer-saved-p))
  :error-patterns ; May depends on Java version?
  (
;;    (error   line-start (file-name) ":" line ":" column ": error:" (message) line-end
                                        ;(and "\n" any line-end "\n[ ]*^" line-end)) ; error message is parsed line by line
 ;;     )
    (error   line-start (file-name) ":" line (zero-or-one ":" column) ": error:" (message) line-end)

    (warning line-start (file-name) ":" line ":" column ": warning:" (message) line-end)
    (info line-start (file-name) ":" line ":" column ":checkstyle>" (message) line-end)
    )
  )

(add-to-list 'flycheck-checkers 'java)

(flycheck-define-checker java-checkstyle
  ""
  :command ("my_java-checkstyle"
             source)
  :error-parser flycheck-parse-checkstyle
  :error-filter ; change 'error to 'info
  (lambda (errors)
    (let ((errors (flycheck-sanitize-errors errors)))
      (dolist (err errors)
        (setf (flycheck-error-level err) 'info)
        )
      )
    errors)
  :modes java-mode
  )
(add-to-list 'flycheck-checkers 'java-checkstyle t) ;; flycheck-define-checker didn't add-to-list. If not in the list, the checker cannot be run.
;; (flycheck-add-next-checker 'java 'java-checkstyle) ;;$;; needless because already defined at :next-checkers

;;--------------------------------------------------------------------------------
;; Scala
;;--------------------------------------------------------------------------------

(defvar scalac-opt "-feature -deprecation -unchecked -Xlint:_ -Ywarn-dead-code -Ywarn-numeric-widen -Ywarn-unused -Ywarn-unused-import"
  "Option for scalac version 2.11.7.")

(defvar flycheck-cache-dir:default "/tmp/" "@dev Global cache directory when project specific cache directory was not found.")
(defvar flycheck-scala-cache-dir nil "@dev Cache directory which is set dynamically.")

(flycheck-define-checker scala
  "A Scala syntax checker using the Scala compiler (option is overwrided by user).

See URL `http://www.scala-lang.org/'.
@bug ; library lookup is not work well? e.g. akka.actor._ is O.K. but akka.stream.Materializer fails.
@bug ; Contaminate src dir with class files. use -d option to fix.
Root is directory where build.sbt exists, or where `project' directory exists.
Get project config via `$ sbt classDirectory'
@todo
define-checker -> judge project type -> handle each-project type && return general config -> set config
@note ; projectile.el may do this?
"
  :command ("scalac" (eval (concatenate 'list (split-string scalac-opt)
                             `("-d" ,(setq flycheck-scala-cache-dir flycheck-cache-dir:default))))
             source)
  :error-patterns
  ((error line-start (file-name) ":" line ": error: " (message) line-end))
  :modes scala-mode
  :next-checkers ((warning . scala-scalastyle)))

;;; OSX homebrew scalastyle
(setq flycheck-scalastyle-jar "/usr/local/Cellar/scalastyle/0.7.0/libexec/scalastyle_2.11-0.7.0-batch.jar")
(setq flycheck-scalastylerc "/usr/local/etc/scalastyle_config.xml")

;;------------------------------------------------
;; Unload function:

(defun my_flycheck-unload-function ()
  "Unload function for my_flycheck.el."
  (interactive)
  (local-unset-key (kbd "M-P"))
  (local-unset-key (kbd "M-N"))
  (remove-hook 'find-file-hook 'my_flycheck-keybind)
  )

(setq-default flycheck-emacs-lisp-load-path load-path)

(provide 'my_flycheck)
;;; my_flycheck.el ends here
