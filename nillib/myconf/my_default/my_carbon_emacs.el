;; FULL SCREEN START
(add-hook 'window-setup-hook
	  (lambda ()
	    (set-frame-parameter nil 'fullscreen 'fullboth)
	    )
	  )
;; FULL SCREEN END

(setq inhibit-startup-message t)
(setq next-line-add-newlines nil)
(setq make-backup-files nil)

(line-number-mode t) ; display line num.
(column-number-mode t) ; display column num.
					;(show-paren-mode t)
(blink-cursor-mode 0)

(menu-bar-mode nil)
(tool-bar-mode nil)
(set-frame-parameter (selected-frame) 'alpha '(85 50))

;;Color
;; (if window-system (progn
;;    (set-background-color "Black")
;;    (set-foreground-color "LightGray")
;;    (set-cursor-color "Gray")
;;    (set-frame-parameter nil 'alpha 80)
;;    ))


;;(set-face-background 'region "gray90")
