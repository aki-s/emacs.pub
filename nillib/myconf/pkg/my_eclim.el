;;; my_eclim.el --- 

;; Copyright (C) 2014  

;; Author:  <@>
;; Keywords: 

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; 

;;; Code:

(require 'eclim)
(require 'eclimd)

(setq
 eclimd-executable "eclimd"
  ;;; '(eclimd-default-workspace nil)
 eclimd-wait-for-process nil
 eclim-eclipse-dirs nil ;; must be set other than nil
 eclim-problems-show-pos t
 )

;;(defvar  my_eclipse_dir  nil "Location eclipse installed" ) 

;;(setq my_eclipse_dir (format "%s" (expand-file-name "~/bin/app/eclipse-indigo")))
;;(setq my_eclipse_dir `(expand-file-name "~/bin/app/eclipse-indigo"))

(defvar  my_eclipse_dir (expand-file-name "~/bin/app/eclipse-indigo") "Location eclipse installed" ) 

(defun eclim-mode-activate () 
  (interactive)
  (eclim-mode 1)
  )

(add-hook 'java-mode-hook 'eclim-mode-activate)

;;$dont work$;;    '(eclim-eclipse-dirs `(list
;;$dont work$;;                          ,my_eclipse_dir
;;$dont work$;;                          ) now))
;; (setq eclim-eclipse-dirs `(list ,my_eclipcsse_dir))
;;(setq eclim-eclipse-dirs (list my_eclipcsse_dir))
(setq eclim-eclipse-dirs `(,my_eclipse_dir))

;; '(eclimd-executable nil) ;; BUG?
;;'(eclim-executable (concat (format "%s" eclim-eclipse-dirs)) "/eclim") )

;;debug (setq eclim-executable (concat my_eclipse_dir "/eclim") )

;; (add-to-list 'exec-path eclim-eclipse-dirs)
;;(add-to-list 'exec-path (append exec-path eclim-eclipse-dirs))
(setq exec-path (append exec-path eclim-eclipse-dirs))

(eclim-mode-activate)
;;$;; Displaying compilation error messages in the echo area

;;(setq byte-compile-warnings '(not free-vars)) ;; for rng-nxml-auto-validate-flag. <- not working

(defun my_eclim-show-err ()
  (interactive)
  (setq help-at-pt-display-when-idle t)
  ;;(setq help-at-pt-timer-delay 0.1)
  (help-at-pt-set-timer)
  )
;;(my_eclim-show-err)

;;$;; Configuring auto-complete-mode

;; regular auto-complete initialization
;;$00;;  (require 'auto-complete-config)
;;$00;;  (ac-config-default)
(require 'my_auto-complete nil t)  ; require 'auto-complete-config and ac-config-default

;; add the emacs-eclim source
(require 'ac-emacs-eclim-source)
(ac-emacs-eclim-config) ;; remove important completion candidates from ac-mode?

(message "my_eclim-mode was activated.")

(global-set-key (kbd "C-S-i") 'eclim-complete) 
(provide 'my_eclim)
;;; my_eclim.el ends here
