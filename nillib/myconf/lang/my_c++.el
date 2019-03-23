;;; packages --- my_c++.el
;;; Commentary:
;;; Code:

(eval-when-compile (require 'my_macro)); for macro load-library-nodeps
(require 'my_c)
(require 'mode-local)

(define-mode-local-override my_imenu-jump c++-mode (target) "Overridden `my_imenu-jump'"
  (interactive)
  (let ((ret (if target (or (rtags-find-symbol-at-point)
                            (rtags-find-references-at-point)
                            (helm-imenu))
               (rtags-imenu))))
    (my_imenu--debug-message "my_imenu-jump-c++-mode => %S" ret)
    (setq my_simple--current-buffer (current-buffer))
    (setq my_simple--current-point-marker (point-marker))
    )
  )

(require 'clang-format)
(define-key c++-mode-map (kbd "C-M-\\") 'clang-format-region)

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
