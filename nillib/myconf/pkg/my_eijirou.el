;;test00;; (defun my_eijirou-prep-window ()
;;test00;;   "Pre-process to get windiow for sure.
;;test00;; If only a dedicated window and a buffer was shown,
;;test00;; get-buffer-create failed.
;;test00;; "
;;test00;;   (unless (get-buffer-window sdic-buffer-name 'A)
;;test00;;     (popwin:popup-buffer sdic-buffer-name)
;;test00;;       )
;;test00;;   ;;(memq sdic-buffer-name (buffer-list))
;;test00;; ;;  (buffer-live-p  sdic-buffer-name)
;;test00;;   ;;(switch-to-buffer sdic-buffer-name)
;;test00;;   ;;(pop-to-buffer sdic-buffer-name (  . ))
;;test00;;   )
;;test00;; ;;; internal func.
;;test00;; ;; sdic-word-at-point
;;test00;;
;;test00;; (defadvice sdic-describe-word (before create-sdic-buffer activate)
;;test00;; ;;; internal func.
;;test00;; ;; (set-buffer (get-buffer-create sdic-buffer-name))
;;test00;;   (my_eijirou-prep-window)
;;test00;;   )
;;test00;;
;;test00;; (defadvice sdic-describe-word-at-point (before create-sdic-buffer activate)
;;test00;;   (my_eijirou-prep-window)
;;test00;;   )
;;test00;;

(autoload 'sdic-describe-word "sdic" "Describe English word" t nil)
(autoload 'sdic-describe-word-at-point "sdic" "Describe English word at point" t nil)
(autoload 'sdic-word-at-point "sdic")

(global-set-key "\C-cw" 'sdic-describe-word)
;;(global-set-key "\C-cW" 'sdic-describe-word-at-point)
(global-set-key "\C-cW" 'sdic-describe-word-at-point-async)

(setq sdic-eiwa-dictionary-list
      '((sdicf-client "~/.emacs.d/share/dict/eijirou118.sdic")))
(setq sdic-waei-dictionary-list
      '((sdicf-client  "~/.emacs.d/share/dict/waeijirou118.sdic")))

(setq sdic-default-coding-system 'utf-8
      sdic-disable-select-window t
      )

(defun sdic-describe-word-at-point-async ()
  "Search word with deferred.
@dev Maybe heavy elisp process cannot be solved with deferred.el."
  (interactive)
  (eval-when-compile (require 'deferred) (require 'concurrent))
  (lexical-let
    ((word (sdic-word-at-point))
      (buf (get-buffer-create sdic-buffer-name)))
    (display-buffer buf)
    (deferred:$
      (cc:thread
        100000000000 ; using larget value would cause no benefit here.
        (sdic-describe-word word)
        (display-buffer buf)
        )))
  )

;;;; @TBD
;; enable migemo

(provide 'my_eijirou)

;;; my_eijirou.el ends here
