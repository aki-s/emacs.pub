;; ------------------------------------------------
;; Setting search directory for my own Lisp library
;; ------------------------------------------------
;; Objective:
;;
;; Setting load-path anywhere you like makes the maintenance hard.
;; Intentionally do I uniform management here.
;;;-----------------------------------------------------------------------------------
;;; recursive add-to-list under given 'dir'
(defun reccur-add-to-load-path (&rest paths)
  "TBD: Make available directory depth of reccursive add-to-path."
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory (expand-file-name (concat user-emacs-directory "/" (prin1-to-string window-system) "lib/" path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))

(reccur-add-to-load-path "elisp-auto-install" "elisp-manual-install" "myconf")

;;-----------------------------------------------------------------------------------
;;(add-to-list 'load-path "~/.emacs.d/myconf")
;;(add-to-list 'load-path "~/.emacs.d/ecb") ;<-macports ecb is don't work well. 110117

(defun ifnil-use-local-elib (lib &optional defdir)
  "If there is no 'lib' in load-path use use my library named 'lib'.
The directory where library locates in is set to ~/.emacs.d/share/ ,but you can overwrite
it with optional 1st arg.
 "
  (unless (locate-library lib)
    (unless defdir
      (setq defdir (concat "~/.emacs.d/share/" lib)))
    (setq load-path (cons (concat defdir ) load-path))))


(defun use-my-elib (lib &optional defdir)
  "Forcibly use my library named 'lib' instead of the default one"
  (let (rm_target (locate-library lib))
    (if rm_target
        (remove rm_target load-path)))
  (if defdir
      (setq load-path (cons (concat defdir ) load-path))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; == share ==
(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/apel");++bug:mac-indigenous
(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/emu");++bug:mac-indigenous
(add-to-list 'load-path "/opt/local/share/gtags") ;++bug:mac-indigenous

(add-to-list 'load-path "/usr/share/gtags") ;++bug:redhat-indigenous

;;(add-to-list 'load-path "~/.emacs.d/share")
;; # [submodule "share/auto-complete"]
;; #  path = share/auto-complete
;; #  url = https://github.com/auto-complete/auto-complete.git
;;(add-to-list 'load-path "~/.emacs.d/share/auto-complete")
;; (add-to-list 'load-path "~/.emacs.d/share/cask") ; ~/.cask/cask.el
;;elpa (add-to-list 'load-path "~/.emacs.d/share/ctable")
(add-to-list 'load-path "~/.emacs.d/share/clang-complete-async")
;;elpa (add-to-list 'load-path "~/.emacs.d/share/deferred")
;;elpa (add-to-list 'load-path "~/.emacs.d/share/eclim"); java
;;elpa (add-to-list 'load-path "~/.emacs.d/share/edbi") ; sql
;;elpa (add-to-list 'load-path "~/.emacs.d/share/e2wm") ; emacs window manager
(add-to-list 'load-path "~/.emacs.d/share/emacs-window-layout") ; for e2wm
;;elpa (add-to-list 'load-path "~/.emacs.d/share/epc")
(add-to-list 'load-path "~/.emacs.d/share/expand-region")
;;elpa (add-to-list 'load-path "~/.emacs.d/share/fringe-helper")
;; (add-to-list 'load-path "~/.emacs.d/share/highlight-symbol")
;;elpa (add-to-list 'load-path "~/.emacs.d/share/helm")
;;elpa (add-to-list 'load-path "~/.emacs.d/share/jedi")
(add-to-list 'load-path "~/.emacs.d/share/py") ; python
(add-to-list 'load-path "~/.emacs.d/share/web-mode")
(add-to-list 'load-path "~/.emacs.d/share/malabar-mode")
;;;(setq load-path (cons "~/local/share/emacs/site-lisp" load-path) ) ;
(add-to-list 'load-path "~/.emacs.d/share/yatex") ;
(add-to-list 'load-path "~/.emacs.d/share/auto-complete/lib/popup")
(add-to-list 'load-path "~/.emacs.d/share/tern/emacs")

;; == nil specific ==
;;(setq load-path (cons "~/.emacs.d/nillib/elisp-auto-install" load-path) ) ;
;;(setq load-path (cons "~/.emacs.d/nillib/elisp-manual-install" load-path) ) ;
;;(normal-top-level-add-to-load-path '("~/.emacs.d/nillib/myconf" "~/.emacs.d/nillib/myconf/my_default")) ;++test ;

(ifnil-use-local-elib "ecb")
(ifnil-use-local-elib "gtags" "~/local/share/gtags/")

;; == may conflict with package.el ==
;;elpa (add-to-list 'load-path "~/.emacs.d/share/elnode") ;; func of elpa package-initialize() prepend load-path
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(ifnil-use-local-elib "cedet")
;;; eieio, required by semantic/fw.el
(add-to-list 'load-path "~/.emacs.d/src/emacs/lisp/emacs-lisp/" t) ;; this file must be at the end to shadow cl.el

(use-my-elib "tramp" "~/.emacs.d/src/emacs/lisp/net/" )


;;; must exist?
(autoload 'global-semantic-mru-bookmark-mode "semantic/mru-bookmark" "semantic/mru-bookmark.el")
(autoload 'semantic-default-c-setup "semantic/bovine/c" "semantic/bovine/c.el")
(autoload 'semantic-tag-write-list-slot-value "semantic/tag-write"  "semantic/tag-write.el")
(autoload 'semanticdb-project-database-file "semantic/db-file" "semantic/db-file.el")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(ifnil-use-local-elib "evil")
(ifnil-use-local-elib "evil-plugins")
;;;; recursively set path under "PWD"n
;; (let ((default-directory (expand-file-name "PWD")))
;;  (add-to-list 'load-path default-directory)
;;  (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
;;      (normal-top-level-add-subdirs-to-load-path)))

;; (message "%s" load-path)
;; (message "%s" (locate-library "ecb"))
;; (ifnil-use-local-elib "ecb")
;; (message "%s" load-path)

;;   (let ((default-directory (expand-file-name "~/.emacs.d/share")))
;;     (add-to-list 'load-path default-directory)
;;     (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
;;         (normal-top-level-add-subdirs-to-load-path))))


;; (add-to-list 'load-path "~/.emacs.d/elpa/memory-usage-0.2") ;; M-x memory-usage

(provide 'my_load-path)
