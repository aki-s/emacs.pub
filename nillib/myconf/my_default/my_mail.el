(autoload 'wl "wl" "Wanderlust" t)
(autoload 'wl-other-frame "wl" "Wanderlust on new frame." t)
(autoload 'wl-draft "wl-draft" "Write draft with Wanderlust." t)
(add-to-list 'load-path "~/.emacs.d/wanderlust/")
(add-to-list 'load-path "~/local/share/emacs/site-lisp/wl/")
(setq ssl-program-name "openssl")

;;(add-to-list 'load-path "~/.emacs.d/wanderlust/wl-version/wl")
;;(add-to-list 'load-path "~/work/wl-version/elmo")

;; アイコンを置くディレクトリ
;; XEmacs の package としてインストールされている場合は必要ありません。
(setq wl-icon-directory
      (cond
       ((featurep 'mac-carbon) "/Applications/Emacs.app/Contents/Resources/share/etc/wl")
       ((featurep 'nil) "/opt/local/share/emacs/23.2/etc/wl/icons/")
       ((featurep 'dos-w32) "d:/cygwin/usr/local/emacs/etc/wl")))

;;;emacs で、デフォルトのメーラーを wanderlust にする場合、下記を追加します。

(autoload 'wl-user-agent-compose "wl-draft" nil t)
(if (boundp 'mail-user-agent)
    (setq mail-user-agent 'wl-user-agent))
(if (fboundp 'define-mail-user-agent)
    (define-mail-user-agent
      'wl-user-agent
      'wl-user-agent-compose
      'wl-draft-send
      'wl-draft-kill
      'mail-send-hook))
