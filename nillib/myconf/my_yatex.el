(when (require 'tex-site nil t)
  (tex-fold-mode 1))
(when (require 'yatex nil t) 
  (cond 
   ((eq system-type 'darwin)
    ;;==============================
    ;;  SET Previewer 
    ;;==============================
    ;;(setq tex-dvi-view-command "/usr/local/texlive/2009/bin/universal-darwin/xdvi")
    (setq latex-run-command "platex-utf8")
    (setq tex-command "/opt/local/bin/platex")
    (setq dvi2-command "open -a Skim")
    (defvar YaTeX-dvi2-command-ext-alist
      '(("xdvi" . ".dvi")
        ("ghostview¥¥|gv" . ".ps")
        ("acroread¥¥|pdf¥¥|Preview¥¥|TeXShop¥¥|Skim" . ".pdf")))

    )
   ( (eq system-type 'gnu/linux)
     (setq  YaTeX-­inhibit-­prefix-­letter   t)
     (setq  tex-­command  "latexmk  -­pvc")  ;;保存したら自動で再コンパイル
     (setq  dvi2-­command  "evince")
     )
   );cond
  
  (add-hook 'yatex-mode-hook 'flyspell-mode)
  (custom-set-variables 
   '(flyspell-auto-correct-binding [(control ?\:)]))

  ;; texの記法は無視
  (setq ispell-parser 'tex)
  )
(provide 'my_yatex)
