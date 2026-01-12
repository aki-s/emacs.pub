;;; package: --- load library according to system-type
;;; Commentary:
;;; Code:

(require 'pcase)

(pcase system-type
  ('darwin
   (progn
     (require 'my_migemo)
     (load-library "my_mac_indigenous")
     ))
  ('cygwin
   (progn
     (load-library "my_cygwin_indigenous")
     ))
  ('gnu/linux
   (progn
     (load-library "my_linux_indigenous")
     ))
  )
;;; my_system-type.el ends here
