(defvar env-exclude-alist '("TERM")
  "alist of environmental variable which shouldn't be overwrited.")

(defun import-shell-env ()
  "`setenv' according to shell environmental variables of bash.

Environmental variable in `env-exclude-alist' is not set.
"
  (interactive)
  (dolist (line (split-string
               ;;;; Don't use --login to avoid stdout handling of login process.
                 (with-output-to-string
                   (with-current-buffer standard-output
                     (call-process "/bin/bash" nil t nil  "-c" ". ~/.bash_profile 2>/dev/null 1>&2; env")))
                 "\n" t))
    (let* ((pair (split-string line "=")) (env-var (car pair)))
      (unless (member env-var env-exclude-alist)
        ;;(message "%S|%S" env-var (cadr pair))
        (setenv env-var (cadr pair))
        ))))



(defvar default-shell "/bin/bash" "Environment variable is extracted from the confinguration file of this shell by method `import-from-shell'.")
(defun import-from-shell (shell-var &optional emacs-sym)
  "Overwrite the variable of emacs `EMACS-SYM' with shell environment variable `SHELL-VAR'"
  (interactive)
  (let* (
         (buf " *setenv* ")
         ;; only for path on LINUX (cmd (concat ". ~/.bash.d/path.sh 2>/dev/null 1>&2 && echo $" shell-var) )
         (cmd
          (pcase system-type
            (`gnu/linux (concat ". ~/.bash.d/000_init 2>/dev/null 1>&2 && echo $" shell-var))
            (_ (concat "echo $" shell-var))
            ))
         var-from-shell
         )
    (with-current-buffer (get-buffer-create buf)
      ;; (start-process (concat "set " shell-var) buf default-shell "--login" "-c" cmd )
      ;; (delete-matching-lines "^Process ")
      (erase-buffer)
      (call-process default-shell nil t nil "--login" "-c" cmd "2>/dev/null")
      (goto-char (point-max))
      (forward-line -1)
      (narrow-to-region (point) (point-max))
      (setq var-from-shell (replace-regexp-in-string "[ \t\n]*$" "" (buffer-string)))
      )
    (setenv shell-var var-from-shell)
    (if emacs-sym
        (setf (symbol-value emacs-sym) (split-string var-from-shell path-separator))
      )
    var-from-shell))

(provide 'my_shell-env-vars)
;;; my_shell-env-vars.el ends here
