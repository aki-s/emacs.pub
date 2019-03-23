;; | official | http://flymake.sourceforge.net/ |
;; http://e-arrows.sakura.ne.jp/2010/02/vim-to-emacs.html

;;$debug;; (when (or (eval-when-compile (load-library "flymake")) (require 'flymake nil t) )
;;(load-library "my_cl-lib")
(require 'flymake)
;;--------------------------------------------------------------------------------
;; TODO
;;--------------------------------------------------------------------------------
;; prevent -preprocessed buffer
;;--------------------------------------------------------------------------------
;; DEBUG
;;--------------------------------------------------------------------------------
(defun my_flymake-force-syntax-check()
  "@dev"
  (interactive)
  ;; lang
  ;; select from my_flymake-init-func-list
  ;; make relation between flymake-mode and buffer buffer-local.
  )

(defun my_flymake-simple-cleanup-dummy ()
  "Dummy function for flymake debugging purpose. Do nothing."
  )

(defun toggle-flymake-log-level (&optional lvl)
  (interactive (list 
                (string-to-number (read-string (format "Input loglevel[-1 ~ 3] (current:%s): " flymake-log-level))))
               )
  ;; current-prefix-arg 
  (cond 
   ((and (integerp lvl) (<= -1 lvl) (>= 3 lvl) )
    (setq-default flymake-log-level lvl)
    (message "flymake-log-level is %d" lvl)
    )
   ( t  ; (null lvl)
     (setq-default flymake-log-level 0)
     (message "flymake-log-level is 0"))
   ))

(if (featurep 'my_debug_init)
    (toggle-flymake-log-level 3))

;;--------------------------------------------------------------------------------
;;  defgroup
;;--------------------------------------------------------------------------------
;;  defvar
(defvar my_flymake-incdir nil "@dev")
(setq-default my_flymake-incdir "./include")
(make-variable-buffer-local 'my_flymake-incdir)
;; (set (make-local-variable 'name) value)
(defvar my_flymake-history nil "Mainly for makefile location table")
(defvar my_flymake-compile-cmd nil "comper +options")

(defvar my_flymake-compile-cmd-hash (make-hash-table :test 'equal)
  "Master hash of compile command used as syntax checker.
 Don't overwrite this variable.")

(defvar my_flymake-compiler-list '() 
  "flymake syntax check compiler list.
    key values of my_flymake-compile-cmd-hash"
  )

(defvar my_flymake-init-func-hash (make-hash-table :test 'equal)
  "Master hash of compile command used as syntax checker.
     Hash key should be discriptive value of init func.
 Don't overwrite this variable.")

(defvar my_flymake-init-func-list '()
  "flymake each program language init func list
     like as flymake-<language>-init .
     Every time you define init func, you should append it to this variable."
  )

(defvar my_flymake-always-this-makefile
  nil
  "Absolute PATH to makefile for my_flymake_init."
  )

;;--------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  defun
;;--------------------------------------------------------------------------------


(defun my_flymake-split (shell-env-var &optional sep )
  "@dev Split 'shell-env-var with delimiter 'sep
ref. ffap-list-env
"
  (setq sep (or sep ":")); default arg
                                        ;  (symbol-value)
  (if (stringp shell-env-var)
      (split-string (getenv shell-env-var) sep t)
    (split-string (getenv (symbol-value shell-env-var)) sep t)
    )
  )

(defun my_flymake-split-concat (shell-env-var &optional sep )
  "@dev Split 'shell-env-var with delimiter 'sep"
                                        ; sep = -I
  (setq sep (or sep " -I")); default arg
  (concat sep (mapconcat 'identity  (my_flymake-split shell-env-var) sep))
  )
                                        ; mapcar "-I" 
(defun my_flymake-split-mapcat (shell-env-var &optional sep cat )
  "@dev concatenate 'cat for each element of the results of splitting 'shell-env-var with delimiter 'sep
@todo Need to ignore white space.
"
  (setq sep (or sep ":")); default arg
  (split-string (concat cat (mapconcat 'identity  (my_flymake-split shell-env-var sep) cat)))
  )

(defun my_flymake-get-init-func-list ()
  "Get syntax checker init func lists defined. "
  (interactive)
    ;;;; http://ergoemacs.org/emacs/elisp_hash_table.html
  (setq my_flymake-init-func-list nil) 
  (maphash 
   (lambda (key value) 
     (setq my_flymake-init-func-list (cons key my_flymake-init-func-list))) 
   my_flymake-init-func-hash
   )
  (message "%s\n" my_flymake-init-func-list) ;; return list
  my_flymake-init-func-list;; return list
  )

(defun my_flymake-select-init-func (&optional flymake-init-func-key)
  "When you want to change flymake init function, use command."
;;; http://stackoverflow.com/questions/9646088/emacs-interactive-commands-with-default-value
  (interactive  (list
                 (read-string (format "compiler (%s): " (my_flymake-get-init-func-list) )
                              nil nil (thing-at-point 'flymake-init-func-key) )))
  (if (null flymake-init-func-key)
      (error "Select valid init func" )
    (let (
          (file-suffix-regex (format "\\%s$" (ffap-file-suffix buffer-file-name)))
          ;; (flymake-init-func-val (gethash (format "%s" flymake-init-func-key) my_flymake-init-func-hash))
          (flymake-init-func-val (gethash flymake-init-func-key my_flymake-init-func-hash))
          )
      (message "%s %s" file-suffix-regex  flymake-init-func-val)
      (push `( ,file-suffix-regex  ,flymake-init-func-val) flymake-allowed-file-name-masks) 
      (message "flymake: %s use %s" file-suffix-regex flymake-init-func-val ))
    ))

(defun my_flymake-init ()
  "Always use specified makefile." 
  ;;$;;    (let* (
  ;;$;;           (temp-file   (flymake-init-create-temp-buffer-copy
  ;;$;;                         'flymake-create-temp-with-folder-structure))
  ;;$;;           (local-file  (file-relative-name
  ;;$;;                         temp-file
  ;;$;;                         (file-name-directory buffer-file-name)))
  ;;$;;           )
  ;;$;;      (flymake-get-include-dirs (concat (file-name-directory buffer-file-name) "/include"))
  ;;$;; 
  ;;$;;      )
  (unless (stringp my_flymake-always-this-makefile)
    (message "my_flymake-always-this-makefile is void")
    ) 
  (flymake-simple-make-init-impl 'flymake-create-temp-inplace t t my_flymake-always-this-makefile 'flymake-get-minimal-make-cmdline);;; return this
  ) 
(puthash "my_flymake-init" 'my_flymake-init my_flymake-init-func-hash)

(defun flymake-get-minimal-make-cmdline (source base-dir)
  "(command (command options separated with space "make target"))"
  (list "make"
        (list "-s"
              "-C"
              base-dir
              (concat "CHK_SOURCES=" source)
              "SYNTAX_CHECK_MODE=1"
              "check-syntax"))) 

(defun my_flymake-select-makefile(&optional my_flymake-always-this-makefile_in)
  "Select makefile to be used for every file."
  ;;(if (not (null 'my_flymake-always-this-makefile_in))
  
  (interactive
   (list
    ;; (interactive  
    ;;     (list 
    ;;                   (read-string "Set Makefile: " 
    ;;                                my_flymake-always-this-makefile_in ))) 
    ;; minibuffer-local-filename-completion-map
    ;; )) 
    (let ( choiced 
           (read-file-name-completion-ignore-case t) 
           (my_flymake-always-this-makefile_default (format "%s%s" default-directory "/Makefile") ) 
           )
      (setq choiced (read-file-name "makefile: " default-directory my_flymake-always-this-makefile_default 'confirm ))
      (require 'dired)
      (if (featurep 'tramp)
          ()
        (unless (string-match "text" (dired-show-file-type (expand-file-name choiced) t ) )
          (error "Selected file is not text file")))
   ;;; ref. http://obsidianrook.com/devnotes/elisp-prompt-new-file-part3.html
      ;;     (setq result
      ;;           (read-from-minibuffer
      ;;            "makefile: "
      ;;                        my_flymake-always-this-makefile_in  ; the inital value (like a default)
      ;;                        minibuffer-local-filename-completion-map  ; new keymap is key
      ;;                        nil
      ;;                        'my_flymake-history  ; maintain a separate history stack
      ;;                        nil
      ;;                        nil))
      ;;(list choiced) )))
      choiced )))
  (my_flymake flymake-allowed-file-name-masks)
  (setq my_flymake-always-this-makefile my_flymake-always-this-makefile_in) 

  (if (file-exists-p my_flymake-always-this-makefile)
      (push '( ".*\\.*" my_flymake-init) flymake-allowed-file-name-masks) 
    (error "%s doesn\'t exist " my_flymake-always-this-makefile)
    )
  (message "my_flymake-always-this-makefile is set to %s" my_flymake-always-this-makefile)
  )

(defun my_flymake-unselect-makefile()
  "Remove my_flymake-init from flymake-allowed-file-name-masks "
  (interactive)
  (remhash "always-this-makefile" my_flymake-init-func-hash)
  ;;; ref
  ;;$ref$;;;;; yasnippetのbindingを指定するとエラーが出るので回避する方法。
  ;;$ref$;;(setf (symbol-function 'yas-active-keys)
  ;;$ref$;;      (lambda ()
  ;;$ref$;;        (remove-duplicates (mapcan #'yas--table-all-keys (yas--get-snippet-tables)))))
  )

;;;;;;;;;; 
(defun my_flymake-get-comiler-list ()
  "Get syntax checker compiler lists defined.
just backup"
    ;;;; http://ergoemacs.org/emacs/elisp_hash_table.html
  (setq my_flymake-compiler-list nil)
  (maphash 
   (lambda (key value) 
     (setq my_flymake-compiler-list (cons key my_flymake-compiler-list))) 
   my_flymake-compile-cmd-hash
   )
  my_flymake-compiler-list;; return list
  )

(defun my_flymake-select-compile-cmd (&optional flymake-init-func-key)
  "Change syntax check compiler"
;;; http://stackoverflow.com/questions/9646088/emacs-interactive-commands-with-default-value
  (interactive  (list
                 (read-string (format "compiler (%s): " (my_flymake-get-comiler-list) )
                              nil nil nil))) 
  (let (
        (file-suffix-regex (format "\\%s$" (ffap-file-suffix buffer-file-name)))
        (flymake-init-func-val (gethash flymake-init-func-key my_flymake-compile-cmd-hash))
        )
    (push `( ,file-suffix-regex  ,flymake-init-func-val) flymake-allowed-file-name-masks) 
    (message "flymake: %s use %s" file-suffix-regex flymake-init-func-val ))
  )

(defun my_flymake-show-compile-cmd ()
  "Show current active syntax check command"
  (interactive)
  (if  (listp  my_flymake-compile-cmd)
      (message "%s" my_flymake-compile-cmd)
    (error "%s" "'my_flymake-compile-cmd is not defined")
    ) ) 

(defun my_flymake-set-compile-cmd (compile-cmd)
  "Directory replace compile command 'my_flymake-compile-cmd of init func."
  (interactive)
  (setq my_flymake-compile-cmd compile-cmd)
  )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;======================================================================
;; 2. Flymake
;;======================================================================
;;;; @ref. http://www.emacswiki.org/emacs/FlyMake
;;;; @ref. || http://d.hatena.ne.jp/mowamowa/20071217/1197865281 |


;;  (add-hook 'find-file-hook 'flymake-find-file-hook)
;;00 (eval-after-load "flymake-mode"
;;00   (when (not (boundp 'flymake-mode-keymap))
;;00     (defvar flymake-mode-keymap (make-sparse-keymap) "my_flymake keymap")
;;00     (define-key flymake-mode-keymap (kbd "\C-cd") 'flymake-display-err-menu-for-current-line) 
;;00     (define-key flymake-mode-keymap (kbd "\M-n" ) 'flymake-goto-next-error)
;;00     (define-key flymake-mode-keymap (kbd "\M-p" ) 'flymake-goto-prev-error)
;;00     ;; (use-local-map flymake-mode-keymap)
;;00     (put flymake-mode :keymap 'flymake-mode-keymap)
;;00     )
;;00   )


(defun my_flymake-unload-keys()
  (global-unset-key "\M-N")
  (global-unset-key "\M-P")
  (global-unset-key "\C-cd")
  )

(defun flymake-mode-on () 
  (interactive)
  (flymake-mode 1)
  (eval-after-load "flymake-mode"
    (progn
      ;;;; http://www.emacswiki.org/emacs/KeybindingGuide
      (define-key (current-local-map) (kbd "\C-cd") 'flymake-display-err-menu-for-current-line)
      ;;notworking      (define-key (current-local-map) (kbd "\M-n" ) 'flymake-goto-next-error)
      (local-set-key "\356" 'flymake-goto-next-error) ;lenovo; \M-n ref. (repeat-complex-command)
      (local-set-key (kbd "M-N") 'flymake-goto-next-error) ; ggtags-next-mark use (kbd "M-n")
      ;;notworking      (define-key (current-local-map) (kbd "\M-p" ) 'flymake-goto-prev-error)
      (local-set-key "\360" 'flymake-goto-prev-error) ;lenovo; \M-p
      (local-set-key (kbd "M-P") 'flymake-goto-prev-error)
      ))
  )

(defun my_flymake-dont-cleanup ()
  "Refer line 284 at flymake.el 
     Don't cleaning up to check flymake behaviour."
  (setq flymake-last-change-time nil)
  )

(defun toggle-my_flymake-display-err-minibuffer ()
  (interactive)
  (if (member 'flymake-display-err-minibuffer 'post-command-hook)
      (progn 
        ;; remove-hook 'post-command-hook 'flymake-display-err-minibuffer)
        ;; message "removed flymake-display-err-minibuffer from post-command-hook" )
        ;;(setq flymake-log-level 0)
        (ad-deactivate 'flymake-mode)
        )
    (progn 
      (add-hook 'post-command-hook 'flymake-display-err-minibuffer)
      (message "added flymake-display-err-minibuffer to post-command-hook" )
      ;; (setq flymake-log-level 3)
      (ad-activate 'flymake-mode)
      )
    )
  )

(defun flymake-display-err-minibuffer () 
  "Error if input is in minibuffer."
  ;;  (run-with-idle-timer 0.5 t 'flymake-display-err-minibuffer-now (current-column))
  (flymake-display-err-minibuffer-now (current-column))
  ;; (cancel-timer
  )
;;;; I want to make this variable in closure.
(defvar flymake-displayed-line-no nil "Keep line number to privent flymake-err hijack minibuffer.")
(defun flymake-display-err-minibuffer-now (&optional colnum) 
  "Displays the error/warning for the current line in the minibuffer.
Under dev -> use current-colnum-info "
  (interactive)
  (progn
    ;;(let* ((line-no             (flymake-current-line-no))
    (let* ((line-no (line-number-at-pos))
           (line-err-info-list  (nth 0 (flymake-find-err-info
                                        flymake-err-info line-no)))
           (count               (length line-err-info-list))
           (count-org           count)
           msg
           )
      (while (> count 0)
        (when line-err-info-list
          (let* ((file       (flymake-ler-file (nth (1- count)
                                                    line-err-info-list)))
                 (full-file  (flymake-ler-full-file (nth (1- count)
                                                         line-err-info-list)))
                 (text (flymake-ler-text (nth (1- count) line-err-info-list)))
                 (line       (flymake-ler-line (nth (1- count)
                                                    line-err-info-list))))
            ;;$00;;      (if (or (/= flymake-displayed-line-no line-no) (/= count 
            ;;$00;;         (progn
            ;;$00;;            (setq flymake-displayed-line-no line-no)
            (setq msg (concat msg (format "[%s] %s\n" line text)))
            ;;$00;; ))))
            (setq count (1- count)))))
      (unless (boundp msg)
        (message "%s" msg))
      ;;(sit-for 2.0)  ;; show each error seqencially
      (sit-for 0.5)  ;; prevent cpu usage.
 ;;;; (sleep-for 5);; sleep to prevent sequencial display<- freeze
      )))
;; Maybe no meaning 
;;$;;
;;$;;(defun show-previous-error ()
;;$;;  (interactive)
;;$;;  (flymake-goto-prev-error)
;;$;;  (flymake-display-err-minibuf))
;;$;;
;;$;;(defun show-next-error ()
;;$;;  (interactive)
;;$;;  (flymake-goto-next-error)
;;$;;  (flymake-display-err-minibuf))
;;$;;

;; cite. http://sakito.jp/emacs/emacsobjectivec.html#emacs-objective-c
;;エラー行にカーソルがあたると自動的に minibuffer にエラーが表示されます。

;;--------------------------------------------------------------------------------
;; 自動的な表示に不都合がある場合は以下を設定してください

(defadvice flymake-goto-next-error (after display-message activate compile)
  "次のエラーへ進む"
  (flymake-display-err-minibuffer))

(defadvice flymake-goto-prev-error (after display-message activate compile)
  "前のエラーへ戻る"
  (flymake-display-err-minibuffer))

(defadvice flymake-mode (before my_flymake-mode-post-commands activate compile)
  "エラー行にカーソルが当ったら自動的にエラーが minibuffer に表示されるようにpost command hook に機能追加
;; 自動的な表示に不都合がある場合は以下を設定してください
;; post-command-hook は anything.el の動作に影響する場合があります
"
  (set (make-local-variable 'post-command-hook)
       (add-hook 'post-command-hook 'flymake-display-err-minibuffer))
  )


(setq flymake-gui-warnings-enabled nil)

;; Only run flymake if I've not been typing for 5 seconds
;;(setq flymake-no-changes-timeout 5)

(defun flymake-after-change-function (start stop len)
  "Start syntax check for current buffer if it isn't already running."
  ;; Do nothing, don't want to run checks until I save.
  )

(cond
 (;; If fringe cannot be used
  (or 
   (eq window-system nil)
   (member "--with-jpeg=no" (split-string system-configuration-options))
   (member "--with-png=no" (split-string system-configuration-options))
   )
  ;;(set-face-background 'flymake-errline "magenda")
  (set-face-background 'flymake-errline "#ffff00")
  (set-face-foreground 'flymake-errline "#000000")
  (set-face-underline-p 'flymake-errline nil)
  ;;(set-face-background 'flymake-warnline "yellow")
  (set-face-foreground 'flymake-warnline "black")
  (set-face-background 'flymake-warnline "#cd5c5c")
  (set-face-underline-p 'flymake-warnline t)
  )
 (t ;; fringe can be used
  (require 'fringe-helper)
  (defvar flymake-fringe-overlays nil)
  (make-variable-buffer-local 'flymake-fringe-overlays)
  
  (defadvice flymake-make-overlay (after add-to-fringe first
                                         (beg end tooltip-text face mouse-face)
                                         activate compile)
    (push (fringe-helper-insert-region
           beg end
           (fringe-lib-load (if (eq face 'flymake-errline)
                                fringe-lib-exclamation-mark
                              fringe-lib-question-mark))
           'left-fringe 'font-lock-warning-face)
          flymake-fringe-overlays))
  
  (defadvice flymake-delete-own-overlays (after remove-from-fringe activate
                                                compile)
    (mapc 'fringe-helper-remove flymake-fringe-overlays)
    (setq flymake-fringe-overlays nil))

  (set-face-background 'flymake-errline  nil)
  (set-face-foreground 'flymake-errline  nil)
  (set-face-foreground 'flymake-warnline nil)
  (set-face-background 'flymake-warnline nil)
  (set-face-underline-p 'flymake-errline nil)
  )
 )


;;======================================================================
;; 1. LANGUAGE
;;======================================================================
;;-------------------------------------------------------------------------------
;; C
;;--------------------------------------------------------------------------------
;;(".+\\.c$" flymake-simple-make-init flymake-simple-cleanup flymake-get-real-file-name)
(defun flymake-c-init ()
  "Return compile command"
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       ;;                      'flymake-create-temp-inplace))
                       'flymake-create-temp-with-folder-structure))
         (fdir (file-name-directory buffer-file-name) )
         (local-file  (file-relative-name temp-file fdir)))
    ;;      (list "gcc" (list "-Wall" "-Wextra" "-fsyntax-only" local-file))))
    (flymake-log 0 " %s|| %s||" temp-file fdir )
    (flymake-log 0 " flymake-c-init-is: %s" local-file)
    (if (executable-find "clang")
        ;;(list "clang" (list "-Wall" "-Wextra" "-fsyntax-only" "-I." (concat "-I " fdir "include/" ) ) local-file))
        (list "clang" (list "-Wall" "-Wextra" "-fsyntax-only" "-I." (concat "-I " fdir "include/") (my_flymake-split-mapcat "INCLUDE" ":" " -I") ) local-file)
      (list "g++" (list "-Wall" "-Wextra" "-fsyntax-only" local-file))) 
    ))

(push '("\\.c$" flymake-c-init) flymake-allowed-file-name-masks) 
(push '("\\.h$" flymake-c-init) flymake-allowed-file-name-masks) 
(add-hook 'c-mode-hook 'flymake-mode-on)

;;|| Http://d.hatena.ne.Jp/nyaasan/20071216/p1 |


;;--------------------------------------------------------------------------------
;; C++ 
;;--------------------------------------------------------------------------------
;;;; http://ergoemacs.org/emacs/elisp_hash_table.html
(puthash "clang++" '("clang++" "-Wall -Wextra -fsyntax-only -I. -I./include" )         my_flymake-compile-cmd-hash ) 
(puthash "g++"  '("g++" "-std=c++0x -Wall -Wextra -fsyntax-only -I. -I./include" )  my_flymake-compile-cmd-hash )
(defvar my_flymake-compile-cmd-cc-default  nil)

(defun clang_version (compiler)
  "Return version of clang[++]"
  (let ( 
        ( str (shell-command-to-string (format "%s %s" compiler "--version")) )
        )
    (string-match "version \\([0-9]\\.[0-9]\\)" str)
    (match-string 1 str)
    )
  )
(defun gcc_version (compiler)
  "Return version of gcc[++]"
  (let ( 
        ( str (shell-command-to-string (format "%s %s" compiler "--version")) )
        )
    (string-match "(GCC) \\([0-9]\\.[0-9]\\.[0-9]\\)" str)
    (match-string 1 str)
    )
  )
  ;;;;  @dev
;;; http://gcc0aiya000.blog.fc2.com
;; Clang 3.3 and later implement all of the ISO C++ 2011 standard.
(cond
 ( (string< "3.3" (clang_version "clang++") )
   ;; -std=c++0x is implemented
   (setq my_flymake-compile-cmd-cc-default  '("clang++" "-Wall -Wextra -fsyntax-only -I. -I./include" ) ) )
 ;;;; https://gcc.gnu.org/projects/cxx0x.html
 ;; GCC 4.7 and later support -std=c++11 and -std=gnu++11
 ( (string< "4.2" (gcc_version "g++") )
   (setq my_flymake-compile-cmd-cc-default  '("g++" "-std=c++0x -Wall -Wextra -fsyntax-only -I. -I./include" ) ))
 )

(setq my_flymake-compile-cmd-cc-default  '("clang++" "-Wall -Wextra -fsyntax-only -I. -I./include" ) )
(my_flymake-set-compile-cmd my_flymake-compile-cmd-cc-default)

;;(defun flymake-compile (&optional my_flymake-compile-cmd)
(defun my_flymake-compile (local-file &optional dir)
  "Refer flymake.el stack trace.
line:1240 flymake-start-syntax-check
line:1268:flymake-start-syntax-check-process
line:646 flymake-process-sentinel 
line:953 flymake-parse-err-lines
line:862 flymake-parse-line
"
  (list
   (format "%s" (nth 0 my_flymake-compile-cmd)) ;; cmd
   (append (split-string (nth 1 my_flymake-compile-cmd) " ")  (list local-file)) ;; cmd option  + local file "each optoin must be a element of  list"
   dir )  ;; dir
  )

(defun flymake-cc-init (&optional compile_f)
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       ;;			 'flymake-create-temp-inplace));http://d.hatena.ne.jp/uk-ar/20110609
                       'flymake-create-temp-with-folder-structure))
         (local-file  (file-relative-name
                       temp-file
                       (file-name-directory buffer-file-name))))
    (flymake-get-include-dirs (concat (file-name-directory buffer-file-name) "/include"))
    (if (functionp compile_f) (defalias my_flymake-compile compile_f));; needless impl
    (if (string= "dev" "dev")
        (progn 
          (cond 
           ((listp local-file) (message "listp %s" local-file))
           ((stringp local-file) (message "stringp %s" local-file))
           )
          (my_flymake-compile local-file)
          )
      (if (executable-find "clang++")
          ;;(if (string= "1" "0")
          (progn
            ;;  (setq my_flymake-compile-cmd-cc-default  '("clang++" "-Wall -Wextra -fsyntax-only -I. -I./include" ) ) 
            (my_flymake-set-compile-cmd my_flymake-compile-cmd-cc-default)
            (my_flymake-compile local-file)
            )
        ;;(list "clang++" (list "-Wall" "-Wextra" "-fsyntax-only" "-I." "-I./include" local-file))
        (list "g++" (list "-Wall" "-Wextra" "-fsyntax-only" "-std=c++0x" local-file))
        )
      ))
  )

(push '("\\.cpp$" flymake-cc-init my_flymake-dont-cleanup ) flymake-allowed-file-name-masks)
;; (push '("\\.c\\(pp\\|xx\\)$" flymake-cc-init my_flymake-dont-cleanup ) flymake-allowed-file-name-masks)
(push '("\\.hpp$" flymake-cc-init my_flymake-dont-cleanup ) flymake-allowed-file-name-masks)

;;notworking.why? (add-hook 'c++-mode-hook 'flymake-mode-on )
(puthash "flymake-cc-init" 'flymake-cc-init my_flymake-init-func-hash)

;;-----------------------------------------------------------
;; Java
;;-----------------------------------------------------------
;; http://stackoverflow.com/questions/10625328/setting-up-emacs-23-4-cedet-1-1-and-semanticdb-to-use-gnu-global-on-windows
;;  http://www.emacswiki.org/emacs-zh/FlymakeJava
;;$;;    (defun my-java-flymake-init ()
;;$;;      (let* ((temp-file  (flymake-init-create-temp-buffer-copy 'flymake-create-temp-with-folder-structure))
;;$;;	     (local-file (file-relative-name temp-file (file-name-directory buffer-file-name))))
;;$;;	(list "javac" (list local-file))))
;;$;;

;;worked00 (defun my-java-flymake-init ()
;;worked00   ;; User cygpath or gcj instead of javac on Cygwin
;;worked00   (if (executable-find "javac")
;;worked00       (progn 
;;worked00         (setq cmd "javac")
;;worked00         ;;         (setq flymake-err-line-patterns
;;worked00         ;;               (cons
;;worked00         ;;                '("\(.+\)(\([0-9]+\)): \(?:lint \)?\(\(?:Warning\|SyntaxError\):.+\)" 1 2 nil 3)
;;worked00         ;;                flymake-err-line-patterns))
;;worked00         )
;;worked00     (setq cmd "gcc")
;;worked00     )
;;worked00 ;;  (if (file-exists-p "~/.emacs.d/util/my_java-lint") (setq cmd "~/.emacs.d/util/my_java-lint") )
;;worked00   (let ( (compile-opt "") )
;;worked00     (if (string= cmd "javac")
;;worked00         (setq compile-opt "-Xlint -Xlint:deprecation -Xprefer:source")
;;worked00       )
;;worked00     (list cmd (list (flymake-init-create-temp-buffer-copy
;;worked00                      ;; (list cmd (nconc (split-string compile-opt) (flymake-init-create-temp-buffer-copy ; don't work
;;worked00                      ;;    (list "javac" (list (flymake-init-create-temp-buffer-copy
;;worked00                      'flymake-create-temp-with-folder-structure)))
;;worked00 
;;worked00 ))

(defun my-java-flymake-init ()
  (setq-local flymake-warning-predicate "\\(^[wW]arning\\|checkstyle\\)")
;;  (setq-local flymake-warning-predicate "checkstyle")
  (list (expand-file-name "~/.emacs.d/util/my_java-lint")
  (list (flymake-init-create-temp-buffer-copy
  'flymake-create-temp-with-folder-structure))))

;;;;; Support checkstyle @TBD
;;(defun flymake-checkstyle-java-init ()
;;  "Use checkstyle to check the style of the current file."
;;  (let* ((temp (flymake-init-create-temp-buffer-copy 'flymake-create-temp-inplace))
;;	 (local (file-relative-name temp (file-name-directory buffer-file-name))))
;;    (list "/usr/bin/java"  (list  "-cp \"~/.emacs.d/share/checkstyle/*\" com.puppycrawl.tools.checkstyle.Main -c ~/.emacs.d/share/checkstyle/sun_checks.xml" local))))


;;(add-to-list 'flymake-allowed-file-name-masks '("\\.java$" my-java-flymake-init flymake-simple-cleanup))
(add-to-list 'flymake-allowed-file-name-masks '("\\.java$" my-java-flymake-init my_flymake-dont-cleanup))

;;$;;    (add-to-list 'flymake-allowed-file-name-masks
;;$;;		 '("\\.java$" my-java-flymake-init flymake-simple-cleanup))
;;$;;    (add-to-list 'flymake-allowed-file-name-masks
;;$;;		 '("\\.java$" my-java-flymake-init))
;;debug;; (add-hook 'java-mode-hook 'flymake-mode-on)


;;$;;
;;$;;  ;; http://tkj.freeshell.org/emacs/java/#jump-to-source
;;$;;
;;$;;  (defvar ecj-type "eclipse")
;;$;;  (defun flymake-java-ecj-init ()
;;$;;    (let* ((temp-file   (flymake-init-create-temp-buffer-copy
;;$;;                         'jde-ecj-create-temp-file))
;;$;;           (local-file  (file-relative-name
;;$;;                         temp-file
;;$;;                         (file-name-directory buffer-file-name))))
;;$;;
;;$;;      ;; if you've downloaded ecj from eclipse.org, then use these two lines:
;;$;;      (if (string= ecj-type "eclipse")
;;$;;	  (list "java" (list "-jar" 
;;$;;			     "${HOME}/.emacs.d/src/eclipse/ecj-3.4.2.jar"))
;;$;;
;;$;;	;; if installing it with DEB packages,or by some other means
;;$;;	;; giving you the ecj BASH script front end, simply use this line
;;$;;	;; instead:
;;$;;	(list "ecj" (list 
;;$;;		     "-Xemacs" 
;;$;;		     "-d" "/dev/null" 
;;$;;		     "-source" "1.5"
;;$;;		     "-target" "1.5"
;;$;;		     "-sourcepath" (car jde-sourcepath)
;;$;;		     "-classpath" 
;;$;;		     (jde-build-classpath jde-global-classpath)
;;$;;		     local-file)))))
;;$;;
;;$;;  (defun flymake-java-ecj-cleanup ()
;;$;;    "Cleanup after `flymake-java-ecj-init' -- delete temp file and dirs."
;;$;;    (flymake-safe-delete-file flymake-temp-source-file-name)
;;$;;    (when flymake-temp-source-file-name
;;$;;      (flymake-safe-delete-directory
;;$;;       (file-name-directory flymake-temp-source-file-name))))
;;$;;
;;$;;  (defun jde-ecj-create-temp-file (file-name prefix)
;;$;;    "Create the file FILE-NAME in a unique directory in the temp directory."
;;$;;    (file-truename (expand-file-name
;;$;;                    (file-name-nondirectory file-name)
;;$;;                    (expand-file-name  (int-to-string (random)) 
;;$;;                                       (flymake-get-temp-dir)))))
;;$;;
;;$;;  (push '(".+\\.java$" flymake-java-ecj-init 
;;$;;          flymake-java-ecj-cleanup) flymake-allowed-file-name-masks)
;;$;;
;;$;;  (push '("\\(.*?\\):\\([0-9]+\\): error: \\(.*?\\)\n" 1 2 nil 2 3
;;$;;          (6 compilation-error-face)) compilation-error-regexp-alist)
;;$;;
;;$;;  (push '("\\(.*?\\):\\([0-9]+\\): warning: \\(.*?\\)\n" 1 2 nil 1 3
;;$;;          (6 compilation-warning-face)) compilation-error-regexp-alist)
;;$;;
;;$;;
;;$;;  ;; --------------------------------------------------
;;$;;  ;; ref. http://dev.ariel-networks.com/Members/matsuyama/detect-syntax-errors-by-flymake/
;;$;;  ;; --------------------------------------------------
;;$;;
;;$;;  ;; redefine to remove "check-syntax" target
;;$;;  (defun flymake-get-make-cmdline (source base-dir)
;;$;;    (list "make"
;;$;;	  (list "-s"
;;$;;		"-C"
;;$;;		base-dir
;;$;;		(concat "CHK_SOURCES=" source)
;;$;;		"SYNTAX_CHECK_MODE=1")))
;;$;;
;;$;;  ;; specify that flymake use ant instead of make                                                                                                                
;;$;;  (setcdr (assoc "\\.java\\'" flymake-allowed-file-name-masks)
;;$;;	  '(flymake-simple-ant-java-init flymake-simple-java-cleanup))
;;$;;
;;$;;  ;; redefine to remove "check-syntax" target
;;$;;  (defun flymake-get-ant-cmdline (source base-dir)
;;$;;    (list "ant"
;;$;;	  (list "-buildfile"
;;$;;		(concat base-dir "/" "build.xml"))))
;;$;;
;;--------------------------------------------------------------------------------
;; JavaScript
;;--------------------------------------------------------------------------------
(when (not (fboundp 'flymake-javascript-init))
  (defun flymake-javascript-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list "/usr/local/bin/jsl" (list "-process" local-file)))) ;; /opt/local/bin/jslint
  (setq flymake-allowed-file-name-masks
        (append
         flymake-allowed-file-name-masks
         '(("\.json$" flymake-javascript-init)
           ("\.js$" flymake-javascript-init))))
  (setq flymake-err-line-patterns
        (cons
         '("\(.+\)(\([0-9]+\)): \(?:lint \)?\(\(?:Warning\|SyntaxError\):.+\)" 1 2 nil 3)
         flymake-err-line-patterns)))
(add-hook 'js-mode-hook 'flymake-mode-on)

;;--------------------------------------------------------------------------------
;; Objc
;;--------------------------------------------------------------------------------
;;--------------------------------------------------------------------------------
;; Perl
;;--------------------------------------------------------------------------------
;; http://blog.kentarok.org/entry/20080701/1214838633
;; Perl用設定
;; http://unknownplace.org/memo/2007/12/21#e001

(defvar flymake-perl-err-line-patterns
  '(("\\(.*\\) at \\([^ \n]+\\) line \\([0-9]+\\)[,.\n]" 2 3 nil 1)))

(defconst flymake-allowed-perl-file-name-masks
  '(("\\.pl$" flymake-perl-init)
    ("\\.pm$" flymake-perl-init)
    ("\\.t$" flymake-perl-init)))

(defun flymake-perl-init ()
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
                     'flymake-create-temp-inplace))
         (local-file (file-relative-name
                      temp-file
                      (file-name-directory buffer-file-name))))
    (list "perl" (list "-wc" local-file))))

(defun flymake-perl-load ()
  (interactive)
  (defadvice flymake-post-syntax-check (before flymake-force-check-was-interrupted)
    (setq flymake-check-was-interrupted t))
  (ad-activate 'flymake-post-syntax-check)
  (setq flymake-allowed-file-name-masks (append flymake-allowed-file-name-masks flymake-allowed-perl-file-name-masks))
  (setq flymake-err-line-patterns flymake-perl-err-line-patterns)
  (require 'set-perl5lib)
  (set-perl5lib)
  (flymake-mode t))

(add-hook 'cperl-mode-hook 'flymake-perl-load)

;;--------------------------------------------------------------------------------
;; PHP
;;--------------------------------------------------------------------------------
(when (not (fboundp 'flymake-php-init))
  (defun flymake-php-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list "php" (list "-f" local-file "-l"))))
  (setq flymake-allowed-file-name-masks
        (append
         flymake-allowed-file-name-masks
         '(("\.php[345]?$" flymake-php-init))))
  (setq flymake-err-line-patterns
        (cons
         '("\(\(?:Parse error\|Fatal error\|Warning\): .*\) in \(.*\) on line \([0-9]+\)" 2 3 nil 1)
         flymake-err-line-patterns)))

(add-hook 'php-mode-hook 'flymake-mode-on)

;;--------------------------------------------------------------------------------
;; Python
;;--------------------------------------------------------------------------------
(defun flymake-pyflakes-init () 
  (let* ((temp-file (flymake-init-create-temp-buffer-copy 
                     'flymake-create-temp-inplace)) 
         (local-file (file-relative-name 
                      temp-file 
                      (file-name-directory buffer-file-name)))) 
    (list "pyflakes" (list local-file)))) 

(add-to-list 'flymake-allowed-file-name-masks 
             '("\\.py\\'" flymake-pyflakes-init))

;;--------------------------------------------------------------------------------
;; Ruby
;;--------------------------------------------------------------------------------
(when (not (fboundp 'flymake-ruby-init))
  (defun flymake-ruby-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      '("ruby" '("-c" local-file)))))

(add-hook 'ruby-mode-hook 'flymake-mode-on) 

;;--------------------------------------------------------------------------------
;; Html
;;--------------------------------------------------------------------------------
;; ref. http://d.hatena.ne.jp/CortYuming/20120415/p3 flymake for html5

;; ref. http://www.emacswiki.org/emacs/FlymakeHtml
(defun flymake-html-init ()
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
                     'flymake-create-temp-inplace))
         (local-file (file-relative-name  temp-file
                                          (file-name-directory buffer-file-name))))
    (list "tidy" (list local-file))))

(add-to-list 'flymake-allowed-file-name-masks
             '("\\.html$\\|\\.ctp\\|\\.jsp" flymake-html-init))

(add-to-list 'flymake-err-line-patterns
             '("line \\([0-9]+\\) column \\([0-9]+\\) - \\(Warning\\|Error\\): \\(.*\\)"
               nil 1 2 4))
(add-hook 'html-mode-hook 'flymake-mode-on ) 




;;======================================================================
;; 3. ETC
;;======================================================================

;;$test00$;; (if (< max-specpdl-size 20000)
;;$test00$;;     (progn 
;;$test00$;;  (setq max-specpdl-size 20000) ;default 7360, use more memory.
;;$test00$;;  (setq max-lisp-eval-depth 10000) ;; must be max-specpdl-size > max-lisp-eval-depth
;;$test00$;;  )
;;$test00$;; )
;;error;; cl-safe-expr-p , 
;;--------------------------------------------------------------------------------
;;boost
(setenv "CPLUS_INCLUDE_PATH" "/opt/local/include:$CPLUS_INCLUDE_PATH")
(setenv "CPLUS_INCLUDE_PATH" "/opt/local/include/glib-2.0:$CPLUS_INCLUDE_PATH")

;;c
(setenv "C_INCLUDE_PATH"
        (concat
         "/opt/local/include:"
         "/opt/local/include/glib-2.0:"
         "/opt/local/include/libxml2:"
         (getenv "$C_INCLUDE_PATH"))
        )
;;$debug;; );; END OF (WHEN)
(defvar my_flymake-log-file "/tmp/flymake.log")  ; make log file name customizable
(defvar my_flymake-log-to-file-p nil)
(defun toggle-my_flymake-log-to-file ()
  "Functoin for debugging flymake."
  (interactive)
  (if my_flymake-log-to-file-p
      (progn 
        (defalias 'flymake-log 'flymake-log)
        (message "Output to *Messages*")
        (setq my_flymake-log-to-file-p nil)
        )
    (progn 
      (defalias 'flymake-log 'my_flymake-log)
      (message "Output to %s" my_flymake-log-file)
      (setq my_flymake-log-to-file-p t)
      )
    )
  )

(defun my_flymake-log (level text &rest args)
  (if (<= level flymake-log-level)
      (let* ((msg (apply 'format text args)))
        ;;(with-temp-file my_flymake-log-file
        (with-temp-buffer
          (insert msg)
          (insert "\n")
          ;;          (write-file my_flymake-log-file)
          (append-to-file nil nil my_flymake-log-file)
          ))))

(defvar my_flymake-redger nil "DB to store per file info.")
(defun my_flymake-register-inc (&optional inc)
  "@dev
Register INCLUDE for visited file.
"
  (interactive)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;

(defun my_flymake-unload-function ()
  (interactive)
;;;; unload-feature
  ;; (void-function flymake-display-err-minibuffer)
  (remove-hook 'flymake-display-err-minibuf 'java-mode-hook)
  ;; (void-function my-java-flymake-init)
  (remove-hook 'my-java-flymake-init 'java-mode-hook)
  (remove-hook 'post-command-hook 'flymake-display-err-minibuffer)
  
  ;; unset-key
  (my_flymake-unload-keys)
  ;; todo
  ;; mode-line
  )

;;--------------------------------------------------------------------------------
;; Overwrite default function
;;--------------------------------------------------------------------------------
(when (> 24 emacs-major-version )
  (progn
    ;;$ need fix
    (defun flymake-fix-file-name (name)
      "Replace all occurrences of '\' with '/'."
      (when name
        (setq name (abbreviate-file-name name)) ;; This return '~' if directory name contains user home directory.
        (setq name (expand-file-name name))
        (setq name (directory-file-name name))
        name))

    ;;$ need fix
    (defun flymake-post-syntax-check (exit-status command)
      (setq flymake-err-info flymake-new-err-info)
      (setq flymake-new-err-info nil)
      (setq flymake-err-info
            (flymake-fix-line-numbers
             flymake-err-info 1 (flymake-count-lines)))
      (flymake-delete-own-overlays)
      (flymake-highlight-err-lines flymake-err-info)
      (let (err-count warn-count)
        (setq err-count (flymake-get-err-count flymake-err-info "e"))
        (setq warn-count  (flymake-get-err-count flymake-err-info "w"))
        (flymake-log 2 "%s: %d error(s), %d warning(s) in %.2f second(s)"
                     (buffer-name) err-count warn-count
                     (- (flymake-float-time) flymake-check-start-time))
        (setq flymake-check-start-time nil)

        (if (and (equal 0 err-count) (equal 0 warn-count))
            (if (equal 0 exit-status)
                (flymake-report-status "" "")	; PASSED
              (if (not flymake-check-was-interrupted)
                  ;;$;; Also enter this section, if error exists in imported files.
                  ;;	      (flymake-report-fatal-status "CFGERR"
                  ;;					   (format "Configuration error has occurred while running %s" command))
                  (flymake-report-status nil ""))) ; "STOPPED"
          (flymake-report-status (format "%d/%d" err-count warn-count) ""))))

    ))
;;$;; ;;$
;;$;; (defun flymake-parse-err-lines (err-info-list lines)
;;$;;   "Parse err LINES, store info in ERR-INFO-LIST."
;;$;;   (let* ((count              (length lines))
;;$;; 	 (idx                0)
;;$;; 	 (line-err-info      nil)
;;$;; 	 (real-file-name     nil)
;;$;; 	 (source-file-name   buffer-file-name)
;;$;; 	 (get-real-file-name-f (flymake-get-real-file-name-function source-file-name)))
;;$;; 
;;$;;     (while (< idx count)
;;$;;       (setq line-err-info (flymake-parse-line (nth idx lines)))
;;$;;       (when line-err-info
;;$;; 	(setq real-file-name (funcall get-real-file-name-f
;;$;;                                       (flymake-ler-file line-err-info)))
;;$;; 	(setq line-err-info (flymake-ler-set-full-file line-err-info real-file-name))
;;$;; 
;;$;; 	(when (flymake-same-files real-file-name source-file-name)
;;$;; 	  (setq line-err-info (flymake-ler-set-file line-err-info nil))
;;$;; 	  (setq err-info-list (flymake-add-err-info err-info-list line-err-info))))
;;$;;       (flymake-log 3 "parsed '%s', %s line-err-info" (nth idx lines) (if line-err-info "got" "no"))
;;$;;       (setq idx (1+ idx)))
;;$;;     err-info-list))
;;$;; 
;;$;; 
;;$;; ;;$
;;$;; (defun flymake-parse-line (line)
;;$;;   "Parse LINE to see if it is an error or warning.
;;$;; Return its components if so, nil otherwise."
;;$;;   (let ((raw-file-name nil)
;;$;; 	(line-no 0)
;;$;; 	(err-type "e")
;;$;; 	(err-text nil)
;;$;; 	(patterns flymake-err-line-patterns)
;;$;; 	(matched nil))
;;$;;     (while (and patterns (not matched))
;;$;;       (when (string-match (car (car patterns)) line)
;;$;; 	(let* ((file-idx (nth 1 (car patterns)))
;;$;; 	       (line-idx (nth 2 (car patterns))))
;;$;; 
;;$;; 	  (setq raw-file-name (if file-idx (match-string file-idx line) nil))
;;$;; 	  (setq line-no       (if line-idx (string-to-number
;;$;;                                             (match-string line-idx line)) 0))
;;$;; 	  (setq err-text      (if (> (length (car patterns)) 4)
;;$;; 				  (match-string (nth 4 (car patterns)) line)
;;$;; 				(flymake-patch-err-text
;;$;;                                  (substring line (match-end 0)))))
;;$;; 	  (if (null err-text)
;;$;;               (setq err-text "<no error text>")
;;$;;             (when (cond ((stringp flymake-warning-predicate)
;;$;;                          (string-match flymake-warning-predicate err-text))
;;$;;                         ((functionp flymake-warning-predicate)
;;$;;                          (funcall flymake-warning-predicate err-text)))
;;$;;               (setq err-type "w")))
;;$;; 	  (flymake-log
;;$;;            3 "parse line: file-idx=%s line-idx=%s file=%s line=%s text=%s"
;;$;;            file-idx line-idx raw-file-name line-no err-text)
;;$;; 	  (setq matched t)))
;;$;;       (setq patterns (cdr patterns)))
;;$;;     (if matched
;;$;; 	(flymake-ler-make-ler raw-file-name line-no err-type err-text)
;;$;;       ())))
;;$;; 
;;$;; ;;$
;;$;; ;; error in process filter: Variable binding depth exceeds max-specpdl-size
;;$;; (defun flymake-process-filter (process output)
;;$;;   "Parse OUTPUT and highlight error lines.
;;$;; It's flymake process filter."
;;$;;   (let ((source-buffer (process-buffer process)))
;;$;; 
;;$;;     (flymake-log 3 "received %d byte(s) of output from process %d"
;;$;;                  (length output) (process-id process))
;;$;;     (when (buffer-live-p source-buffer)
;;$;;       (with-current-buffer source-buffer
;;$;;         (flymake-parse-output-and-residual output)))))
;;$;; 
;;;;-----------------------------------------------------------
;;; test debug
(defun my_flymake-debug-mode ()
  "Enable custom debug config for flymake."
  (interactive)
  (toggle_my_flymake-log-to-file)
  (setq flymake-log-level 3)
  ;;$test$;;   (debug-on-entry 'flymake-parse-err-lines)
  ;;$test$;;   (debug-on-entry 'flymake-parse-output-and-residual)
  ;;$test$;;   (debug-on-entry 'flymake-parse-residual)
  (defalias 'flymake-simple-cleanup 'my_flymake-simple-cleanup-dummy )
  (message "my_flymake-debug-mode is on")
  )
;; (toggle-my_flymake-display-err-minibuffer) ;; deactivate minibuffer
;;(my_flymake-debug-mode)

(provide 'my_flymake)
;;; my_flymake ends here
