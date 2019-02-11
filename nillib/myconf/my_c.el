;;; package: --- my_c.el
;;; Commentary:
;;; Code:

;;;; http://www.info.kochi-tech.ac.jp/y-takata/index.php?%A5%E1%A5%F3%A5%D0%A1%BC%2Fy-takata%2FFlymake

;;; compile command
;;  M-h v compile-command
(defun my-c-compile-command ()
  (unless (or (file-exists-p "makefile")
              (file-exists-p "Makefile"))
    (set (make-local-variable 'compile-command)
         (concat "clang -o "
                 (file-name-sans-extension (file-name-nondirectory (buffer-file-name)))
                 " "
                 (file-name-nondirectory (buffer-file-name))
                 ))))

(add-hook 'c-mode-hook 'my-c-compile-command)

;;test_comment_out;; (require 'my_auto-complete-clang-async) ;; Don't know why, auto-async-byte-compile vomit error here.

;;;; useful
(require 'google-c-style) ;; set of configs to override properties
(add-hook 'c-mode-common-hook 'google-set-c-style)
(add-hook 'c-mode-common-hook 'google-make-newline-indent)

(defun my-c-mode-common-hook ()
  (require 'hideshow)
  (hs-minor-mode 1)

  (require 'flyspell)
  (flyspell-prog-mode)

  (require 'my_company)
  (company-mode 1)

  (auto-fill-mode 1)
  (modify-syntax-entry ?_ "w")
  (setq truncate-lines 0)
  (local-set-key (kbd "C-c o") 'ff-find-other-file)

  ;; (setq doxymacs-doxygen-dirs '(("^/Users/grant/Development/Licenser/"
  ;; "http://oldclicker.cedrus.sp/licenser-html/licenser.xml"
  ;; "http://oldclicker.cedrus.sp/licenser-html/")
  ;;("^/Users/grant/Development/svn/SuperLab_4.0.x/"
  ;; "http://oldclicker.cedrus.sp/superlab-html/superlab.xml"
  ;; "http://oldclicker.cedrus.sp/superlab-html/")
  ;;)
  ;;    )
;;TOOSLOW;;  (when (and (not (string-match "/usr/include" (expand-file-name default-directory)))
;;TOOSLOW;;             (and (not (string-match "/usr/local" (expand-file-name default-directory)))
;;TOOSLOW;;                  (and (not (string-match "/Library" (expand-file-name default-directory)))
;;TOOSLOW;;                       (and (not (string-match "/System" (expand-file-name default-directory)))
;;TOOSLOW;;                            (and (not (string-match "/Developer" (expand-file-name default-directory)))
;;TOOSLOW;;                                 (and (not (string-match "/Users/grant/Development/RCX/External" (expand-file-name default-directory)))
;;TOOSLOW;;                                      (and (not (string-match "/var" (expand-file-name default-directory)))
;;TOOSLOW;;                                           (and (not (string-match "/tmp" (expand-file-name default-directory)))
;;TOOSLOW;;                                                (not (string-match "/opt" (expand-file-name default-directory)))))))))))
;;TOOSLOW;;    (gl-gtags-create-or-update))
  )

(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

;;$;; (c-file-style)
;;$;; (c-toggle-auto-hungry-state 1)
;;$;; (define-key c-mode-base-map "\C-m" 'newline-and-indent)

(eval-when-compile (load-library "ffap"))
(let ((inc-path (getenv "INCLUDE")))
  (if inc-path (setq ffap-c-path (split-string inc-path ":")))); set to use "INCLUDE" for header search path for find-file-at-point

;;test (setq ffap-c-path (ffap-list-env "INCLUDE")
;; find-file-at-point == ffap
;;; ffap-prompter
;;;; ffap-guesser
;;;;; ffap-file-at-point
;;;;;; ffap-string-at-point


(require 'mode-local)
(require 'my_rtags)

(define-mode-local-override my_imenu-jump c-mode (target) "Overridden `my_imenu-jump'"
  (interactive)
  (let ((ret (if target (or (rtags-find-symbol-at-point)
                            (rtags-find-references-at-point))
               (rtags-imenu))))
    (message "my_imenu-jump-c-mode => %S" ret)
    (setq my_rtags--current-buffer (current-buffer))
    (setq my_rtags--current-point-marker (point-marker))
    )
  )

(require 'clang-format)
(define-key c-mode-map (kbd "C-M-\\") 'clang-format-region)

(provide 'my_c)
;;; my_c.el ends here
