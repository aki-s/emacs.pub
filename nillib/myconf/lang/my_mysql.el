;;http://www.emacswiki.org/cgi-bin/wiki?SqlMode
;; save  history between sessions

(defun my-sql-save-history-hook ()
  (let ((lval 'sql-input-ring-file-name)
	(rval 'sql-product))
    (if (symbol-value rval)
	(let ((filename 
	       (concat "~/.emacs.d/sql/"
		       (symbol-name (symbol-value rval))
		       "-history.sql")))
	  (set (make-local-variable lval) filename))
      (error
       (format "SQL history will not be saved because %s is nil"
	       (symbol-name rval))))))
(add-hook 'sql-interactive-mode-hook 'my-sql-save-history-hook)

;; don't work well 'sql-mysql-program'.
;(setq sql-mysql-program "/opt/local/bin/mysql5")
(setq sql-mysql-options (quote ("--socket=/opt/local/var/run/mysql5/mysqld.sock")))
					;(setq sql-mysql-options (quote ("--port" "3307")))

;;; 110103 I don't know how to set variable. The following is my trial.
;; (add-hook 'sql-mode-hook
;; 	  (lambda ()
;; 	    (setq sql-mysql-program (quote ("/opt/local/bin/mysql5")))
;; 	    (setq sql-mysql-options (quote ("--socket=/opt/local/var/run/mysql5/mysqld.sock")))))

(provide 'my_mysql)
;;; my_mysql.el ends here
