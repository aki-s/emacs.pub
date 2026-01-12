;; load this file. If you no more need 'jobenv, then just unload-feature 'jobenv.
;; If you place this file named jobenv.el at your $HOME, then automatically loaded
;; at boot time of emacs.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'tramp-default-proxies-alist
'( "\\.a\\.i\\.com"   "\\(name.*\\|name2.*\\|name3.*\\|name4\\)"  "/ssh:%h:") )

;;(semantic-add-system-include "/home/xxx" 'java-mode)
(setenv "CLASSPATH" (concat (getenv "CLASSPATH")
":./"
))

(add-to-list 'tramp-default-method-alist '("" "y91210" "ssh"))

;;;; eclipse default
(my_basic_func-eclipse-tab)
(set-language-environment "English")
(prefer-coding-system 'iso-8859-1-unix) ; europian
(setq buffer-file-coding-system 'iso-8859-1-unix)

(defun jobenv-unload-function ()
  (interactive)
  (prefer-coding-system 'utf-8)
  (setq buffer-file-coding-system 'utf-8)
  )

(defvar jobenv_column_width 80)
(add-hook 'find-file-hook #'whitespace-mode)
(eval-after-load 'whitespace
  '(progn
     (setq whitespace-style '(face lines-tail))
     (setq whitespace-line-column jobenv_column_width)))


(setq my_basic_func-tab-width 1)
(setq my_basic_func-indent-tabs-mode nil)


(defun my_basic_func-jobenv-tab ()
  "Set buffer-local variables.[Default of syunsuke aki]"
  (setq indent-tabs-mode my_basic_func-tab-width)
  (setq tab-width my_basic_func-tab-width)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(provide 'jobenv)
