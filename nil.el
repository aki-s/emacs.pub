;;; nil.el: --- -*- byte-compile-dynamic: nil; -*-
;;; Commentary:
;;; Code:


(eval-and-compile (load-file "~/.emacs.d/nillib/my_load-path.el"))
(load-library "my_files")
(load-library "my_package")
(load-library "my_cask")
;; (load-library "my_profiler")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; == EMACS ==
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; == server-mode ==
;; for info $ man emacsclient
;; (load-library "my_server-start")
;;;; == DEBUG ==
;;(load-library "my_debug_init")
(require 'my_evil)
;; == EMACS::CUSTOM ==
(let ((file "~/.emacs.d/nillib/emacs-custom-nil.el"))
  (if (file-exists-p file)
      (progn (setq custom-file file)
             (load custom-file))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; == CONF BASIC ==
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package amx
  :config
  (amx-mode))
(load-library "my_ace-window")
(load-library "my_global-vars")
(load-library "my_emacs-version")
(load-library "my_basic_func")
;;(load-library "my_browse-url")
(load-library "my_auto-mode-alist")
(load-library "my_autoload")
;;(load-library "my_utf")
(load-library "my_japanese")
(load-library "my_privacy")
(load-library "my_paren")
(load-library "my_autoinsert")
(load-library "my_mode-line")
(load-library "my_header-line")
(load-library "my_highlight-indent-guides")
(load-library "my_helm") ;ffap-find-file don't work?
(load-library "my_multiple-cursors")
(load-library "my_vc")
(load-library "my_window")
(eval-after-load 'pdf-view-mode (require 'my_pdf-tools))
;; (load-library "my_popwin") ;; popwin collapse ecb window layout.
(load-library "my_system-type")
(load-library "my_simple")
(load-library "my_tempbuf")
(load-library "my_highlight-symbol")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; == PROGRAM LANGUAGE ==
;;; language mode file like as `sql.el' seems to be loaded when Emacs boots, even if related file is not opened.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(eval-after-load 'c-mode (require 'my_c))
;;unused (eval-after-load 'c++-mode (load-library "my_c++")) ;; Don't know why but c++-mode-hook is not working

;;unused (eval-after-load 'cc-mode (load-library "my_gtk-look"))

;;(load-library "my_clisp")
(require 'my_dired)
;; (load-library "my_elisp")
;; (autoload 'eldoc-mode "eldoc")
(eval-after-load 'lisp-mode (load-library "my_elisp"))
;;(eval-after-load 'emacs-lisp-mode "my_elisp");; emacs-lisp-mode is definde in lisp-mode.el.gz and it is not a FILE.
;;(autoload 'emacs-lisp-mode "my_elisp")

;;(load-library "my_mysql")
;;(eval-after-load 'java-mode "my_java") ; unloeded
;; (load-library "my_java")
;; (eval-after-load 'sql (require 'my_mysql))

;;(load-library "my_octave")
;;(load-library "my_php")
;;(load-library "my_perl")
;;(load-library "my_processing")
;;(load-library "my_R")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; == TOOLS ==
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (load-library "my_printer")
;; ------------------------------------------------
;; Key Binding
;; ------------------------------------------------
(load-library "my_keybind")
(require 'my_editorconfig)
(load-library "my_face")
(load-library "my_font")
(load-library "my_expand-region")

;;;; sdic eijirou
(load-library "my_eijirou")

;;; == namazu ==
;;(load-library "my_namazu")

;;;; == MAIL::WANDERLUST ==
;;(load-library "my_mail")

;;test (load-library "my_anything")
(load-library "my_all-the-icons")
(load-library "my_auto-install")
(load-library "my_buffer-menu")
(eval-after-load 'company-mode (require 'my_company))
(load-library "my_cedet")
(load-library "my_ecb")
(eval-after-load 'scala-mode (lambda () (require 'my_ensime)))
(load-library "my_flycheck")
;; (load-library "my_flymake") ;use flyspell instead
(load-library "my_flyspell")
;;(load-library "my_gdb")
(eval-after-load 'gdb (load-library "my_gdb"))
(load-library "my_git-gutter")
(load-library "my_grep")
(load-library "my_gtags")
(load-library "my_hideshow")
;;needless?test (load-library "my_icicles")
(load-library "my_imenu")
(load-library "my_indent")
(load-library "my_ispell")
(load-library "my_migemo")
(load-library "my_markdown-mode")
;;(load-library "my_hl-line")
(eval-after-load 'org-mode (load-library "my_org-mode"))
;;(load-library "my_twitter")
;; (load-library "my_w3m")
;;(load-library "my_web-mode")
(load-library "my_yasnippet")
;;(load-library "my_zencoding")
;;(eval-after-load (list 'sgml-mode 'html-mode 'text-mode) "my_zencoding")
(load-library "my_lsp-mode")
(load-library "my_persistent-scratch")
(load-library "my_replace")
(load-library "my_smart-compile")
(load-library "my_rect")
(load-library "my_swoop")
(load-library "my_elscreen")
(load-library "my_tramp");; I want to make this autoload.
(load-library "my_undo-tree")
(eval-after-load 'vline-mode (require 'my_vline))
(eval-after-load 'vline-global-mode (require 'my_vline))
(load-library "my_which-func")
(load-library "my_which-key")
(load-library "my_whitespace")

(if (not (eq window-system nil) )
    (load-library "my_frame")
  )
;; (load-library "my_cursor")
;;;; ===== pukiwiki-mode =====
;; (defadvice pukiwiki-mode (after pukiwiki-mode-hook (arg))
;;   "run hook as after advice"
;;   (run-hooks 'pukiwiki-mode-hook))
;; (ad-activate 'pukiwiki-mode)
;; (add-hook 'pukiwiki-mode-hook) ; Thers seems no pukiwiki-mode-hook
;;(require 'my_pukiwiki)
;;(autoload 'my_pukiwiki "my_pukiwiki" nil);++test

(load-library "my_hook") ; `my_hook' is loaded to override hooks of the other libraries.
;;-----------------------------------------------
;;(message (format " read %s" (c-get-current-file)))
(let ((jobenv "~/.jobenv.el"))
  (if (file-exists-p jobenv) ;; write job specific env, like as CLASSPATH, INCLUDE_DIR, etc here.
    (progn
      (message "jobenv file found at %s" jobenv)
      (load-file jobenv))
  (message "No jobenv file loaded.")
  ))
(message (format " read %s" "nil.el"))

;;; nil.el ends here
