;;; my_ajoke.el --- a
;;; Commentary:
;; https://github.com/baohaojun/ajoke
; export AJOKE_DIR=~/gcode/ajoke #PLEASE MODIFY THIS TO SUIT YOUR CASE
; export export PATH=$AJOKE_DIR/bin:$PATH
; export PERL5LIB="$AJOKE_DIR/etc/perl:$PERL5LIB";

; exec-path
;;; Code:

(require 'ajoke)
(let ( (ajoke-dir (expand-file-name "~/.emacs.d/share/ajoke")) )
  (setenv "PATH" (concat (getenv "PATH")
                         ":" ajoke-dir "/bin"
                         ))
  (setenv "PERL5LIB" (concat (getenv "PERL5LIB")
                             ":"  ajoke-dir
                             ":"  ajoke-dir "/etc/perl"
                             ))
  )

(defadvice ajoke--create-index-function (after my_ajoke-debug last activate)
  "Check if ajoke's 'imenu-create-index-function is doing bad thing."
  (message "ajoke--create-index-function was used")
)

;;------------------------------------------------
;; Unload function:

(defun my_ajoke-unload-function ()
   "Unload function to ensure normal behavior when feature 'a is unloaded."
   (interactive)
   (eval-and-compile (require 'imenu))
   (setq-default imenu-create-index-function #'imenu-default-create-index-function)
)


(provide 'my_ajoke)
;;; my_ajoke.el ends here
