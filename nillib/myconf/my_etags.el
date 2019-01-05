;;=============================================================================
;; http://d.hatena.ne.jp/ryo1miya/20110613/1307980874
;;=============================================================================
;; etags の TAGS ファイルを下層のディレクトリにわたって作る。
;; 
;; .emacs.el あるいは .emacs.d/init.el などに以下を記述。
;; 
(defvar etags-mode-extension-alist 
  '((c-mode          . "\\.[hc]$")
    (c++-mode        . "\\.\\(hh\\?\\|cc\\|[ch][+px]\\{2\\}\\)$")
    (objc-mode       . "\\.[hm]m\\?$")
    (java-mode       . "\\.java$")
    (perl-mode       . "\\.p[lm]$")
    (ruby-mode       . "\\.rb$")
    (python-mode     . "\\.py$")
    (javascript-mode . "\\.js$")
    (php-mode        . "\\.php$")
    (lisp-mode       . "\\.\\(c\\?l\\|c\\?lisp\\)$")
    (emacs-lisp-mode . "\\.el$")
    ))

(defun etags-shell-command-with-message (dir regexp)
  (if (catch 'exit
        (while t
          (message "creating TAGS file ...")
          (shell-command
           (concat "find " dir " -type f 2>/dev/null | grep \"" regexp "\" | xargs etags"))
          (throw 'exit t)))
      (message "done.")))

(defun etags-create-tags-custom (dir regexp)
  (interactive "Droot directory for TAGS file: \nsRegexp of extension: ")
  (etags-shell-command-with-message dir regexp))

(defun etags-create-tags-auto (dir)
  (interactive "Droot directory for TAGS file: ")
  (if (catch 'exit
        (loop for elt in etags-mode-extension-alist
              do
              (if (equal major-mode (car elt))
                  (throw 'exit
                         (etags-shell-command-with-message dir (cdr elt))))))
      t))

(defun etags-create-tags ()
  (interactive)
  (if (or (equal major-mode 'eshell-mode) (equal major-mode 'dired-mode))
      (call-interactively 'etags-create-tags-custom)
    (call-interactively 'etags-create-tags-auto)))

(global-set-key (kbd "C-M-.") 'etags-create-tags)

;; C-M-. だとモード特有のキーバインドにぶつかることがある。slimeとか。個人的に anything-c-etags-select を M-. にあてているので近い所にあてただけ。
;; 
;; etags-mode-extension-alist の該当するファイルを開いている場合は拡張子を入力する必要はない。 eshell,dired では拡張子の正規表現を手動で入力する。
;; 
;; これで anything-c-etags-select が快適になった。 gtags みたいに参照元にジャンプできないのでそこは moccur-grep と併用する。
;; 
;; 追記
;; 
;; eshell ではコマンドラインで
;; 
;;     etags **/*.[hc]
