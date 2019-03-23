;;; my_auto-complete-clang-async ---

;;;; How to setup emacs-clang-complete-async
;;; ref. https://github.com/Golevka/emacs-clang-complete-async

;;; [REHL type]
;; - Install packages required to compile
;; $ yum -y install llvm-debuginfo  llvm-devel   llvm-libs
;; - Compile from source (Managed with Git submodule)
;; $ cd $HOME/.emacs.d/share/clang-complete-async
;;
;;; [Darwin]
;; $ brew install emacs-clang-complete-async

;;; Commentary:

;; [WARNING]
;; - 'auto-complete-clang-async use out-of-date library 'flymake ...
;; It seems AUTO-COMPLETE-CLANG-ASYNC is not maintained and obsolete.
;;
;; [Better alternative]
;; ref. http://tuhdo.github.io/c-ide.html#orgheadline15
;; - `company-semantic' (> `company-clang' ) may be better alternatives
;; - For header name completion => `company-c-headers'

;;; Code:

(unless (executable-find "clang-complete")
  (message "Binary `clang-complete' not found.")
  (pcase system-type
    (darwin
      (if (executable-find "brew")
        (progn
          (message "Try to install clang-complete")
          (shell-command-to-string "brew install emacs-clang-complete-async")
          )
        )
      )
    )
  )

(when (and
        (require 'auto-complete)
        (require 'auto-complete-config)
        )
  (require 'auto-complete-clang-async)

  (defun my_ac-cc-timeout ()
    "Time out auto completion process to avoid extra CPU usage like when file is remote and not reachable, or when process is still running without souce buffer."
    (process-list)
    (buffer-live-p buffer)
    (kill-process)
    (if ac-clang-completion-process
      (with-current-buffer (process-buffer ac-clang-completion-process)
        )
      )
    )

  (defun my_ac-set-timer ()
    (unless my_ac-timer
      (setq my_ac-timer (run-with-idle-timer ac-delay ac-delay 'ac-update-greedy))))

  (defvar my_ac-cc-exclude-regex ()
    "@TBD:Disable autocomplete feature when file name mach regular expression my_ac-cc-exclude-regex."
    ;; (file-remote-p )
    ;; /su:spr14e@echo.yy.xx.com:/home/
    )
  (defvar my_ac-cc-allowed-regex ()
    "Allow autocomplete feature when file name mach regular expression my_ac-cc-exclude-regex."
    )
  (defun my_ac-cc-mode-setup ()
    ;;(setq ac-clang-complete-executable "~/.emacs.d/site-lisp/clang-complete")
    (setq-default ac-sources '(ac-source-clang-async))
    (ac-clang-launch-completion-process);; return process object ac-clang-completion-process
    )

  (defun my_ac-config ()
    (global-set-key "\M-/" 'ac-start)
    ;; C-n/C-p で候補を選択
    (define-key ac-complete-mode-map "\C-n" 'ac-next)
    (define-key ac-complete-mode-map "\C-p" 'ac-previous)

    (add-hook 'c-mode-common-hook 'my_ac-cc-mode-setup)
    (add-hook 'auto-complete-mode-hook 'ac-common-setup)
    (auto-complete-mode t))

  (my_ac-config)
  )

(provide 'my_auto-complete-clang-async)
;;; my_auto-complete-clang-async.el ends here.
