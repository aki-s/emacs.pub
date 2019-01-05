;;; my_profiler.el --- 

;; Copyright (C) 2013  

;; Author:  Syunsuke Aki
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
;; reffer profile.el as of emacs24
;; 

;;; Code:

(setq-default message-log-max 500)
(get-buffer-create "*my_profiler*")

(defvar my_profiler-call-level 0)
(defvar my_profiler-trace-level 0)


(defun my_profiler-show-require (fun)
 ; (if (or (functionp fun) )
  (message "my_profiler-show-require in")
      (princ (format (concat "%" (number-to-string my_profiler-call-level) "s%s\n") "+" (apply fun '(0))  (set-buffer "*my_profiler*")))
  (message "my_profiler-show-require out")
 ;   (error (format "%s is not function" fun))
;    )
)

(defun my_profiler-count-up-depth ()
  (setq my_profiler-call-level (1+ my_profiler-call-level)))

(defun my_profiler-count-down-depth ()
  (setq my_profiler-call-level (1- my_profiler-call-level)))

(defadvice require (around detect-require first activate)
    ;;(setq my_profiler-call-level (1+ my_profiler-call-level))
    (my_profiler-count-up-depth)
                                        ;  (princ (format (concat "%" (number-to-string my_profiler-call-level) "s%s\n") "+" (ad-get-args 0))  (set-buffer "*my_profiler*"))
    ;;(l
    (my_profiler-show-require #'ad-get-args)
    ad-do-it
    ;; (setq my_profiler-call-level (1- my_profiler-call-level))
    (my_profiler-count-down-depth)
    )

;; (memory-limit) ; actual allocation for memory?

;;;; ============================================================
;; elp.el :
;;;; ============================================================
;; M-x elp-results

(provide 'my_profiler)
;;; my_profiler.el ends here
