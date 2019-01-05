;;; my_gtk-look ---
;;; Commentary:
;;; Code:
;; http://kliketa.wordpress.com/2010/08/04/gtklook-browse-documentation-for-gtk-glib-and-gnome-inside-emacs/
(when (require 'gtk-look nil t)
  (setq browse-url-browser-function
    (concatenate 'list
      browse-url-browser-function
      '(
        ("file:.*/opt/local/share/gtk-doc/html" . w3m-browse-url)
        ("file:.*/usr/share/gtk-doc/html" . w3m-browse-url)
        ("." . browse-url-firefox)
        )))

  (setq gtk-lookup-devhelp-indices
    '(
       "/opt/local/share/gtk-doc/html/*/*.devhelp*"
       "/opt/X11/share/gtk-doc/html/*/*.devhelp*"
       "/opt/local/Library/Frameworks/Python.framework/Versions/2.7/share/gtk-doc/html/*/*.devhelp*"
       "/usr/share/gtk-doc/html/*/*.devhelp*"
       "/usr/local/share/gtk-doc/html/*/*.devhelp*"
       "/usr/X11/share/gtk-doc/html/*/*.devhelp*"
       ))
                                        ;(global-set-key "\C-ch" 'gtk-lookup-symbol)
  (eval-after-load 'cc-mode '(local-set-key (kbd "C-c h") 'gtk-lookup-symbol))
  )

(provide 'my_gtk-look)
;;; my_gtk-look.el ends here
