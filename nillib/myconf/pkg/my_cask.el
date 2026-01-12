;;; my_cask.el --- my_cask
;;; Commentary: For cask version '0.9.1pre'

;;; Code:
(require 'cl)
(defalias 'defmethod 'cl-defmethod)
(require 'cask)
(require 'dash)
;; cask update --debug --verbose
(cask--initialize)

(provide 'my_cask)
;;; my_cask.el ends here
