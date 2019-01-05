;;; my_keybind --- Central place to configure key-bindings.

;;; Commentary:
;; - Load this file to configure key bindings.
;;
;; - External package may override my key-binding.
;; In this case `eval-after-load' in xx-mode-hook may be the best choice.
;; or use (define-key XXX-mode-map (kbd "xx") 'func)
;;
;; - Set in alphabetical order>

;; (global-set-key (kbd "M-L") 'func)

;;;

;;; move to the previous window.
(put 'upcase-region 'disabled nil) ;; C-x C-u

;;;https://josephhall.org/nqb2/index.php/replace_ctrlms
;;;Here's what I added to my .emacs file to map C-c m to replacing all the ^M characters in the current buffer:
;;Replace all freakin' ^M chars in the current buffer
(fset 'replace-ctrlms
   [escape ?< escape ?% ?\C-q ?\C-m return ?\C-q ?\C-j return ?!])
(global-set-key "\C-cm" 'replace-ctrlms)

(define-key global-map (kbd "C-M-¥") 'indent-region) ; OSX fails to input '\' with Ctr or Meta is pressed.

(provide 'my_keybind)
;;; my_keybind ends here
