;;; my_buffer-menu --- Customize buff-menu
;;; Commentary:
;;; Code:

(if (> 24 emacs-major-version)
    ;; list-buffers-noselect cause error
    (require 'buff-menu+)
  )
;;; M-x ibuffer is sufficient
(global-set-key "\C-x\C-b" 'ibuffer)

(provide 'my_buffer-menu)
;;; my_buffer-menu.el ends here
