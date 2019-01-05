;;; package: ---
;;; Commentary:
;;;; == Install ==
;; M-x auto-install-from-emacswiki
;; php-mode-improved
;;
(when (require 'php-mode nil 'noerror)
  ;; MacOSX: Macports php-mode.el
  ;; http://itpro.nikkeibp.co.jp/article/COLUMN/20070219/262441/
  (add-hook 'php-mode-user-hook
            '(lambda ()
               (setq tab-width 2)
               (setq indent-tabs-mode nil)
               (setq php-manual-path "~/.emacs.d/share/doc/php/php-chunked-xhtml")
               ))

  (defun php-mode-hooks ()
    ;;      (web-mode)
    (hs-minor-mode 1)
    (require 'php-completion);; http://tech.kayac.com/archive/php-completion.html
    (php-completion-mode t)
    (define-key php-mode-map (kbd "C-o") 'phpcmp-complete) ; :key:
    (when (require 'auto-complete nil t)
      (make-variable-buffer-local 'ac-sources)
      (add-to-list 'ac-sources 'ac-source-php-completion)
      (auto-complete-mode t)))
  (add-hook  'php-mode-hook 'php-mode-hooks)
  )
(when    (require 'php-doc nil t)
  (setq php-doc-directory "~/.emacs.d/share/doc/php/php-chunked-xhtml")
  (defun  my-php-doc-hook()
    (local-set-key "\t" 'php-doc-complete-function) ; :key:
    (eval-after-load 'php-mode
          '(local-set-key (kbd "\C-c h") 'php-doc)) ; :key:
    (set (make-local-variable 'eldoc-documentation-function)
         'php-doc-eldoc-function)
    (eldoc-mode 1))
  (add-hook 'php-mode-hook 'my-php-doc-hook)
)


(provide 'my_php-mode)
;;; my_php-mode.el ends here
