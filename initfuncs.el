;;; This file is specified with `auto-async-byte-compile-init-file'
;;; which is defined in `auto-async-byte-compile.el'.
(setq debug-on-signal t)
(condition-case nil
    (progn
      ;; (debug-on-entry 'tramp-set-syntax)
      ;; (autoload 'tramp-set-syntax "tramp") ; Suppress error when loading `ffap'.
      ;; (load-file "tramp") ; Suppress unknown error "Symbol’s function definition is void: tramp-set-syntax"
      (load-file "ffap")
      (load-file "~/.emacs.d/nillib/myconf/my_cask.el") ; Append load-path of packages installed via Cask.
      )
  (error (message "%S"))
  )

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
