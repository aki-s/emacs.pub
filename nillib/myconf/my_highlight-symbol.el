;;; my_highlight-symbol.el --- extension
;;; Commentary:
;;; Code:
(require 'highlight-symbol)
(require 'my_window)

(defun my_highlight-symbol-occur (&optional nlines)
  "Call `occur' with the symbol at point.
        `occur' is defined in replace.el

Each line is displayed with NLINES lines before and after, or -NLINES
before if NLINES is negative."
  (interactive "P")
  (if (thing-at-point 'symbol)
      (progn
        (unless (get-buffer "*Occur*") ; Usually buffer is named "*Occur: XXX"
          ;;(my_window-popwin-bellow 20)
          (my_window-popwin-bellow)
          ;; @TODO should use my_window-display-buffer-stingy
          )
        (occur (highlight-symbol-get-symbol) nlines)
        (setq truncate-lines nil)
        )
    (error "No symbol at point")))

;;(global-set-key [(shift f4)] 'highlight-symbol-at-point)
(global-set-key (kbd "M-s h") 'highlight-symbol-at-point)
;; (global-set-key [(control f3)] 'highlight-symbol-next)
;; (global-set-key [(meta f3)] 'highlight-symbol-prev)
(global-set-key (kbd "M-s n") 'highlight-symbol-next)
(global-set-key (kbd "M-s p") 'highlight-symbol-prev)
;;; Overwrite (move-to-window-line arg)
;;(global-set-key [(meta r)] 'highlight-symbol-query-replace)
(global-set-key (kbd "M-s r") 'highlight-symbol-query-replace)
(global-set-key (kbd "M-s o") 'my_highlight-symbol-occur)

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
