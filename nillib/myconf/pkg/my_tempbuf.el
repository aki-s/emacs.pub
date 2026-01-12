;;; package: --- tmpbuf
;;; Commentary:
;;; Code:
;;;; TBD
;; Enable tempbuf-mode when buffer is opened without find-file().
(require 'tempbuf)
(setq tempbuf-mode-line-string " TB")
(defvar my_tempbuf-debug nil)
(defvar my_tempbuf-ignore-regex nil "ignore if buffer name matches, even when tempbuf-mode")
;; (setq my_tempbuf-ignore-regex "\\*\\(eshell\\|Help\\|Messages\\|scratch\\)\\*")
(setq my_tempbuf-ignore-regex "[ \t]*\\*\\(eshell\\|Help\\|Minibuf.*\\|Messages\\|scratch\\|Tern\\|ggtags-global\\)\\*")

(eval-when-compile (require 'cl)) ; remove-if
(declare-function remove-if "cl")

(defvar tempbuf-check-interval 3600 "[sec]")
(defun turn-on-tempbuf-mode ()
  "@dev overwrited
Turn on tempbuf mode.

See also function `tempbuf-mode'."
  (when (not tempbuf-timer)
    (setq tempbuf-timer (run-at-time 15 tempbuf-check-interval 'tempbuf-check-buffers)))
  (setq tempbuf-activation-time (current-time))
  (setq tempbuf-mode t)
  (tempbuf-grace)
  (add-hook 'post-command-hook 'tempbuf-post-command nil t)
  (tempbuf-post-command)
  (run-hooks 'tempbuf-mode-hook))


(defun my_tempbuf-buffer-list()
  "Remove buffer maching my_tempbuf-ignore-regex from (buffer-list)"
  (remove-if
   #'(lambda (buf)
       ;; (find (buffer-name buf) my_tempbuf-ignore-regex :test #'equal))
       (let* (
              (bufname (buffer-name buf))
              (idx (string-match my_tempbuf-ignore-regex bufname))
              ;;             (ignore-buf (match-string idx bufname) )
              )
         (if (and my_tempbuf-debug idx)
             (message "my_tempbuf: %s is ignored" bufname)
           ;; (message "my_tempbuf: %s is to be deleted" bufname)
           )
         (if idx
             ;;bufname nil))) ;; PREDICATE
             (prog1
                 bufname; return bufname
               (my_tempbuf-turn-off-tempbuf-mode bufname)
               )
           nil))) ;; PREDICATE for remove-if
   (buffer-list);; SEQ for remove-if
   ); remove-if
  )

(defun my_tempbuf-turn-off-tempbuf-mode(buf)
  (set-buffer buf)
  (setq tempbuf-mode nil)
  ;;(message "my_tempbuf-turn-off-tempbuf-mode: %s is off" buf); for debug
  )

(defun my_tempbuf-turn-on-tempbuf-mode(buf)
       (set-buffer buf)
       (setq tempbuf-mode t)
  )

(defun tempbuf-check-buffers ()
  "overwritten by my_tempbuf"
  (let ((ct (current-time)))
    (mapcar
     (lambda (buffer)
       (with-current-buffer buffer
         (when tempbuf-mode
           (if (get-buffer-window buffer t)
               (progn
                 (tempbuf-post-command)
                 (tempbuf-grace ct))
             (when (and (> (tempbuf-time-diff ct tempbuf-last-time)
                           tempbuf-timeout))
               (tempbuf-expire ct))))))
     (my_tempbuf-buffer-list))))

(define-globalized-minor-mode global-tempbuf-mode
  ;; idea is from evil-integration.el and undo-tree.el
  tempbuf-mode turn-on-tempbuf-mode
  )
(global-tempbuf-mode 1);; enable tempbuf-mode in all buffers

(setq tempbuf-kill-message nil) ;; when debug
;; (setq tempbuf-kill-message t)
(setq tempbuf-life-extension-ratio 20)
;;(setq tempbuf-life-extension-ratio 1.5)  ;; shorten life of buffers.
(defun toggle-my_tempbuf-debug ()
  "@dev"
  (interactive)
  (if my_tempbuf-debug
      (progn
        (setq my_tempbuf-debug nil)
        (setq tempbuf-kill-message nil)
        (setq tempbuf-life-extension-ratio 1.1)
        (message "my_tempbuf-debug is off")
        )
    (progn
      (setq my_tempbuf-debug t)
        (setq tempbuf-kill-message t)
      (setq tempbuf-life-extension-ratio 20)
      (message "my_tempbuf-debug is on")
      )
    );if
  )
(defun my_tempbuf-enalbe-tempbuf-mode-allbuffer ()
  (interactive)
  (map nil 'my_tempbuf-turn-on-tempbuf-mode (buffer-list))
  )

(defun my_tempbuf-disalbe-tempbuf-mode-allbuffer ()
  "@dev"
  (interactive)
  ;;(map nil 'my_tempbuf-turn-on-tempbuf-mode (buffer-list))
  )

;;--------------------------------------------------
(my_tempbuf-enalbe-tempbuf-mode-allbuffer)

(defun my_tempbuf-unload-function()
  "@dev"
  (interactive)
  )
;;--------------------------------------------------
(provide 'my_tempbuf)
;;; my_tempbuf.el ends here
