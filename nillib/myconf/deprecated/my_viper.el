;;; package --- Deprecated. replaced by evil
;;; Commentary:
;; https://sites.google.com/site/fudist/Home/vimpulse/my-viper-script#mode-line

;;; Code :

;;(setq viper-mode t)
(defvar viper-mode t "Need to set before requiring 'viper.")
(require 'viper)
(setq viper-expert-level '5)
(setq viper-inhibit-startup-message 't)
;; 検索の際に大文字小文字を区別しない(smartcase)
(setq viper-case-fold-search t)
;; 検索はループする
(setq viper-search-wrap-around t)
;; オートインデントをデフォルトで有効
(setq-default viper-auto-indent t)
;; インデント幅
(setq viper-shift-width tab-width)
;;
(setq viper-fast-keyseq-timeout 0)
;; http://stackoverflow.com/questions/3230804/disable-esc-as-meta-in-emacs-viper-mode
;; (defun viper-translate-all-ESC-keysequences () nil)

;;------------------------------------
;; モードラインを強調表示
;;------------------------------------
;; モードラインの色設定 保存/復元
(defvar my-viper-default-face-background (face-background 'mode-line))
;;(setq my-viper-default-face-background (face-background 'mode-line t))
(defadvice viper-go-away (after my-viper-go-away-restore activate)
  (set-face-background 'mode-line my-viper-default-face-background )
  (set-face-foreground 'mode-line "black" )
  )
;;
;;$$cause visual-mode insert rectangle bug$$;; (defadvice viper-goto-eol (after my-viper-goto-eol+1 activate )
;;$$cause visual-mode insert rectangle bug$$;;   (forward-char 1) )

;; モードラインの色変更
;;test;; (defun my-viper-set-mode-line-face ()
;;test;;   (unless (minibufferp (current-buffer))
;;test;;     (set-face-background 'mode-line (cdr (assq viper-current-state
;;test;;     '((vi-state     . "Green")
;;test;;             ;;(insert-state . "Yellow3")))))))
;;test;;             (insert-state . "Yellow")))))
;;test;; ;;  (set-face-foreground 'mode-line "black" )
;;test;;   (set-face-foreground 'mode-line "red" )
;;test;;                ))
;;; http://www.gnu.org/software/emacs/manual/html_node/elisp/Mode-Hooks.html
(defun my-viper-set-mode-line-face () )
(add-hook 'after-change-major-mode-hook 'my-viper-set-mode-line-face)
(dolist
    (hook
     (list
      'viper-vi-state-hook
      'viper-insert-state-hook ))
  (add-hook hook 'my-viper-set-mode-line-face))

;; don't steal C-h (viper-backward-char)
;; (define-key  viper-vi-global-user-map (kbd "C-h k") 'describe-key-briefly)
(setq viper-want-ctl-h-help t)
(define-key  viper-vi-global-user-map (kbd "C-\\") 'toggle-input-method) ; undef viper-alternate-Meta-key
;; (setq-default viper-no-multiple-ESC nil)

;;;; DEBUG visual-mode insert rectangle
;;; last-command-event
(provide 'my_viper)
;;; my_viper.el ends here
