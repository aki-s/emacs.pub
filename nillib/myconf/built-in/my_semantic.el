;;; my_semantic --- semantic.el configuration
;;; Commentary:
;;; Code:

(require 'semantic nil t)
(eval-when-compile (require 'cl))

;; override cedet/semantic#semantic-new-buffer-setup-functions
(setq semantic-new-buffer-setup-functions
  '((c-mode . semantic-default-c-setup)
     (c++-mode . semantic-default-c-setup)
     (html-mode . semantic-default-html-setup)
     (java-mode . wisent-java-default-setup)
     (js-mode . wisent-javascript-setup-parser)
     (python-mode . wisent-python-default-setup)
     (scheme-mode . semantic-default-scheme-setup)
     (srecode-template-mode . srecode-template-setup-parser)
     (texinfo-mode . semantic-default-texi-setup)
     (makefile-automake-mode . semantic-default-make-setup)
     (makefile-gmake-mode . semantic-default-make-setup)
     (makefile-makepp-mode . semantic-default-make-setup)
     (makefile-bsdmake-mode . semantic-default-make-setup)
     (makefile-imake-mode . semantic-default-make-setup)
     (makefile-mode . semantic-default-make-setup))
  )

;;======================================================================
;; my_semantic
;;======================================================================
;; I should use M-x update-directory-autoloads
(autoload 'global-ede-mode  "ede" "global-ede-mode"); required by semantic-mode
(autoload 'global-semantic-idle-scheduler-mode  "semantic/idle" "idle" )
(autoload 'global-semanticdb-minor-mode  "semantic/db-mode" "db-mode")
(autoload 'global-semantic-mru-bookmark-mode "semantic/mru-bookmark" "semantic/mru-bookmark.el")
(autoload 'semantic-default-c-setup "semantic/bovine/c" "semantic/bovine/c.el")
(autoload 'semantic-tag-write-list-slot-value "semantic/tag-write"  "semantic/tag-write.el")
(autoload 'semantic-dependency-tag-file "semantic/tag-file" "semantic/tag-file.el")
(autoload 'semantic-symref "semantic/symref/list" "semantic/symref/list.el")
(autoload 'semantic-default-make-setup "semantic/bovine/make" "semantic/bovine/make.el")

(autoload 'semanticdb-project-database-file "semantic/db-file" "semantic/db-file.el")
(autoload 'wisent-java-default-setup "semantic/wisent/java-tags" "semantic/wisent/java-tags.el")
(autoload 'semantic-change-function "semantic/edit" "semantic/edit.el")
(autoload 'semantic-ia-fast-jump "semantic/ia" "semantic/ia.el")

 ;;; semantic must be required before loading global-ede-mode
(semantic-mode 1)
(require 'my_ede)
(require 'semantic/imenu) ;; load variable semantic-imenu-summary-function
(require 'semantic/format) ;; load func semantic-format-tag-summarize
(setq semantic-imenu-summary-function
  (lambda (tag)
    (semantic-format-tag-summarize tag nil t)))
;;; http://blog.goo.ne.jp/gleaning/e/0dffe11469827ccd860e4f6d3c90a5d4
(defvar semantic-default-submodes
  '(
     global-semantic-idle-scheduler-mode  ;;@TODO should be disable in buffers like as *eshell*
     global-semantic-idle-completions-mode
     global-semanticdb-minor-mode
     global-semantic-highlight-func-mode
     global-semantic-idle-local-symbol-highlight-mode
     global-semantic-show-unmatched-syntax-mode
     ;;	global-semantic-decoration-mode
     ;;	global-semantic-stickyfunc-mode
     global-semantic-mru-bookmark-mode
     ))

(global-set-key (kbd "C-c . j") 'semantic-ia-fast-jump) ; Not active in `c-mode'
(global-set-key (kbd "M-J") 'semantic-ia-fast-jump) ; [M-j] is bound to cc-cmds#`c-indent-new-comment-line'

;;;; http://stackoverflow.com/questions/12791246/how-can-i-tell-if-cedet-is-using-gnu-global
;; M-x cedet-gnu-global-show-root RET
;; to see if it can find a Global index file in that project.
;;
;; Next, to see if symref found it, you need to eval this:
;; M-: (semantic-symref-detect-symref-tool)
;;
;; and it will give you a symbol representing the tool it has chosen to use. It will say 'grep if it failed to use Global.
;;
;; If you were in the middle of configuring things, you might need to reset things for you buffer. An easy way is to kill the buffer, and find it again, or:
;; M-x (setq semantic-symref-tool 'detect) RET

;;; ------------------------------------------------------

(cond ( (eq system-type 'cygwin)
        (progn
          (message "cygwin cedet")
          )
        )
  ( (eq system-type 'darwin)
    (progn
      ;; (ede-cpp-root-project "NAME" :file "Makefile"
      ;;      :include-path '( "/include" "../include" )
      ;;      :system-include-path '( "/usr/include/c++/4.2.1/" )
      ;;      :spp-table '( ("MOOSE" . "")
      ;;                    ("CONST" . "const") )
      ;;      :spp-files '( "include/config.h" )
      ;;      )

      ;;
      (semantic-add-system-include "/usr/include/c++/4.2.1/" 'c++-mode)
      (semantic-add-system-include "/usr/local/include" 'c++-mode)
      (semantic-add-system-include "/usr/include" 'c-mode)
      (semantic-add-system-include "/usr/local/include" 'c-mode)

      ;;;; Java
      (defvar my_semantic-java-zipped-srcs
        (let* ((jh (getenv "JAVA_HOME"))
                (jh-src (if jh (concat jh "/src.zip")))
                (jh-src-fx (if jh (concat jh "/javafx-src.zip")))
                )
          (list jh-src jh-src-fx))
        "List of candidates of zipped java src. All value may be nil.")

      (defun my_java-remove-suffix-for-compressed-file (str)
        "Remove suffix jar or zip from STR(nil is allowed)."
        (eval-and-compile
          (load-library "subr")
          (require 'subr-x))
        (cond
          ((string-suffix-p ".jar" str)
            (string-remove-suffix ".jar" str))
          ((string-suffix-p ".zip" str)
            (string-remove-suffix ".zip" str))
          (t str)
          ))

      (defvar my_semantic-java-unzipped-srcs
        (loop for f in (mapcar 'my_java-remove-suffix-for-compressed-file my_semantic-java-zipped-srcs)
          if (and f (file-exists-p f))
          collect f)
        "Collect actually existent files as a list")

      ;; Add extracted java src to semantic.
      (loop for dir in my_semantic-java-unzipped-srcs
        do (semantic-add-system-include dir 'java-mode))

      ;;;; Python
      (defvar semantic-python-dependency-system-include-path
        '("/usr/lib/python2.6/"))
      ;;;; C
      (defvar semantic-c-dependency-system-include-path
        (quote (
                 "/opt/local/include/glib-2.0"
                 "/opt/local/lib/glib-2.0/include"
                 "/usr/include"
                 "/usr/local/include"
                 )))
      (defvar semantic-c++-dependency-system-include-path
        (quote (
                 "/opt/local/include/glib-2.0"
                 "/opt/local/lib/glib-2.0/include"
                 "/opt/local/include/glibmm-2.4"
                 "/usr/include"
                 "/usr/include/c++/4.2.1"
                 "/usr/local/include"
                 )))

      ;; ;; flymake
      ;; ;;http://www.emacswiki.org/emacs-zh/FlyMake#toc18
      ;; (require 'lmcompile)
      ;; (add-hook 'compilation-finish-functions 'vj-compilation-finish-highlight)
      ;; (defun vj-compilation-finish-highlight (buffer result-str)
      ;;   (interactive)
      ;;   (lmcompile-do-highlight))
      ))
  )
  ;;; ref. https://github.com/alexott/emacs-configs/blob/2f703acf5d84c14146dfe9a3e6afc599ac671a04/rc/emacs-rc-cedet.el
;;$;;  (semantic-load-enable-excessive-code-helpers)
;;$;;  ;;(semantic-load-enable-semantic-debugging-helpers)
;;$;;
;;$;;  (setq senator-minor-mode-name "SN")
;;$;;  (setq semantic-imenu-auto-rebuild-directory-indexes nil)
;;$;;  (global-srecode-minor-mode 1)
;;$;;  (global-semantic-mru-bookmark-mode 1)
;;$;;
;;$;;  (require 'semantic-decorate-include)
;;$;;
;;$;;  ;; gcc setup
;;$;;  (require 'semantic-gcc)
;;$;;
;;$;;  ;; smart complitions
;;$;;  (require 'semantic-ia)
;;$;;
;;$;;  (setq-mode-local c-mode semanticdb-find-default-throttle
;;$;;                                    '(project unloaded system recursive))
;;$;;  (setq-mode-local c++-mode semanticdb-find-default-throttle
;;$;;                                    '(project unloaded system recursive))
;;$;;  (setq-mode-local erlang-mode semanticdb-find-default-throttle
;;$;;                                    '(project unloaded system recursive))
;;$;;
;;$;;  (require 'eassist)
;;$;;
;;$;;  ;; customisation of modes
;;$;;  (defun my-cedet-hook ()
;;$;;      (local-set-key [(control return)] 'semantic-ia-complete-symbol-menu)
;;$;;        (local-set-key "\C-c?" 'semantic-ia-complete-symbol)
;;$;;          ;;
;;$;;          (local-set-key "\C-c>" 'semantic-complete-analyze-inline)
;;$;;            (local-set-key "\C-c=" 'semantic-decoration-include-visit)
;;$;;
;;$;;              (local-set-key "\C-cj" 'semantic-ia-fast-jump)
;;$;;                (local-set-key "\C-cq" 'semantic-ia-show-doc)
;;$;;                  (local-set-key "\C-cs" 'semantic-ia-show-summary)
;;$;;                    (local-set-key "\C-cp" 'semantic-analyze-proto-impl-toggle)
;;$;;                      )
;;$;;  ;;(add-hook 'semantic-init-hooks 'my-cedet-hook)
;;$;;  (add-hook 'c-mode-common-hook 'my-cedet-hook)
;;$;;  (add-hook 'lisp-mode-hook 'my-cedet-hook)
;;$;;  (add-hook 'emacs-lisp-mode-hook 'my-cedet-hook)
;;$;;  ;; (add-hook 'erlang-mode-hook 'my-cedet-hook)
;;$;;
;;$;;  (defun my-c-mode-cedet-hook ()
;;$;;     ;; (local-set-key "." 'semantic-complete-self-insert)
;;$;;     ;; (local-set-key ">" 'semantic-complete-self-insert)
;;$;;      (local-set-key "\C-ct" 'eassist-switch-h-cpp)
;;$;;        (local-set-key "\C-xt" 'eassist-switch-h-cpp)
;;$;;          (local-set-key "\C-ce" 'eassist-list-methods)
;;$;;            (local-set-key "\C-c\C-r" 'semantic-symref)
;;$;;              )
;;$;;  (add-hook 'c-mode-common-hook 'my-c-mode-cedet-hook)
;;$;;
;;$;;  ;; hooks, specific for semantic
;;$;;  (defun my-semantic-hook ()
;;$;;    ;; (semantic-tag-folding-mode 1)
;;$;;      (imenu-add-to-menubar "TAGS")
;;$;;       )
;;$;;  (add-hook 'semantic-init-hooks 'my-semantic-hook)
;;$;;
;;$;;  (custom-set-variables
;;$;;    '(semantic-idle-scheduler-idle-time 3)
;;$;;     '(semantic-self-insert-show-completion-function (lambda nil (semantic-ia-complete-symbol-menu (point))))
;;$;;      '(global-semantic-tag-folding-mode t nil (semantic-util-modes)))
;;$;;  (global-semantic-folding-mode 1)
;;$;;
;;$;;  ;; gnu global support
;;$;;  (require 'semanticdb-global)
;;$;;  (semanticdb-enable-gnu-global-databases 'c-mode)
;;$;;  (semanticdb-enable-gnu-global-databases 'c++-mode)
;;$;;
;;$;;  ;; ctags
;;$;;  (require 'semanticdb-ectag)
;;$;;  (semantic-load-enable-primary-exuberent-ctags-support)
;;$;;
;;$;;  ;;
;;$;;  (semantic-add-system-include "~/exp/include" 'c++-mode)
;;$;;  (semantic-add-system-include "~/exp/include" 'c-mode)
;;$;;
;;$;;  (add-to-list 'semantic-lex-c-preprocessor-symbol-file
;;$;;                            "~/exp/include/boost-1_38/boost/config.hpp")
;;$;;
;;$;;  ;;; ede customization
;;$;;  (require 'semantic-lex-spp)
;;$;;  (global-ede-mode t)
;;$;;
;;$;;  ;; cpp-tests project definition
;;$;;  (setq cpp-tests-project
;;$;;              (ede-cpp-root-project "cpp-tests" :file "~/projects/lang-exp/cpp/CMakeLists.txt"
;;$;;                                                                :system-include-path '("/home/ott/exp/include"
;;$;;                                                                                                                                          "/home/ott/exp/include/boost-1_38")
;;$;;                                                                                            :local-variables '(
;;$;;                                                                                                                                                              (compile-command . "cd ~/projects/lang-exp/cpp/; make -j2")
;;$;;                                                                                                                                                                                                             )
;;$;;                                                                                                                        ))
;;$;;
;;$;;  (setq squid-gsb-project
;;$;;              (ede-cpp-root-project "squid-gsb" :file "~/projects/squid-gsb/README"
;;$;;                                                                :system-include-path '("/home/ott/exp/include"
;;$;;                                                                                                                                          "/home/ott/exp/include/boost-1_38")
;;$;;                                                                                            :local-variables '(
;;$;;                                                                                                                                                              (compile-command . "cd ~/projects/squid-gsb/Debug/; make -j2")
;;$;;                                                                                                                                                                                                             )
;;$;;                                                                                                                        ))
;;$;;
;;$;;  ;; my functions for EDE
;;$;;  (defun my-ede-get-local-var (fname var)
;;$;;      "fetch given variable var from :local-variables of project of file fname"
;;$;;        (let* ((current-dir (file-name-directory fname))
;;$;;                        (prj (ede-current-project current-dir)))
;;$;;              (when prj
;;$;;                      (let* ((ov (oref prj local-variables))
;;$;;                                         (lst (assoc var ov)))
;;$;;                                (when lst
;;$;;                                            (cdr lst))))))
;;$;;
;;$;;  ;; setup compile package
;;$;;  ;; TODO: allow to specify function as compile-command
;;$;;  (require 'compile)
;;$;;  (setq compilation-disable-input nil)
;;$;;  (setq compilation-scroll-output t)
;;$;;  (setq mode-compile-always-save-buffer-p t)
;;$;;  (defun My-Compile ()
;;$;;      "Saves all unsaved buffers, and runs 'compile'."
;;$;;        (interactive)
;;$;;          (save-some-buffers t)
;;$;;            (let* ((r (my-ede-get-local-var
;;$;;                                    (or (buffer-file-name (current-buffer)) default-directory)
;;$;;                                                 'compile-command))
;;$;;                            (cmd (if (functionp r) (funcall r) r)))
;;$;;              ;;    (message "AA: %s" cmd)
;;$;;                  (set (make-local-variable 'compile-command) (or cmd compile-command))
;;$;;                      (compile compile-command)))
;;$;;
;;$;;  (global-set-key [f9] 'My-Compile)
;;$;;
;;$;;  ;;
;;$;;  (defun my-gen-cmake-debug-compile-string ()
;;$;;      "Generates compile string for compiling CMake project in debug mode"
;;$;;        (let* ((current-dir (file-name-directory
;;$;;                                                    (or (buffer-file-name (current-buffer)) default-directory)))
;;$;;                        (prj (ede-current-project current-dir))
;;$;;                                 (root-dir (ede-project-root-directory prj))
;;$;;                                          (subdir "")
;;$;;                                                   )
;;$;;              (when (string-match root-dir current-dir)
;;$;;                      (setf subdir (substring current-dir (match-end 0))))
;;$;;                  (concat "cd " root-dir "Debug/" subdir "; make -j3")))
;;$;;
;;

(provide 'my_semantic)
;;; my_semantic.el ends here
