;;;; Zen Coding Mode
;;; http://www.goodpic.com/mt/archives2/2010/02/emacs_zencoding.html

(require 'zencoding-mode) ;
;;(autoload 'zencoding-mode);;test

(add-hook 'sgml-mode-hook 'zencoding-mode)
(add-hook 'html-mode-hook 'zencoding-mode)
(add-hook 'text-mode-hook 'zencoding-mode)

;;(define-key zencoding-preview-keymap "\C-i" 'zencoding-preview-accept)
(define-key zencoding-preview-keymap (kbd "<C-return>") 'zencoding-preview-accept)

;; yasnippet を利用している環境でzencoding-modeを使う人は、zencoding-expand-line の代わりに zencoding-expand-yas を利用すべし。
;;(define-key zencoding-mode-keymap "\C-i" 'zencoding-expand-line) 
;; (define-key zencoding-mode-keymap (kbd "<C-return>") 'zencoding-expand-line) 
(define-key zencoding-mode-keymap (kbd "<C-return>") 'zencoding-expand-yas)

