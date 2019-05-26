;;; my_highlight-symbol.el --- extension
;;; Commentary:
;;; Code:
(require 'highlight-symbol)

(global-set-key (kbd "M-s h") 'highlight-symbol-at-point)
(global-set-key (kbd "M-s n") 'highlight-symbol-next)
(global-set-key (kbd "M-s p") 'highlight-symbol-prev)
(global-set-key (kbd "M-s r") 'highlight-symbol-query-replace)

;; Overwrite highlight-symbol-nav-mode-map with setq
(if (listp highlight-symbol-nav-mode-map)
    (setq-default highlight-symbol-nav-mode-map
                  (let ((map (make-sparse-keymap)))
                    ;; (define-key map "\M-s 'highlight-symbol-next)
                    (define-key map (kbd "M-s n") 'highlight-symbol-next)
                    ;;(define-key map "\M-S" 'highlight-symbol-prev)
                    (define-key map (kbd "M-s p") 'highlight-symbol-prev)
                    map)
                  ;; "Keymap for `highlight-symbol-nav-mode'.")
                  ))

(setq highlight-symbol-idle-delay 0.5)
(add-hook 'find-file-hook 'highlight-symbol-mode) ;; global minor mode

(provide 'my_highlight-symbol)
;;; my_highlight-symbol.el ends here
