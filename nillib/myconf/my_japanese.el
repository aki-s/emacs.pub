;;; my_japanese.el: --- my_japanese (@see my_face.el)
;;; Commentary:
;;; Code:

(cond
 ((< emacs-major-version 23)

  ;;needless;; ;; 全角空白、Tab、改行表示
  ;;needless;; (require 'jaspace)
  ;;needless;; (setq jaspace-alternate-jaspace-string "□")
  ;;needless;; (setq jaspace-alternate-eol-string "↓\n")
  ;;needless;; (setq jaspace-highlight-tabs t)
  ;;needless;; (setq jaspace-modes
  ;;needless;;         '(
  ;;needless;;         'org-mode
  ;;needless;;         'scheme-mode
  ;;needless;;                      'php-mode
  ;;needless;;                      'yaml-mode
  ;;needless;;                      'js-mode
  ;;needless;;                      'ruby-mode
  ;;needless;;                      'text-mode
  ;;needless;;                      'fundamental-mode
  ;;needless;;                      'yatex-mode
  ;;needless;;                      'LaTeX-mode))
  ;;needless;; (setq jaspace-mode-string " jp")

  ); 23
 ((>= emacs-major-version 23)

  )
 );cond emacs-major-version


;; ------------------------------------------------
;; Language
;; ------------------------------------------------
;; Japanese setting ; ref. http://osx.miko.org/index.php/Beginning_OS_X_10.5/
;;Emacsの文字コード指定. 左下の EEE や uuu という3文字の表示は (keyboard)(terminal )(buffer-file) それぞれのエンコーディングを示している.
;;Avoid illegal character of Japanese


;; prevent illegal character out put when compile in emacs
(set-language-environment "Japanese")

;; for canna input
;; http://www.stex.phys.tohoku.ac.jp/~ohba/canna/node2.html

;;  (if (and (boundp 'CANNA) CANNA)
;;         (progn
;;          (load-library "canna")
;;          (canna) ))


(cond ;http://sakito.jp/emacs/emacsshell.html#emacs-shell-mode
 ;; (  (eq window-system 'nil)
 ;; ())
 ;;-----------------------------------DARWIN---------------------------------------------------------------
 (  (or (eq window-system 'mac) (eq window-system 'ns) )
    ;; Mac OS X の HFS+ ファイルフォーマットではファイル名は NFD (の様な物)で扱うため以下の設定をする必要がある
    (require 'ucs-normalize)
    (setq file-name-coding-system 'utf-8-hfs)
    (setq locale-coding-system 'utf-8-hfs)

    (prefer-coding-system 'utf-8-unix)
    (set-keyboard-coding-system 'utf-8-unix)
    (set-terminal-coding-system 'utf-8-unix)
    (set-buffer-file-coding-system 'utf-8-unix)
    )

 ;;-----------------------------------CYGWIN---------------------------------------------------------------
 ( (or (eq system-type 'cygwin) (eq system-type 'windows-nt) )
   ;;    (setq file-name-coding-system 'utf-8)
   ;;   (setq locale-coding-system 'utf-8)
   (prefer-coding-system 'shift_jis-dos)
   (set-keyboard-coding-system 'shift_jis-dos)
   (set-terminal-coding-system 'shift_jis-dos)
   (set-buffer-file-coding-system 'shift_jis-dos)
   ;;'(default ((t (:family "Arial" :foundry "outline" :slant normal :weight normal :height 96 :width normal))));; test
   ;; もしコマンドプロンプトを利用するなら sjis にする
   ;; (setq file-name-coding-system 'sjis)
   ;; (setq locale-coding-system 'sjis)
   ;; 古い Cygwin だと EUC-JP にする
   ;; (setq file-name-coding-system 'euc-jp)
   ;; (setq locale-coding-system 'euc-jp)
   )

 ( (eq system-type 'gnu/linux)


   (prefer-coding-system 'utf-8-unix)
   (setq keyboard-coding-system 'utf-8-unix)
   (setq-default terminal-coding-system 'utf-8-unix)
   (setq buffer-file-coding-system 'utf-8-unix)
   ;;(setq default-input-method "japanese-anthy-uim" ) ;; don't work on mode-line
   ;;(setq default-input-method "japanese-anthy" )
   ;; (setq default-input-method "japanese-skk" )
   ;;(setq default-input-method "japanese-skk-auto-fill" )
   (when (require 'skk nil t)
     (set-input-method "japanese-skk-auto-fill" )
     )
   ;;; C-x j , skk-auto-fill-mode
   ;;; skk-tuttorial
   (when (and (executable-find "mozc_emacs_helper")
              (file-readable-p "/usr/share/emacs/site-lisp/emacs-mozc/mozc.el");; ubuntu
             ;; (require 'mozc nil t)
              (load-file "/usr/share/emacs/site-lisp/emacs-mozc/mozc.el")
              )
     (set-input-method "japanese-mozc")
     )
   (message "Configured input method for Linux")
   )

 (t
  (set-language-environment "Japanese")
  (prefer-coding-system 'utf-8)
  (setq keyboard-coding-system 'utf-8)
  (setq-default terminal-coding-system 'utf-8)
  (setq buffer-file-coding-system 'utf-8)

  )
 )

;; debug
(message (format "DEBUG: keyboard-coding-system %s" keyboard-coding-system))
(message (format "DEBUG: terminal-coding-system %s" terminal-coding-system)) ; characters output to the terminal
(message (format "DEBUG: buffer-file-coding-system %s" buffer-file-coding-system))
(message (format "DEBUG: file-name-coding-system %s" file-name-coding-system))
(message (format "DEBUG: default-file-name-coding-system %s" default-file-name-coding-system))
;; -------------------- IMPROVE -----------------------
;; set Unicode only for *.el files on Cygwin

(provide 'my_japanese)
;;; my_japanese.el ends here
