;;; package: --- my_java.el ---
;;; Commentary:
;;; Code:
(require 'cc-mode)
(require 'deferred)

(setq deferred:debug t)
(setq deferred:debug-on-signal t)

(defvar my_java-javadoc-urls nil)

(defvar anything-c-source-my_java-javadoc
  '( (name . "my_java-javadoc")
     (candidates . my_java-javadoc-urls)
     (action . w3m-goto-url-new-session)
     )
  "TBD: create buffer or reuse w3m buffer to display URL.")

(defun my_java-set-class-url (SRC TARGET)
  (if (equal "" TARGET)
      (progn (message "Cannot find TARGET at point. %s" TARGET)
             nil)
    (replace-regexp-in-string ".*\\(html \\)" "html"
                              (shell-command-to-string
                               (concat "find " SRC
                                       ;;error;; " -iname '*" TARGET "*.html -print0 -o "
                                       " -name class-use -prune"
                                       " -o "
                                       " -iname " TARGET ".html -print0 "
                                       ))
                              nil nil 1))
  )

(defun my_java-set-method-url (WORD FNAME FIND_IN_DIRS)
  "Must return urls of string."
  (let ( (cmd (concat "find " FIND_IN_DIRS
                      " \\( "
                      " -name tree -prune "
                      " -o "
                      " -name class-use -prune "
                      " -o "
                      " -name doclet -prune  "
                      " -o "
                      " -name doclets -prune  "
                      " -o "
                      " -name index-files -prune  "
                      " -o "
                      " -name technotes -prune  "
                      " -o "
                      " -name images -prune "
                      " -o "
                      " -type f "
                      " -iname " FNAME " -print"
                      " \\) "
                      " | xargs grep " WORD
                      " | cut -d ':' -f1 | uniq "
                      ))
         ); end let
    ;; (message "cmd is: %s" cmd)
    (replace-regexp-in-string "\\(html \\)" "html "
                              (shell-command-to-string cmd)
                              nil nil 1); end replace-regexp-in-string
    )
  ) ;; my_java-set-method-url

(defun my_java-set-method-url-d (WORD FNAME FIND_IN_DIRS)
  "Must return urls of string."
  (concat  (expand-file-name FIND_IN_DIRS)
           " -name tree -prune "
           " -o "
           " -name class-use -prune "
           " -o "
           " -name doclet -prune  "
           " -o "
           " -name doclets -prune  "
           " -o "
           " -name index-files -prune  "
           " -o "
           " -name technotes -prune  "
           " -o "
           " -name images -prune "
           " -o "
           " -type f "
           " -iname " FNAME " -print"
           " | xargs grep " WORD
           " | cut -d : -f1 | uniq "
           ))

;;
;; http://stackoverflow.com/questions/4173737/how-to-include-standard-jdk-library-in-emacs-semantic

(setq rng-nxml-auto-validate-flag nil);; Invalidate nxml-mode VALIDATION.

;;;; Parser
(when nil
  (cond
   ( (string= "eclim" "eclim")
     (require 'my_eclim);; too heavy
     )

   )
  );when

;;;; Maven
;;; <For malabar-mode>
(require 'cedet)
(require 'semantic)
(require 'semantic/tag-file)  ;; func semantic-dependency-tag-file
(require 'srecode/srt-mode) ;; func srt-mode
(autoload 'srecode-minor-mode "srecode/mode" )
(autoload 'semantic-analyze-possible-completions  "'semantic/analyze")
;;(require 'gv) ;; function gv-define-simple-setter
(require 'fringe-helper)

(cond ( (and (< emacs-major-version 24)
             (load "my_cl-lib") ;; provide cl-lib installable from elpa
             ;;(eval-when-compile (require 'cl))
             (require 'cl)
             (defalias 'cl-flet 'flet "Under emacs 24.2")
             )
        (load "my_malabar-mode")
        )
;; requires inf-groovy      ( t (require 'malabar-mode))
      )

(eval-after-load "java-mode";; java-mode is defined in cc-mode.el.gz?
  (progn
    (message "java-mode was activated.")
    (global-set-key  (kbd "C-c C-l") 'toggle-truncate-lines) ;; Overwrite c-toggle-electric-state
    ))
(global-set-key (kbd "C-c H") 'my_java-describe-deferred)

;; not recommended
(let ((java-home (getenv "JAVA_HOME")))
  (when (null 'java-home)
    (progn
      (message "${JAVA_HOME} is %s" java-home)
      (semantic-add-system-include java-home 'java-mode)
      )))

(unless (featurep 'yasnippet)
  (load-library "my_yasnippet")
  )
(unless (featurep 'flymake-mode)
  (progn
    (load-library "my_flymake")
    (message "my_java.el: called my_flymake")
    )
  )
(unless (featurep 'my_java)
  (provide 'my_java)
  )

;;? (setq tab-width 4) ; test. jobenv.el is not working.

;;; my_java.el ends here
