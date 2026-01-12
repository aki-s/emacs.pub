;;; my_server-start.el --- 

;; Copyright (C) 2012  U-T420-4143\administratorNHT

;; Author: U-T420-4143\administratorNHT <administratorNHT@T420-4143>
;; Keywords: 

(require 'server)
;;(unless (server-socket-dir)
(unless (file-exists-p (format "/tmp/emacs%d/server" (user-uid)))
  (setq server-socket-dir (format "/tmp/emacs%d" (user-uid)))
  (server-start)
  (setq frame-title-format (format "SOCKET: %s" server-name))
  )
;; (setq server-use-tcp t)


;; ref. 

(ignore-errors ;; this prevents error when environment variable is not set
  (when (not (string-match "server" server-name))
    (setq default-frame-alist
          (append default-frame-alist
                  '((background-color . "#93DB80")
                    (cursor-color . "yellow")
                    )))
    ;; or set a color-theme, e.g., (color-theme-classic)
    )
  (when (string-match "server1" server-name)
    (setq default-frame-alist
          (append default-frame-alist
                  '((background-color . "yellow")
                    ;; (foreground-color . "black")
                    (cursor-color . "blue")
                    )))
    ))

(provide 'my_server-start)
