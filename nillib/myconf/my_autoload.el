;;; my_autoload.el ---

;; Copyright (C) 2014
;; ------------------------------------------------
;; ------------------------------------------------

;;; Code:

(eval-when-compile
  (require 'cl) ; eval-when
  )
;; @ref eval-after-load adds entry to after-load-alist

(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(autoload 'my_ecb "my_ecb" "activate customized ecb" t)
(autoload 'w3m-goto-url-new-session "my_w3m" "activate customized w3m" t)
(autoload 'browse-url "my_w3m" "activate customized w3m" t)
(eval-after-load "browse-url" (load-library "my_w3m") )
(autoload 'my_gtags "my_gtags" "activate customized gtags" t)

(autoload 'js2-mode "js2-mode" "activate customized js" t)
(autoload 'js2-minor-mode "js2-mode" "activate customized js" t)

;;(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
;;(autoload 'vline-mode "vline" "highlight column vertically" t)
(eval-after-load "term" (load-library "term+") )

(provide 'my_autoload)
;;; my_autoload.el ends here
