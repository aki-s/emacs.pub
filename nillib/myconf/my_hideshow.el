;;; package --- my_hideshow.el
;;; Commentary:
;;; Code:

(require 'hideshow)
;;;; ref. http://efreedom.com/Question/1-944614/Emacs-HideShow-Work-Xml-Mode-Sgml-Mode
;;; sgml-mode
(add-to-list 'hs-special-modes-alist
  '(sgml-mode
     "<!--\\|<[^/>]*[^/]>"                    ;; regexp for start block
     "-->\\|</[^/>]*[^/]>"                    ;; regexp for end block

     "<!--"                                   ;; regexp for comment start. (need this??)
     sgml-skip-tag-forward
     nil))

(add-to-list 'hs-special-modes-alist
  '(nxml-mode
     "<!--\\|<[^/>]*[^/]>"                    ;; regexp for start block
     "-->\\|</[^/>]*[^/]>"                    ;; regexp for end block

     "<!--"                                   ;; regexp for comment start. (need this??)
     ;;               sgml-skip-tag-forward
     nil
     nil))



;;==============================================================
;; Options
;; ref. http://www.emacswiki.org/emacs-se/HideShow#toc6
;;==============================================================
;; Hide the comments too when you do a 'hs-hide-all'
(setq hs-hide-comments-when-hiding-all nil)
;; Set whether isearch opens folded comments, code, or both
;; where x is code, comments, t (both), or nil (neither)
(setq hs-isearch-open 'code)

(defun display-code-line-counts (ov)
  "Displaying overlay content in echo area or tooltip."
  (when (eq 'code (overlay-get ov 'hs))
    (overlay-put ov 'help-echo
      (buffer-substring (overlay-start ov)
        (overlay-end ov)))))

(setq hs-set-up-overlay 'display-code-line-counts)



;;; http://www.emacswiki.org/emacs-se/HideShow#toc1
;; Finally, set up key bindings and automatically activate hs-minor-mode for the desired major modes:

;;(global-set-key (kbd "C-c \+") 'toggle-hiding)
;;(global-set-key (kbd "C-c \\") 'toggle-selective-display)

;; ;;
;; ;;(add-hook 'cperl-mode-hook      'hs-minor-mode) ;; freeze on cygwin?
;; (add-hook 'emacs-lisp-mode-hook 'hs-minor-mode)
;; (add-hook 'java-mode-hook       'hs-minor-mode)
;; (add-hook 'lisp-mode-hook       'hs-minor-mode)
;; ;;(add-hook 'perl-mode-hook       'hs-minor-mode)  ;; freeze on cygwin?
;; (add-hook 'sh-mode-hook         'hs-minor-mode)

(define-globalized-minor-mode global-hs-minor-mode
  hs-minor-mode my_hideshow-ignore-setup-failure)

(defun my_hideshow-ignore-setup-failure() (ignore-errors (hs-minor-mode)))
(global-hs-minor-mode 1)



(define-key hs-minor-mode-map (kbd "C--") 'hs-hide-level)
(define-key hs-minor-mode-map (kbd "C-+") (lambda () (interactive) (hs-hide-level 4))) ;; TODO: create appropriate function
(provide 'my_hideshow)
;;; my_hideshow ends here
