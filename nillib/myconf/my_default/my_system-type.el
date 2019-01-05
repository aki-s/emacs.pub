;;; package: --- load library according to system-type
;;; Commentary:
;;; Code:

(if (eq system-type 'darwin) ;(eq window-system 'mac)
    (progn
      (require 'my_migemo)
      (load-library "my_mac_indigenous")
      ;;   (load-file "~/.emacs.d/nillib/myconf/my_carbon_emacs")
      ))
(if (eq system-type 'cygwin)
    (progn
      (load-library "my_cygwin_indigenous")
      )
  )
(if (eq system-type 'gnu/linux)
    (progn
      (load-library "my_linux_indigenous")
      )
  )

;;; my_system-type.el ends here
