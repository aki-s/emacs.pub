;; ------------------------------------------------
;;; == yatex ==
;; ------------------------------------------------

;; (require 'yatex)
;; (setq auto-mode-alist
;;       (cons (cons "\\.tex$" 'yatex-mode) auto-mode-alist))
;;(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
;; (add-hook 'yatex-mode-hook (lambda ()
;;                              (TeX-fold-mode 1)))
;;; determine encoding
;; http://oku.edu.mie-u.ac.jp/~okumura/texwiki/?YaTeX#d56b9bcf
;; http://d.hatena.ne.jp/tatatat/20080531/1212237988
;;(setq YaTeX-kanji-code 4)
;; (add-hook 'yatex-mode-hook
;; 	  '(lambda ()
;; 	     (set-buffer-file-coding-system 'utf-8)))
;;	     (setq YaTeX-latex-message-code 'utf-8)))


;; LaTex? or YaTeX
;; yatexの時は、 latex-mode-hook を yatex-mode-hook にする。
;; ref.-> http://www.bookshelf.jp/pukiwiki/pukiwiki.php?%B2%BF%A4%C7%A4%E2%A5%A2%A5%A6%A5%C8%A5%E9%A5%A4%A5%F3%A5%E2%A1%BC%A5%C9#content_1_19

;;; About if-else condition:-> http://www.math.s.chiba-u.ac.jp/~matsu/lisp/emacs-lisp-intro-jp_4.html#SEC56

(if 1
    ;;; TRUE phrase
    ;; simple version
    (add-hook 
     'latex-mode-hook
     '(lambda ()
	(setq outline-regexp 
	      "\\([ \t]*\\\\\\(documentstyle\\|documentclass\\|chapter\\|section\\|subsection\\|subsubsection\\|paragraph\\)\\*?[ \t]*[[{]\\)")
	(setq 
	 outline-level 
	 (function (lambda ()
		     (save-excursion
		       (looking-at outline-regexp)
		       (let ((bs (buffer-substring (match-beginning 1) (match-end 1))))
			 (cond ((equal (substring bs 0 4) "docu") 15)
			       ((equal (substring bs 0 4) "chap") 0)
			       ((equal (substring bs 0 4) "para") (+ 5 (length bs)))
			       (t (length bs))))))))
	(outline-minor-mode t)))
  ;;; else phrase
  ;; complete version
  (add-hook 
   'latex-mode-hook
   '(lambda ()
      (setq outline-regexp 
	    "\\([ \t]*\\\\\\(documentstyle\\|documentclass\\|chapter\\|section\\|subsection\\|subsubsection\\|paragraph\\)\\*?[ \t]*[[{]\\|[%\f]+\\)")
      (setq 
       outline-level 
       (function (lambda ()
		   (save-excursion
		     (looking-at outline-regexp)
		     (cond 
		      ((equal (char-after (match-beginning 0)) 37) (- (match-end 0) (match-beginning 0)))
		      (t (let ((bs (buffer-substring (match-beginning 2) (match-end 2))))
			   (cond ((equal (substring bs 0 1) "d") 15)
				 ((equal (substring bs 0 1) "c") 0)
				 ((equal (substring bs 0 1) "p") 4)
				 ((equal (substring bs 0 2) "se") 1) ;section
				 ((equal (substring bs 0 5) "subse") 2) ;subsection
				 ((equal (substring bs 0 8) "subsubse") 3) ;subsubsection
				 (t (length bs))))))))))
      (outline-minor-mode t)))
  )

;; ------------------------------------------------
;; AUCTex
;; ------------------------------------------------
(if (eq system-type 'darwin)
    (require 'tex-site nil 'noerror)
  (add-hook 'LaTeX-mode-hook (lambda ()
			       (TeX-fold-mode 1))))

(provide 'my_latex)
