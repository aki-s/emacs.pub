;; http://d.hatena.ne.jp/kiwanami/20101008/1286518936
(require 'inertial-scroll)
(setq inertias-global-minor-mode-map 
      (inertias-define-keymap
       '(
         ("<next>"  . inertias-up)
         ("<prior>" . inertias-down)
         ("C-v"     . inertias-up)
         ("M-v"     . inertias-down)
         ) inertias-prefix-key))
(inertias-global-minor-mode 1)
(setq inertias-initial-velocity 1000) ; 初速（大きいほど一気にスクロールする）
(setq inertias-friction 20)        ; 摩擦抵抗（大きいほどすぐ止まる）
(setq inertias-rebound-flash nil)
(setq inertias-rest-coef 0)         ; 画面端でのバウンド量（0はバウンドしない。1.0で弾性反発）
(setq inertias-update-time 60)      ; 画面描画のwait時間（msec）

(provide 'my_inertial-scroll)
