;;; package --- ""
;;; Commentary:
;;; Code:
(require 'helm)
(require 'helm-config)
(eval-when-compile (require 'helm-gtags)) ; helm-gtags-mode-map
(setq helm-gtags-auto-update t) ; update gtag
;;;; 初期は無効にしておく iserch 中にM-m で toggle できる
(setq-default migemo-isearch-enable-p nil)

(declare-function helm-mode "helm")
(helm-mode 1)
;; (setq helm-exit-idle-delay nil)

(global-set-key (kbd "C-h C-h") 'helm-mini)
(global-set-key (kbd "C-h C-s") 'helm-occur-from-isearch) ; require helm-regexp
(global-set-key (kbd "C-s") 'isearch-forward)
;;(global-set-key (kbd "M-o M-o") 'helm-imenu)

;; Enable helm-gtags-mode
(add-hook 'c-mode-hook 'helm-gtags-mode)
(add-hook 'c++-mode-hook 'helm-gtags-mode)
(add-hook 'emacs-lisp-mode-hook 'helm-gtags-mode)
(add-hook 'java-mode-hook 'helm-gtags-mode)
(add-hook 'scala-mode-hook 'helm-gtags-mode)

;; Set key bindings
(eval-after-load "helm-gtags"
  '(progn
  ;;   (define-key helm-gtags-mode-map (kbd "M-r M-t") 'helm-gtags-find-tag)
  ;;   (define-key helm-gtags-mode-map (kbd "M-r M-r") 'helm-gtags-find-rtag)
  ;;   (define-key helm-gtags-mode-map (kbd "M-r M-s") 'helm-gtags-find-symbol)
  ;;   (define-key helm-gtags-mode-map (kbd "M-r M-p") 'helm-gtags-parse-file)
  ;;   (define-key helm-gtags-mode-map (kbd "C-c <") 'helm-gtags-previous-history)
  ;;   (define-key helm-gtags-mode-map (kbd "C-c >") 'helm-gtags-next-history)
  ;;   (define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-pop-stack))
       (define-key helm-gtags-mode-map (kbd "M-<") 'helm-gtags-previous-history)
       (define-key helm-gtags-mode-map (kbd "M->") 'helm-gtags-next-history)
))
(global-set-key (kbd "M-L") 'helm-gtags-find-files) ; Find file from GTAGS
(global-set-key (kbd "M-T") 'helm-gtags-find-pattern) ;; global -g --format=grep PATTERN ?
(global-set-key (kbd "M-F") 'helm-gtags-parse-file) ;; globa -f FILE ; Can be alternative to 'imenu
(global-set-key (kbd "M-D") 'helm-gtags-find-tag) ;; Find definition from GTAGS

(eval-after-load "cperl-mode"
  (helm-perldoc:setup)
  )
;; (global-set-key (kbd "M-O") 'helm-imenu)
;;todo (global-set-key (kbd "C-x 4 M-O") 'helm-imenu-open-in-other-window)
(require 'helm-ls-git)
(global-set-key (kbd "M-E") 'helm-ls-git-ls) ; List file in 'git ls-files'

(require 'helm-xref)
(setq xref-show-xrefs-function 'helm-xref-show-xrefs)

(use-package helm-dash) ; doc

(provide 'my_helm)
;;; my_helm.el ends here
