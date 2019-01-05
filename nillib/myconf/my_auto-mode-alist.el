;;; my_auto-mode-alist.el: --- bind suffix and major-mode
;;; Commentary:
;; Uniformly management auto-mode-alist and autoload functions
;; Author:
;; Keywords: lisp,

;;; Code:
;;--------------------------------------------------------------
(autoload 'web-mode "web-mode" "" t)
(autoload 'php-mode "php-mode-improved" "php-mode" t)
(autoload 'perl-mode "cperl-mode" "alternate mode for editing Perl programs" t)
(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
(autoload 'R-mode "ess-site" "Emacs Speaks Statistics mode" t)

;;--------------------------------------------------------------
(cond
 ;;( (and (= emacs-major-version 23) (> emacs-minor-version 1))
 ( (= emacs-major-version 23)
;;$bug$;;   (autoload 'js2-minor-mode "js2-mode" "activate customized js" t)
;;$bug$;;   (add-hook 'js-mode-hook 'js2-minor-mode)
;;$bug$;;   (add-hook 'js2-minor-mode #'(lambda ()
;;$bug$;;                                (setq post-command-hook nil) ))
;;$bug$;;  (add-to-list 'auto-mode-alist '("\\.js\\'" . js-mode))
   )
 ( (> emacs-major-version 23)
   ;;(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
   (add-to-list 'auto-mode-alist '("\\.js\\'" . js-mode))
   )
 )

;;--------------------------------------------------------------
(defalias 'perl-mode 'cperl-mode)

;;--------------------------------------------------------------
(add-to-list 'auto-mode-alist '("\\.\\(tpl\\|php\\)\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.db2\\'" . sql-mode))
(add-to-list 'auto-mode-alist '("\\.dicon\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.ddl\\'" . sql-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.less\\'" . less-css-mode))
(add-to-list 'auto-mode-alist '("\\.jsp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.lua\\'" . lua-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode)) ;; http://jblevins.org/projects/markdown-mode/
(add-to-list 'auto-mode-alist '("\\.php\\'" . php-mode))
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.r$" . 'R-mode))
(add-to-list 'auto-mode-alist '("\\.R$" . 'R-mode))
(add-to-list 'auto-mode-alist '("\\.scala\\'" . scala-mode))
(add-to-list 'auto-mode-alist '("\\.scss\\'" . scss-mode))
(add-to-list 'auto-mode-alist '("\\.sqx\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.tex\\'" . yatex-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\'" . web-mode))
;; (add-to-list 'auto-mode-alist '("\\.java\\'" . malabar-mode))
;; If your template extension is tpl, "\\.phtml" becomes "\\.tpl"
;;(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode)) ;; <-conflict w3m?
;;(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
;;(add-to-list 'auto-mode-alist '("\\.php\\'" . web-mode))
;;--------------------------------------------------------------

;;   (add-to-list 'interpreter-mode-alist '("node" . js2-mode))

;;--------------------------------------------------------------
(provide 'my_auto-mode-alist)
;;; my_auto-mode-alist ends here
