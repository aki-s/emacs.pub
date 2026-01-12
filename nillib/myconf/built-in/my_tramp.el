;;; my_tramp.el ---

;; ref.  http://blog.digital-bot.com/blog/2013/09/05/emacs-tramp/


(if (< max-lisp-eval-depth 5000)
    (setq max-lisp-eval-depth 5000);; avoid 'Variable binding depth exceeds max-specpdl-size'
)
(if (< max-specpdl-size 6000)
    (setq max-specpdl-size 6000)
)

;; (require 'tramp-compat)
(require 'trampver) ; required by tramp-sh
(require 'tramp-sh)
;; (require 'tramp-smb)
(require 'tramp-cache)
;; (require 'tramp-ftp)
(require 'tramp-cmds)

(when (require 'tramp nil t)
  ;;;; ref. file-name-handler-alist contains tramp-file-name-handler
  ;;;;  line 2093 in tramp.el
  (add-to-list 'tramp-methods
               '("rsudo"
                 (tramp-login-program "su")
                 (tramp-login-args
                  (;; ("-")
                   ("%u")))
                 (tramp-remote-sh "/bin/sh")
                 (tramp-copy-program nil)
                 (tramp-copy-args nil)
                 (tramp-copy-keep-date nil)
                 (tramp-password-end-of-line nil)
                 )
               )
  (add-to-list 'tramp-methods
               '("work"
                 (tramp-login-program "ssh")
                 (tramp-login-args
                  '(("%h")
                    ("-l" "%u")
                    ("-p" "%p")
                    ("-q")
                    ("-e" "none" "-t" "-t" "/usr/bin/sh")))
                 (tramp-async-args (("-q")))
                 (tramp-remote-shell "/usr/bin/sh")
                 (tramp-remote-shell-args "-c")
                 (tramp-remote-port 22)))


  (add-to-list 'tramp-methods
               '("work"
                 (tramp-login-program "ssh")
                 (tramp-login-args
                  '(("%h")
                    ("-l" "%u")
                    ("-p" "%p")
                    ("-q")
                    ("-e" "none" "-t" "-t" "/usr/bin/sh")))
                 (tramp-async-args (("-q")))
                 (tramp-remote-shell "/usr/bin/sh")
                 (tramp-remote-shell-args "-c")
                 (tramp-remote-port 22)))

  (setq-default tramp-shell-prompt-pattern "^[^#$%>]*[#$%>]+ *\\(\\[[0-9;]*[a-zA-Z] *\\)*")
                                        ;$default$;  "^[^#$%>\n]*[#$%>] *\\(\\[[0-9;]*[a-zA-Z] *\\)*"
	;; (setq tramp-shell-prompt-pattern "^[^#$%>]*[ #$%\\->]*" ) ;; not work for prompt '$ '

  ;;; (add-to-list 'tramp-default-user-alist
  ;;; (setq 'tramp-default-user

  (add-to-list 'tramp-default-method-alist '("" "root" "ssh"))
                                        ;$default$;  (nil "%" "smb")
                                        ;$default$;  ("" "\\`\\(anonymous\\|ftp\\)\\'" "ftp")
                                        ;$default$;  ("\\`ftp\\." "" "ftp")
                                        ;$default$;  ("\\`localhost\\'" "\\`root\\'" "su"))
;;$;; todo ;;
;;$;; todo ;;   (tramp-remote-path
;;$;; todo ;;   (tramp-remote-process-environment

  ;;;; ref. http://www.emacswiki.org/emacs/TrampMode
  (if (null system-name)
    (add-to-list 'tramp-default-proxies-alist
                 '((regexp-quote (system-name))   nil  nil) ))

  (add-to-list 'tramp-default-proxies-alist
               '( "localhost"   nil  nil) )

;;template00;;  (add-to-list 'tramp-default-proxies-alist
;;template00;;               '( "\\.fuga\\.hoge\\.com"   "\\(spam.*\\|ham.*\\|egg.*\\)"  "/ssh:%h:") )  ;;; usage /su:spr120@fu.com:/path/to/target

;;  tramp-maybe-open-connection
;;  tramp-compute-multi-hops

  ;;------------------------------------------------------------------------------------------
;;;; Useful info to customize
;;;; C-h v tramp-methods
  ;;------------------------------------------------------------------------------------------

  (defvar my_tramp-verbose-previous 0 "tramp-verbose value previously set. ")
  (defvar my_tramp-trace-advice-defined 0 "")

  ;;(defun my_tramp-set-tramp-debug-level (&options level)
  (defun my_tramp-set-tramp-debug-level (level)
    "Change tramp trace level."
    (interactive "P")
    (if (or (integerp level) (<= 0 level) (>= 10 level) )
        (progn
          (setq my_tramp-verbose-previous tramp-verbose)
          (setq tramp-verbose level)
          (message "set tramp-verbose with %d" level)
          ;; (message "given:%d, new:%d, old:%d\n" level tramp-verbose my_tramp-verbose-previous)
          )
      (message "'tramp-verbose must be 0 <= tramp-verbose <= 10" )
      ))

  (defun my_tramp-trace-enable ()
    (interactive)
    (require 'trace)
    (if (= my_tramp-trace-advice-defined 0 )
    (;;;;  generates advice to trace function
     dolist (target-func
             (concatenate 'list
                          (all-completions "tramp-" obarray 'functionp)
                          (all-completions "ad-Orig-tramp-" obarray 'functionp)
                          ))
      (trace-function-background (intern target-func))) ;; buffer "*trace-output*"
    ;;;; just activate advice
    (ad-activate-regexp "tramp-")
    )
    ;;;; (trace-make-advice
    )

  (defun my_tramp-trace-disable ()
    (interactive)
    (unless (= my_tramp-trace-advice-defined 0 )
        (ad-disable-regexp "tramp-")
      ))

  (defun toggle-tramp-debug ()
    "Toggle tramp-debug
   http://www.gnu.org/software/emacs/manual/html_node/tramp/Traces-and-Profiles.html
   "
    ;;; edebug-defun tramp-compute-multi-hops
    (interactive )
    (if (= tramp-verbose 0)
        (progn
          (message "turned on tramp-debug")
          (if (/= my_tramp-verbose-previous 0)
              (my_tramp-set-tramp-debug-level my_tramp-verbose-previous)
            (my_tramp-set-tramp-debug-level 3)
            )
          ;;(setq-default tramp-verbose my_tramp-verbose-previous)
          ;;          (setq tramp-verbose my_tramp-verbose-previous)
          (my_tramp-trace-enable)
          ;; (untrace-function 'tramp-read-passwd)
          ;;(untrace-function 'tramp-gw-basic-authentication)
          )
      (progn
        ;;        (setq my_tramp-verbose-previous tramp-verbose)
        (message "turned off tramp-debug")
        (my_tramp-set-tramp-debug-level 0)
        ;;
        (my_tramp-trace-disable)
        )
      ))

  (defadvice tramp-make-tramp-file-name (after my_tramp-ignore-local-misunderstanding-file )
  ;;; tramp-sh.el link.4539: Found remote shell prompt on
  ;;; We should check if hosts exists or not
    )
  ;;(defadvice tramp-dissect-file-name (after tramp-dissect-file-name-with-ping activate)
  ;;$$$; bug
  ;;$;;  (defadvice tramp-dissect-file-name (around tramp-dissect-file-name-with-ping activate)
  ;;$;;    ad-do-it
  ;;$;;    (let ( (tramp-host  (elt ad-return-value 2) ) )
  ;;$;;      (if (and tramp-host (= 0 (call-process "ping" nil nil nil "-c 1" tramp-host ) ))  ;; check if host is available
  ;;$;;          (progn
  ;;$;;            ;; (print (format "my_tramp.el:%s "  ad-return-value) (get-buffer "*Messages*" ) )
  ;;$;;            (print (format "my_tramp.el:%s "  ad-return-value) (get-buffer "*trace-log*" ) )
  ;;$;;            ad-return-value
  ;;$;;            )
  ;;$;;        (progn
  ;;$;;          (print (format "my_tramp.el:%s is unreachable. %s"  tramp-host ad-return-value)
  ;;$;;                 (get-buffer "*Messages*" ) )
  ;;$;;          (setq ad-return-value (vector (elt ad-return-value 0) (elt ad-return-value 1) nil (concat (elt ad-return-value 2) : (elt ad-return-value 3) )(elt ad-return-value 4) ))
  ;;$;;          )))
  ;;$;;    )
  ;;$$$; bug

;;;; http://www.gnu.org/software/emacs/manual/html_node/tramp/Frequently-Asked-Questions.html
;;; Disable version control no remote host
  (setq vc-ignore-dir-regexp
        (format "\\(%s\\)\\|\\(%s\\)"
                vc-ignore-dir-regexp
                tramp-file-name-regexp))
  )
;;;; autounload advice if unload-feature is called.
(defun my_tramp-unload-function ()
  (interactive)
  ;; (ad-remove-advice 'tramp-dissect-file-name 'around 'tramp-dissect-file-name-with-ping)
  ;; (ad-deactivate 'tramp-dissect-file-name)
  ;; (my_tramp-trace-disable)
     (dolist (target-func
              (concatenate 'list
                           (all-completions "tramp-" obarray 'functionp)
                           (all-completions "ad-Orig-tramp-" obarray 'functionp)
                           ))
     (ad-unadvise `,(intern target-func))  ;;work. Remove advice definition completely
     )
  )


(provide 'my_tramp)
