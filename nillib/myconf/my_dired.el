;;;; http://d.hatena.ne.jp/mooz/20091207/p1
(setq dired-listing-switches "-alh"); setting for `ls`
;;;
(defvar dired-various-sort-type
  '(
    ("S" . "size")
    ("X" . "extension")
    ("v" . "version")
    ("t" . "date")
    (""  . "name"))
;;    ("X" . "extension")
;;    (""  . "name")
;;    ("S" . "size")
;;    ("t" . "date")
;;    ("v" . "version")
)

(defun dired-various-sort-change (sort-type-alist &optional prior-pair)
  (when (eq major-mode 'dired-mode)
    (let* (case-fold-search
           get-next
           (options
            (mapconcat 'car sort-type-alist ""))
           (opt-desc-pair
            (or prior-pair
                (catch 'found
                  (dolist (pair sort-type-alist)
                    (when get-next
                      (throw 'found pair))
                    (setq get-next (string-match (car pair) dired-actual-switches)))
                  (car sort-type-alist)))))
      (setq dired-actual-switches
            (concat "-l" (dired-replace-in-string (concat "[l" options "-]")
                                                  ""
                                                  dired-actual-switches)
                    (car opt-desc-pair)))
      (setq mode-name
            (concat "Dired by " (cdr opt-desc-pair)))
      (force-mode-line-update)
      (revert-buffer))))

(defun dired-various-sort-change-or-edit (&optional arg)
  "Hehe"
  (interactive "P")
  (when dired-sort-inhibit
    (error "Cannot sort this dired buffer"))
  (if arg
      (dired-sort-other
       (read-string "ls switches (must contain -l): " dired-actual-switches))
    (dired-various-sort-change dired-various-sort-type)))

(defvar anything-c-source-dired-various-sort
  '((name . "Dired various sort type")
    (candidates . (lambda ()
                    (mapcar (lambda (x)
                              (cons (concat (cdr x) " (" (car x) ")") x))
                            dired-various-sort-type)))
    (action . (("Set sort type" . (lambda (candidate)
                                    (dired-various-sort-change dired-various-sort-type candidate)))))
    ))

(defun my_dired-filter-by-name ()
  "Alternative way of dired-at-point. e.g.  C-x d <regex> defined at ffap.el
ref. line.3365 in speedbar.el speedbar-dired, speedbar-key-map, speedbar-file-key-map
@dev
@see `find-lisp-find-dired'
`find-name-dired'
"
  )
(defun my_dired-mode-map()
  (define-key dired-mode-map "c"
    '(lambda ()
       (interactive)
       (anything '(anything-c-source-dired-various-sort))))
  (define-key dired-mode-map "f" 'my_dired-filter-by-name)
  (define-key dired-mode-map "s" 'dired-various-sort-change-or-edit)
  )
;; (add-hook 'dired-mode-hook 'my_dired-mode-map) ;; useless if already dired-mode is on
(my_dired-mode-map)
;; http://www.dgp.toronto.edu/~ghali/emacs.html
(require 'dired-x) ;; Assign C-x C-j to dired-jump

;;;; ==================================================================
;;(load "sorter")

;;;; append 'ls -h' option when in  dired + sorter mode.
;; cited from http://d.hatena.ne.jp/higepon/20061230/1167447340

(defadvice dired-sort-other
  (around dired-sort-other-h activate)
  (ad-set-arg 0 (concat (ad-get-arg 0) "h"))
  ad-do-it
  (setq dired-actual-switches (dired-replace-in-string "h" "" dired-actual-switches)))


;;;; make the files editted today noticeable.
;; cited from http://d.hatena.ne.jp/higepon/20061230/1167447340

(defface my_dired-face-today-mod '((t (:foreground "yellow"))) nil)
;;Warning: defface for `my_dired-face-today-mod' fails to specify containing group
(defvar my_dired-face-today-mod 'my_dired-face-today-mod)
(defun my-dired-today-search (arg)
  "Fontlock search function for dired."
  (search-forward-regexp
   (concat (format-time-string "%Y-%m-%d" (current-time)) " [0-9]....") arg t))

(add-hook 'dired-mode-hook
          '(lambda ()
             (font-lock-add-keywords
              major-mode
              (list
               '(my-dired-today-search . my_dired-face-today-mod)
               ))))

;;----------------------------------------------------------------------------------------------
;;;; TODO
;; http://homepage1.nifty.com/blankspace/emacs/dired.html

;; http://www.emacswiki.org/emacs/DiredReuseDirectoryBuffer
(put 'dired-find-alternate-file 'disabled nil) ;; always open 1 dired (activate keyboard command 'a')
;; Another way of achieving this:

;; we want dired not not make always a new buffer if visiting a directory
;; but using only one dired buffer for all directories.
(defadvice dired-advertised-find-file (around dired-subst-directory activate)
  "Replace current buffer if file is a directory."
  (interactive)
  (let ((orig (current-buffer))
        (filename (dired-get-filename)))
    ad-do-it
    (when (and (file-directory-p filename)
               (not (eq (current-buffer) orig)))
      (kill-buffer orig))))

;;    Using the advising methods above will still create a new buffer if you invoke ^
;;   (dired-up-directory). To prevent this:

(eval-after-load "dired"
  ;; don't remove `other-window', the caller expects it to be there
  '(defun dired-up-directory (&optional other-window)
     "Run Dired on parent directory of current directory."
     (interactive "P")
     (let* ((dir (dired-current-directory))
            (orig (current-buffer))
            (up (file-name-directory (directory-file-name dir))))
       (or (dired-goto-file (directory-file-name dir))
           ;; Only try dired-goto-subdir if buffer has more than one dir.
           (and (cdr dired-subdir-alist)
                (dired-goto-subdir up))
           (progn
             (kill-buffer orig)
             (dired up)
             (dired-goto-file dir))))))

(provide 'my_dired)
