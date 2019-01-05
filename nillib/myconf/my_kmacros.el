;; kmacro.el
(defvar kmacro-save-file "~/.emacs.d/kmacro.el")
(defvar kmacro-save-file-tmp "/tmp/kmacro-tmp.el")

(defun kmacro-save(kmacro-save-file)
  (interactive)
  (kmacro-save-skel (kmacro-save-file))
  )

(defun kmacro-save-tmp (kmacro-save-file-tmp)
  (interactive)
  (kmacro-save-skel kmacro-save-file-tmp)
  )

(defun kmacro-save-skel (symbol file)
  (interactive "Sname for last kbd macro: ")
  (name-last-kbd-macro symbol)
  (with-current-buffer (find-file-noselect file)
    (goto-char (point-max))
    (insert-kbd-macro symbol)
    (basic-save-buffer)
    )
  )

