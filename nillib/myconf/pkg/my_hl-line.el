;;; http://www.bookshelf.jp/soft/meadow_31.html#SEC444
;;; http://d.hatena.ne.jp/o0cocoron0o/20101006/1286354957

(global-hl-line-mode)

(defface my-hlline-face
  '(
    ;; 背景が dark ならば 背景を黒に.
    (((class color) (background dark))
     (:background "blue" :foreground "white"))
    ;; 背景が light ならば背景色を緑に
    (((class color) (background light))
;     (:background "ForestGreen"))
;     (:background "LightGoldenrodYellow" t))
;     (:background "blue" :foreground "white"))
;     (:background "blue" :foreground "red"))
;      (:foreground "green" ))
      (:background "blue" ))
;     (:background "blue" :foreground "black"))
;    (t (:bold t)))
    (t  ()))
  "*Face used by hl-line.")
(setq hl-line-face 'my-hlline-face)
;(setq hl-line-face 'Underline)
(set-face-underline-p hl-line-face 1)


;; '(hl-line ((t (:inherit highlight :foreground "black"))))
