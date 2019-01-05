;;; my_header-line.el --- Customize header-line-format
;;; Commentary:
;;; Code:
;;@TBD
;; user header line for which-func <- Conflict with tabbar or elscreen.

;; (setq header-line-format sticky-buffer-previous-header-line-format)
(require 'which-func)
(defvar header-line-format-custom
  '((:eval
      (let ((fun (progn
                   (propertize
                     (format "%s" (gethash (selected-window) which-func-table which-func-unknown))
                     'face 'frame-title-face))))
        (when (and (not (equal fun "nil")) which-func-mode)
          fun)))))

(setq-default header-line-format header-line-format-custom)

(defun toggle-header-line-format()
  (interactive)
  (setq header-line-format header-line-format-custom))

;; (add-hook 'find-file-hook 'toggle-header-line-format)

(provide 'my_header-line)
;;; my_header-line.el ends here
