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

(defun anything-c-my_java-javadoc ()
  "TBD:"
  (anything-other-buffer anything-c-source-my_java-javadoc " *my_java-javadoc*")
  )


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

(defun my_java-describe-deferred()
  "Async my_java-describe"
  (interactive)
  (require 'deferred)
  (lexical-let ((w (thing-at-point 'word t)))
    (deferred:$
      (deferred:call 'my_java-describe-d w)
      (deferred:error it
        (lambda (err)
          (message "my_java::my_java-describe-deferred catched err : %s" err)))
      ))
  )

(defvar FIND_IN_DIR  "~/.emacs.d/share/doc/java/se6/api/  ~/.emacs.d/share/doc/java/ee6/javax/ " "javadoc-html-search-path")
(defun my_java-describe-d (&optional pword)
  (interactive)
  (unless (featurep 'my_w3m) (require 'my_w3m))
  (lexical-let* (
                 ;;(let* (
                 (TARGET (if (stringp pword ) (prog1 pword )
                           (condition-case err
                               (thing-at-point 'word t)
                             ('wrong-number-of-arguments (thing-at-point 'word))
                             )))
                 (FNAME "*.html") ; for java keyword,
                 ;;(FNAME "index*all.html")
                 (URL (my_java-set-class-url FIND_IN_DIR TARGET ) )
                 )
    (unless (equal "" TARGET)
      (cond
       ( (equal "" URL)
        ;;;; found string
         (progn
           (message "Cannot find Class %s" TARGET)
           (message "Search method %s" TARGET)
           (deferred:$
             (deferred:next
               (lambda ()  (my_java-set-method-url-d TARGET FNAME "~/.emacs.d/share/doc/java/")))
             (deferred:nextc it
               (lambda (txt)
                 (deferred:process-shell "find" txt)
               ))
             (deferred:nextc it
               (lambda (txt)
                 (message "found url.")
                 (replace-regexp-in-string "\\(html \\)" "html "
                                           txt
                                           ;;(shell-command-to-string txt)
                 nil nil 1) ; end replace-regexp-in-string
                 ))
             (deferred:nextc it
               (lambda (x)
                 (message "found url.")
                 (setq my_java-javadoc-urls (split-string x))
                 (if (> (length my_java-javadoc-urls) 0)
                     (anything-c-my_java-javadoc)
                   )))
             (deferred:error it
               (lambda (err)
                 (message "my_java::my_java-describe-d catched err : %s" err)))
             ); deferred:$
           ))
       (t
         ;;; class match
        (if (or (require 'w3m nil t) (featurep 'w3m))
            ;;(if (or (require 'my_w3m) (featurep 'my_w3m))
            ;;	(setq w3m-command-arguments '("-cookie" "-T text/html"))
            ;;(w3m-browse-url URL t)
            (w3m-goto-url-new-session URL t)
          (browse-url URL)))
       )
      )
    (message "(TARGET,FNAME,URL)=(%s, %s, %s)" TARGET FNAME URL )
    ))

(defun my_java-describe (&optional pword)
  (interactive)
  (unless (featurep 'my_w3m) (require 'my_w3m))
  (let* ( (TARGET (if (stringp pword ) (prog1 pword )(thing-at-point 'word t)))
          (FIND_IN_DIR  "~/.emacs.d/share/doc/java/se6/api/  ~/.emacs.d/share/doc/java/ee6/javax/ ")
          (FNAME "*.html") ; for java keyword,
          (URL (my_java-set-class-url FIND_IN_DIR TARGET ) )
          )
    (unless (equal "" TARGET)
      (cond
       ( (equal "" URL)
        ;;;; found string
         (progn
           (message "Cannot find Class %s" TARGET)
           (message "Search method %s" TARGET)
           ;;(unless (get-file-buffer (my_java-set-method-url FNAME TARGET))
           (setq my_java-javadoc-urls (split-string (my_java-set-method-url TARGET FNAME "~/.emacs.d/share/doc/java/")) )
           (message "URLS:%s" my_java-javadoc-urls)
           (if (> (length my_java-javadoc-urls) 0)
               (anything-c-my_java-javadoc)
             )
           ))
       (t
         ;;; class match
        (if (or (require 'w3m nil t) (featurep 'w3m))
            ;;(if (or (require 'my_w3m) (featurep 'my_w3m))
            ;;	(setq w3m-command-arguments '("-cookie" "-T text/html"))
            ;;(w3m-browse-url URL t)
            (w3m-goto-url-new-session URL t)
          (browse-url URL)))
       )
      )
    (message "(TARGET,FNAME,URL)=(%s, %s, %s)" TARGET FNAME URL )
    t) )


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

;;        (add-hook 'malabar-mode-hook
;;             (lambda ()
;;               (add-hook 'after-save-hook 'malabar-compile-file-silently
;;                          nil t)))

;;; </For malabar-mode>

;; (unless (featurep 'ajoke)
;;   (load-library "ajoke") ;; You need JDK (source code of java) and GNU Global.
;;   (cond
;;    ((eq system-type 'darwin)
;;   ;;;; Java8 : http://docs.oracle.com/javase/8/docs/technotes/guides/install/mac_jdk.html#A1096855
;;         ;;  - Mac: java_home(1)
;;
;;   ;;; If you installed ajoke as a normal user, the edit .globalrc to point to library of normal user.
;;   ;;; $ cd /Library/Java/JavaVirtualMachines/jdk1.8.0_20.jdk/Contents/Home/
;;   ;;; $ mkgtags (create cache at $HOME/.cache/for-code-reading/)
;;         (defvar my_java-ajoke-java-fallback-dir "/Library/Java/JavaVirtualMachines/jdk1.8.0_20.jdk/Contents/Home/")
;;
;;   ;;; @DEV
;;         ;; ajoke.el::ajoke-complete-method
;;         ;; + ajoke-get-hierarchy.pl l.38:"gtags: GTAGS not found."
;;         ;; ++ java-find-defs.pl
;;         ;; +++ grep-gtags
;;         ;; ++ java-query-qmethod
;;         ;; ++ ajoke-get-members
;;         ;; @ref
;;         ;; To maintain branch of ajoke. http://kik.xii.jp/archives/179
;;         )
;;    );cond
;;   )


;; (eval-after-load 'java-mode '(local-set-key (kbd "C-c h") 'my_java-describe))
(eval-after-load "java-mode";; java-mode is defined in cc-mode.el.gz?
  (progn
    ;; (local-set-key (kbd "C-c h") 'my_java-describe)
    (define-key java-mode-map (kbd "C-c h") 'my_java-describe)
    (when (and (executable-find "java-add-fallback") (executable-find "mkgtags") (featurep 'ajoke))
        (progn
          (shell-command-to-string "mkgtags")
          (shell-command-to-string (concat "java-add-fallback " my_java-ajoke-java-fallback-dir)))
        )
    (message "java-mode was activated.")
    (global-set-key  (kbd "C-c C-l") 'toggle-truncate-lines) ;; Overwrite c-toggle-electric-state
    ))
(global-set-key (kbd "C-c H") 'my_java-describe-deferred)
;;(global-set-key (kbd "C-c h") 'my_java-describe-d)
;;(global-set-key (kbd "C-c h") 'my_java-describe)
;;(if (boundp 'toggle-truncate-lines)
;;(global-set-key  "\C-c\C-l" 'toggle-truncate-lines)


;;defun my_java-mode-hooks ()
;; (interactive)
;; not recommended
(let ((java-home (getenv "JAVA_HOME")))
  (when (null 'java-home)
    (progn
      (message "${JAVA_HOME} is %s" java-home)
      (semantic-add-system-include java-home 'java-mode)
      )))
;;(setq ecb-layout-name "left1")
;; recommended
;;$;; semantic-dependency-system-include-path
;;(require 'my_eclim nil t);; cause error
;;TBD (if (boundp semantic-idle-breadcrumbs-mode)
;;TBD   (progn
;;TBD     (semantic-idle-summary-mode )
;;TBD     (semantic-idle-scheduler-mode 1)
;;TBD     (semantic-idle-breadcrumbs-mode 1)
;;TBD     ))

;;  (autoload 'jde-mode "jde" "Java Development Environment for Emacs." t)
;;$;;  (when (require 'jde )
;;$;;    (setq auto-mode-alist (cons '("\.java$" . jde-mode) auto-mode-alist))
;;$;;    (setq semantic-load-turn-useful-things-on t))
;;(require 'my_yasnippet) <--- cause error  File mode specification error: (error "Variable binding depth exceeds max-specpdl-size")
;;)
;; (message "my_java-mode-hooks called")
                                        ; )
;;;; need which-func-mode for java
;; http://dev.ariel-networks.com/articles/software-design-200802/elisp-advanced/

;;;; Can prevent dependency of require?

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
