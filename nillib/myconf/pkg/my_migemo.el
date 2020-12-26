;;; package: --- my_migemo
;;; Commentary:
;; official: http://0xcc.net/migemo/

;; osx: http://d.hatena.ne.jp/samurai20000/20100907/1283791433
;; osx: http://wun.jp/2011/07/04/113800/

;; cmigemo: http://code.google.com/p/cmigemo/
;; https://bitbucket.org/sakito/dot.emacs.d/src/tip/site-start.d/init_cmigemo.el

;;; Code:

;;(defvar migemo-directory nil) ;; Need to be set before (require 'migemo)
(if (null (and (executable-find "cmigemo") (locate-library "migemo")))
    (message "ERROR: no executable found, cmigemo")
    (progn
;;;; cmigemo
      (setq migemo-command "cmigemo")
      (setq migemo-options '("-q" "--emacs"))
      (setq my_migemo-dict-dir (expand-file-name "~/local/share/migemo/utf-8"))
      (cond
       ((file-exists-p (concat my_migemo-dict-dir "/migemo-dict"))
        ;; install_name_tool -change libmigemo.1.dylib $(prefix)/lib/libmigemo.1.dylib  $(prefix)/bin/cmigemo
        ;; dyldinfo
        (setq-default migemo-directory my_migemo-dict-dir)
        (setq-default migemo-command "cmigemo")
        )
       ((eq system-type 'gnu/linux)
        (setq migemo-dictionary "/usr/share/cmigemo/utf-8/migemo-dict")
        )
       ((eq system-type 'darwin)
        (setq migemo-dictionary "/usr/local/share/migemo/utf-8/migemo-dict")
        )
       );cond
      (setq migemo-user-dictionary nil)
      (setq migemo-regex-dictionary nil)

;;;;;; enable cache of emacs
      (setq migemo-use-pattern-alist t)
      (setq migemo-use-frequent-pattern-alist t)
      (setq migemo-pattern-alist-length 1024)

      (setq migemo-coding-system 'utf-8-unix)


;;;; 初期は無効にしておく iserch 中にM-m で toggle できる
      (setq-default migemo-isearch-enable-p nil)
      ;;(setq migemo-coding-system 'utf-8)
      ;;     (load-library "migemo")

;;;; init at start
      (eval-and-compile (require 'migemo nil t))
      (setq migemo-use-default-isearch-keybinding nil); Stolen by C-y is annoying.
      (migemo-init)
      ))

(provide 'my_migemo)
;;; my_migemo ends here
