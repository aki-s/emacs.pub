;;; my_clisp.el --- ""
;;; Commentary:
;;; Code:
(require 'slime)
;;$ clisp
;; (setq inferior-lisp-program "clisp")
;;$ ccl
(setq inferior-lisp-program "ccl") ;; Default Common Lisp processor as Clozure CL
(slime-setup '(slime-repl slime-fancy slime-banner))
;; SLIMEからの入力をUTF-8に設定
(setq slime-net-coding-system 'utf-8-unix)

(message "%s\n" 'buffer-file-name)

(provide 'my_clisp)
;;; my_clisp.el ends here
