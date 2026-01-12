;; gdb-mi.el
;; gud.el
;; ref.
;; http://narupon.tdiary.net/20061022.html
;;; http://d.hatena.ne.jp/uhiaha888/20130304/1362382317
;;; GDB 関連

(setq gdb-use-separate-io-buffer t);;; I/O バッファを表示


;;gl;; https://github.com/glimberg/emacs/blob/master/gl-gdb.el
(defun my-gdb-mode-hook ()
  ;; (setq gdb-show-main t) ;; show source code being debugged. gdb-many-windows overwrite gdb-show-main.

  (require 'gud)
  (setq gud-chdir-before-run nil)
  (setq gud-tooltip-mode t) ;;; 変数の上にマウスカーソルを置くと値を表示
  (setq gud-tooltip-echo-area nil) ;;; t にすると mini buffer に値が表示される

  (require 'gdb-mi)
  (setq gdb-many-windows t) ;;; 有用なバッファを開くモード
  (gdb-restore-windows) ;; restore gdb-many-windows
)

(add-hook 'gdb-mode-hook 'my-gdb-mode-hook)
;; gdb -i=mi <exe>
;; gdb --fullname  <exe>

(provide 'my_gdb)

;; gud-gdb
