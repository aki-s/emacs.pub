;;; package: --- tmpbuf
;;; Commentary:
;;; Code:
;;;; TBD
;; Enable tempbuf-mode when buffer is opened without find-file().
(require 'tempbuf)
(setq tempbuf-mode-line-string " TB")
(defvar my_tempbuf-debug nil)
(defvar my_tempbuf-ignore-regex nil "ignore if buffer name matches, even when tempbuf-mode")
;; (setq my_tempbuf-ignore-regex "\\*\\(eshell\\|Help\\|Messages\\|scratch\\|ECB.*\\)\\*")
(setq my_tempbuf-ignore-regex "[ \t]*\\*\\(eshell\\|Help\\|Minibuf.*\\|Messages\\|scratch\\|Tern\\|ECB.*\\|ggtags-global\\)\\*")

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

;;; ref. https://github.com/DarwinAwardWinner/dotemacs/blob/master/site-lisp/settings/tempbuf-settings.el
;;notworking;; 
;;notworking;; (defun string-ends-with (ending string) 
;;notworking;;   "Return t if the final characters of STRING are ENDING"
;;notworking;;    (string-match-p (concat ending "$") string))
;;notworking;; 
;;notworking;; (defun mode-symbol (sym)
;;notworking;;   "Append \"-mode\" to SYM unless it already ends in it."
;;notworking;;   (let ((symname (symbol-name sym)))
;;notworking;;     (intern
;;notworking;;      (concat symname
;;notworking;;              (unless (string-ends-with "-mode" symname)
;;notworking;;                "-mode")))))
;;notworking;; 
;;notworking;; (defun tempbuf-major-mode-hook ()
;;notworking;;   "Turn on `tempbuf-mode' in current buffer if buffer's `major-mode' is in `tempbuf-temporary-major-modes'.
;;notworking;; 
;;notworking;;   Else turn off `tempbuf-mode'."
;;notworking;;   (if (memq major-mode tempbuf-temporary-major-modes)
;;notworking;;       (turn-on-tempbuf-mode)
;;notworking;;     (turn-off-tempbuf-mode)))
;;notworking;; 
;;notworking;; (defun tempbuf-setup-temporary-major-modes (symbol newval)
;;notworking;;   (set-default symbol (mapcar 'mode-symbol newval))
;;notworking;;   ;; Set tempbuf-mode correctly in existing buffers.
;;notworking;;   (mapc (lambda (buf)
;;notworking;;           (with-current-buffer buf
;;notworking;;             (tempbuf-major-mode-hook)))
;;notworking;;         (buffer-list)))
;;notworking;; 
;;notworking;; (defcustom tempbuf-temporary-major-modes nil
;;notworking;;   "Major modes in which `tempbuf-mode' should be activated.
;;notworking;; 
;;notworking;;   This will cause buffers of these modes to be automatically killed
;;notworking;;   if they are inactive for a short while."
;;notworking;;   :group 'tempbuf
;;notworking;;   :set 'tempbuf-setup-temporary-major-modes
;;notworking;;   :type '(repeat (symbol :tag "Mode")))
;;notworking;; 
;;notworking;; (setq tempbuf-temporary-major-modes
;;notworking;;       '(
;;notworking;;        (fundamental-mode)
;;notworking;;        ))
;;notworking;; 
;;notworking;; (add-hook 'after-change-major-mode-hook 'tempbuf-major-mode-hook)
;;notworking;; 

;; (add-hook 'before-change-functions 'turn-on-tempbuf-mode)
;; (add-hook 'write-file-functions 'turn-on-tempbuf-mode)
;; (add-hook 'find-file-hooks 'turn-on-tempbuf-mode)
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
;;(toggle-my_tempbuf-debug)
(my_tempbuf-enalbe-tempbuf-mode-allbuffer)

(defun my_tempbuf-unload-function()
  "@dev"
  (interactive)
  )
;;--------------------------------------------------
(provide 'my_tempbuf)
;;; my_tempbuf.el ends here
