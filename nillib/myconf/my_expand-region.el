;;; my_expand-region --- Customize expand-region
;;; Commentary:
;;; Code:
(require 'expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)

;;;; @todo
;;;  Use `|@=' as segmentator.
;;; :keyword `looking-at' `re-search-forward'

(provide 'my_expand-region)
;;; my_expand-region.el ends here
