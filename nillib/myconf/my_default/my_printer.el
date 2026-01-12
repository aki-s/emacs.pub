;; ------------------------------------------------
;; emacs からのプリントアウトの設定
;; コマンドは M-x ps-print-buffer
;; ------------------------------------------------
(setq ps-multibyte-buffer 'non-latin-printer)
(require 'ps-mule)
(defalias 'ps-mule-header-string-charsets 'ignore)
