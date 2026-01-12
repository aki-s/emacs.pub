;;=============================================================================
;; http://tech.lampetty.net/tech/index.php/archives/384
;; http://idita.blog11.fc2.com/blog-entry-810.html

;;  perl
;; Prerequisite:
;; flymake.el/perl-completion.el/auto-complete.el
;;
;;--------------------------------------------------------------------

;;--------------------------------------------------------------------
(defun perl-eval (beg end)
  "Run selected region as Perl code"
  (interactive "r")
  (save-excursion
    (shell-command-on-region beg end "perl"))
  )
;;--------------------------------------------------------------------
;; @linux /usr/share/man/man3/File::Find.3pm.gz

;; perl mode
(when (locate-library "cperl-mode")
  ;;  (defalias 'perl-mode 'cperl-mode)
  ;;  (autoload 'perl-mode "cperl-mode" "alternate mode for editing Perl programs" t)
  (setq
   cperl-indent-level 4
			cperl-continued-statement-offset 4
			cperl-comment-column 40)

  ;;   (setq cperl-continued-statement-offset 4)
  ;;   (setq cperl-comment-column 40)

  (define-key cperl-mode-map (kbd "C-c h") 'cperl-perldoc-at-point)
  ;;--------------------------------------------------------------------
  ;; perl-completion
  ;; http://d.hatena.ne.jp/hakutoitoi/20090208/1234069614
  ;; http://d.hatena.ne.jp/a666666/20100524/1274634774
  ;; http://d.hatena.ne.jp/sugyan/touch/searchdiary?word=*[Perl]&of=15
  (defun my-cperl-mode-hooks()
    (when (require 'auto-complete nil t)
      (auto-complete-mode t))
    (setq plcmp-use-keymap nil) ; (require 'perl-completion) より前の段階で設定する
    (when (require 'perl-completion nil t)
      (make-variable-buffer-local 'ac-sources)
      (setq ac-sources '(ac-source-perl-completion))
      ;;    (add-to-list 'ac-sources 'ac-source-perl-completion)
      (perl-completion-mode t)
      ;; plcmp-mode-mapにコマンドを割り当てていく
      (define-key plcmp-mode-map (kbd "C-c m") 'plcmp-cmd-menu)
      (define-key plcmp-mode-map (kbd "C-c s") 'plcmp-cmd-smart-complete)
      (define-key plcmp-mode-map (kbd "C-c d") 'plcmp-cmd-show-doc)
      (define-key plcmp-mode-map (kbd "C-c p") 'plcmp-cmd-show-doc-at-point)
      (define-key plcmp-mode-map (kbd "C-c c") 'plcmp-cmd-clear-all-cashes)))
  (add-hook 'cperl-mode-hook 'my-cperl-mode-hooks)
  ;;  (when (require 'cperl-mode nil t)
  ;;--------------------------------------------------------------------
  ;; flymake.el config for perl
  ;; http://unknownplace.org/memo/2007/12/21#e001
  (when (locate-library "flymake")
    (defvar flymake-perl-err-line-patterns
      '(("\\(.*\\) at \\([^ \n]+\\) line \\([0-9]+\\)[,.\n]" 2 3 nil 1)))

    (defconst flymake-allowed-perl-file-name-masks
      '(("\\.pl$" flymake-perl-init)
	("\\.pm$" flymake-perl-init)
	("\\.t$" flymake-perl-init)))

    (defun flymake-perl-init ()
      (let* ((temp-file (flymake-init-create-temp-buffer-copy
			 'flymake-create-temp-inplace))
	     (local-file (file-relative-name
			  temp-file
			  (file-name-directory buffer-file-name))))
	(list "perl" (list "-wc" local-file))))

    (defun flymake-perl-load ()
      (interactive)
      (defadvice flymake-post-syntax-check (before flymake-force-check-was-interrupted)
	(setq flymake-check-was-interrupted t))
      (ad-activate 'flymake-post-syntax-check)
      (setq flymake-allowed-file-name-masks (append flymake-allowed-file-name-masks flymake-allowed-perl-file-name-masks))
      (setq flymake-err-line-patterns flymake-perl-err-line-patterns)
      (when (require 'set-perl5lib nil t)
	(set-perl5lib))
      (flymake-mode 1))

    (add-hook 'cperl-mode-hook 'flymake-perl-load)
    )

  (if (featurep 'cperl-mode)
       (run-hooks
	'my-cperl-mode-hooks
	'flymake-perl-load
       )
    (require 'cperl-mode )
    )
  )

(provide 'my_perl)
