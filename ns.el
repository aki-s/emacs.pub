(load-file "~/.emacs.d/nil.el")

(setq ring-bell-function 'ignore) ; Setting both this value and `visual-bell' `nil' didn't work.
(set-frame-parameter (selected-frame) 'alpha '(80 50))
(add-to-list 'default-frame-alist '(alpha 80 50))
(my_frame-toggle-frame-maximized)
