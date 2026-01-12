;;;; ref. http://www.miura-takeshi.com/2010/0121-100438.html
;;;; http://www.emacswiki.org/emacs/SpeedBar
(require 'speedbar)
 (speedbar-add-supported-extension ".js") 
(add-to-list 'speedbar-fetch-etags-parse-list '("\\.js" . speedbar-parse-c-or-c++tag))

(defun html-imenu-create-index ()
  (let ((index))
    (goto-char (point-min))
    (while (re-search-forward "\\(id\\|class\\)=\"\\([^\"]+\\)\"" nil t)
      (push (cons (concat
                   (if (equal "id" (match-string 1)) "#" ".")
                   (match-string 2)) (match-beginning 1)) index))
    (nreverse index)))

(add-hook 'html-mode-hook
          '(lambda ()
             (setq imenu-create-index-function 'html-imenu-create-index)))
             
;;$default$;; (setq speedbar-mode-specific-contents-flag t)
;;$default$;; (setq speedbar-query-confirmation-method 'all)
;;$default$;; (setq speedbar-before-visiting-file-hook '(push-mark))
;;$default$;; (setq speedbar-visiting-file-hook nil)
;;$default$;; (setq speedbar-before-visiting-tag-hook '(push-mark))
;;$default$;; (setq speedbar-visiting-tag-hook '(speedbar-highlight-one-tag-line))
;;$default$;; (setq speedbar-load-hook nil)
;;$default$;; (setq speedbar-reconfigure-keymaps-hook nil)
;;$default$;; (setq speedbar-show-unknown-files nil)
;;$default$;; (setq speedbar-frame-parameters '((minibuffer . nil))
;;$default$;; (setq speedbar-frame-plist)
;;$default$;; (setq speedbar-use-imenu-flag (fboundp 'imenu))
;;$default$;; (setq speedbar-use-tool-tips-flag (fboundp 'tooltip-mode))
;;$default$;; (setq speedbar-track-mouse-flag (not speedbar-use-tool-tips-flag))
;;$default$;; (setq speedbar-default-position 'left-right)
;;$default$;; (setq speedbar-sort-tags nil)
;;$default$;; (setq speedbar-tag-hierarchy-method)
;;$default$;; (setq speedbar-tag-group-name-minimum-length 4)
;;$default$;; (setq speedbar-tag-split-minimum-length 20)
;;$default$;; (setq speedbar-tag-regroup-maximum-length 10)
;;$default$;; (setq speedbar-directory-button-trim-method 'span)
;;$default$;; (setq speedbar-smart-directory-expand-flag t)
;;$default$;; (setq speedbar-indentation-width 1)
;;$default$;; (setq speedbar-hide-button-brackets-flag nil)
;;$default$;; (setq speedbar-before-popup-hook nil)
;;$default$;; (setq speedbar-after-create-hook '(speedbar-frame-reposition-smartly))
;;$default$;; (setq speedbar-before-delete-hook nil)
;;$default$;; (setq speedbar-mode-hook nil)
;;$default$;; (setq speedbar-timer-hook nil)
;;$default$;; (setq speedbar-verbosity-level 1)
;;$default$;; (setq speedbar-vc-do-check t)
;;$default$;; (setq speedbar-vc-directory-enable-hook nil)
;;$default$;; (setq speedbar-vc-in-control-hook nil)
;;$default$;; (setq speedbar-obj-do-check t)
;;$default$;; (setq speedbar-scanner-reset-hook nil)
;;$default$;; (setq speedbar-ignored-modes '(fundamental-mode))
;;$default$;; (setq speedbar-ignored-directory-expressions)
;;$default$;; (setq speedbar-directory-unshown-regexp "^\\(\\..*\\)\\'")
(setq speedbar-directory-unshown-regexp "^\\(\\..*\\| *\\*\\)\\'")
;;$default$;; (setq speedbar-file-unshown-regexp)
;;$default$;; (setq speedbar-supported-extension-expressions)
;;$default$;; (setq speedbar-update-flag dframe-have-timer-flag)
;;$default$;; (setq speedbar-select-frame-method 'attached)
;;$default$;; (setq speedbar-fetch-etags-command "etags")
;;$default$;; (setq speedbar-fetch-etags-arguments '("-D" "-I" "-o" "-"))


(setq speedbar-mode-functions-list
  '(
    ("buffers" (speedbar-item-info . speedbar-buffers-item-info)
     (speedbar-line-directory . speedbar-buffers-line-directory))
    ("quick buffers" (speedbar-item-info . speedbar-buffers-item-info)
     (speedbar-line-directory . speedbar-buffers-line-directory))
    ("files" (speedbar-item-info . speedbar-files-item-info)
     (speedbar-line-directory . speedbar-files-line-directory))
    ))
   
(setq 
speedbar-frame-parameters (quote ((minibuffer) (width . 60) (border-width . 0) (menu-bar-lines . 0) (tool-bar-lines . 0) (unsplittable . t) (left-fringe . 0)))
speedbar-frame-plist (quote (minibuffer nil width 80 border-width 0 internal-border-width 0 unsplittable t default-toolbar-visible-p nil has-modeline-p nil menubar-visible-p nil default-gutter-visible-p nil))
)
 (defun speedbar-expand-all-lines ()
   "Expand all items in the speedbar buffer. But be careful: this opens all the files to parse them." 
   ;; TBD
 ;; regex and jump to buffer-file-name
   (interactive)
 (setq speedbar-directory-contents-alist  nil)
 (setq speedbar-directory-contents-alist 
;default-directory 
       (list default-directory
             (list
  ;;(file-name-base (directory-file-name default-directory))
  (file-relative-name (buffer-file-name)))))

 ;; (speedbar-file-lists default-directory)
 (save-window-excursion
   (select-window (sr-speedbar-get-window))
   (goto-char (point-min))
   (while (not (eobp))
     (forward-line) 
     (speedbar-expand-line)))
 )


(provide 'my_speedbar)
