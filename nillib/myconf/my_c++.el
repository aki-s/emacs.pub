;;; packages --- my_c++.el
;;; Commentary:
;;; Code:

(eval-when-compile (require 'my_macro)); for macro load-library-nodeps

;; (load-library-nodeps "my_doc_cpp" 'my_doc_cpp)
(load-library-nodeps "my_doc_cpp")
(load-library-nodeps "my_auto-complete" 'my_auto-complete)

;;-----------------------------------------------------------
;; semantic
;;-----------------------------------------------------------
;;;; semantic/bovine/c.el
;; @test 
;; search pass for include dir
(setq semantic-c-dependency-system-include-path
      '(
        "/usr/include/c++/4.47"
        ))
(setq semantic-default-c-path 
        '(
          "/usr/include"
          ))

;;-----------------------------------------------------------
;; ffap
;;-----------------------------------------------------------
;; see ffap-alist
(let ((inc-path (getenv "INCLUDE")))
   (if inc-path (setq ffap-c-path (split-string (getenv "INCLUDE") ":")))); set to use "INCLUDE" for header search path for find-file-at-point

;;-----------------------------------------------------------
;; find-file
;;-----------------------------------------------------------
;;$no-more-used?;; (setq cc-search-directories
;;$no-more-used?;;   '("." "./include" "/usr/include/*" "/usr/local/include/*")
;;$no-more-used?;;   ;; $INCLUDE
;;$no-more-used?;;   )

(provide 'my_c++)
(message "my_c was loaded")

;;; my_c++.el ends here
