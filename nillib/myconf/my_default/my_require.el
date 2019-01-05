;;;; ref. http://cloverrose.hateblo.jp/entry/2013/04/12/145825
(defvar rootpath (expand-file-name "~/.emacs.d"))
(setq load-path (cons (concat rootpath "/elisp")load-path))

;; submodule関連
(defvar elisp-package-dir (concat rootpath "/elisp"))
(defun submodule (dir)
  (push (format "%s/%s" elisp-package-dir dir) load-path))
(defun require-submodule (name &optional dir)
  (push (format "%s/%s" elisp-package-dir (if (null dir) name dir)) load-path)
  (require name))

;;;; auto-complete
;; 基本設定
(submodule "auto-complete")
(require-submodule 'popup "auto-complete/lib/popup")
(require-submodule 'fuzzy "auto-complete/lib/fuzzy")
