;;; package: --- my_emmet-mode
;;; Commentary:
;; emmet is successor of yasnippet?
;;;; https://github.com/smihica/emmet-mode
;; If you want the cursor to be positioned between first empty quotes after expanding:
;;; Code:

;; Or if you don't want to move cursor after expandin:
;; (setq emmet-move-cursor-after-expanding nil) ;; default t
;; http://qiita.com/ironsand/items/55f2ced218949efbb1fb
(require 'emmet-mode) ;; successor of zen-coding-mode
(setq emmet-move-cursor-between-quotes t) ;; default nil
(setq emmet-preview-default nil) ;; t cause error 'expr undefined'

;; (add-hook 'emmet-mode-hook (lambda () (setq emmet-indentation 2)))

;;$ (eval-after-load "emmet-mode"
;;$   '(define-key emmet-mode-keymap (kbd "C-j") nil))
;;$ (keyboard-translate ?\C-i ?\H-i) ;;C-i と Tabの被りを回避
;;$ (define-key emmet-mode-keymap (kbd "H-i") 'emmet-expand-line) ;; C-i で展開

(provide 'my_emmet-mode)
;;; my_emmet-mode.el ends here
