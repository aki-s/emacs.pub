;;; package --- 
;;; Commentary:

;;;; @ref. Original version is https://github.com/daic-h/emacs-rotate/blob/master/rotate.el

;;; Code:
(eval-when-compile (require 'cl))

(global-set-key (kbd "C-x SPC") 'my_rotate-layout)
(global-set-key (kbd "C-c SPC") 'my_rotate-window) ; (kbd "C-c SPC")  conflict with windows.el:win-toggle-window
;; (global-set-key (kbd "M-SPC") 'my_rotate-window) ; Original binding just-one-space is not useful. Overwrite. ; Conflict with MacOSX's toggling of input method.
 
(defgroup my_rotate nil
  "tmux like window manager"
  :group 'windows)

(defcustom my_rotate:exclude-regex-alist
  '(
    ;; e.g.  " buffer-name-with-space-padded"
    "^ +"              
    ;; e.g.  " *auto-generated-buffer*"
    "^[ ]+\\*[^*]+\\*"  ; Although this case is included in the 1st expression.
    )
  " Setting this variable sometimes becomes useful when you execute (my_rotate-window).
buffer-name matching list of regular expression is excluded.
More than a element of regular expression is tedious, but this makes it easy to maintain the list.
"
  :group 'my_rotate
  )

(defvar my_rotate-count 0)

(defvar my_rotate-functions nil)
(setq my_rotate-functions
      '(my_rotate:even-horizontal
        my_rotate:even-vertical
        ;;my_rotate:main-horizontal
        ;;my_rotate:main-vertical
        my_rotate:tiled 
        ;;my_rotate:original ; @TBD
        ))

(defun my_rotate:exclude-p (win)
  "Return flags of list about which 'win is to be excluded.
 according to variable my_rotate:exclude-regex-alist.
Each flag have value 2^x, which is binary expression corresponding to my_rotate:exclude-regex-alist.
"
  (loop with flag = (make-vector (length win) 0)
        with idx_reg = 0
        for regex in my_rotate:exclude-regex-alist
        do 
        (loop with idx_win = 0
              for w in win 
              do
              (if (string-match regex (buffer-name (window-buffer w))) 
                  (setf (aref flag idx_win) (+ (aref flag idx_win) (expt 2 idx_reg)))
                )
              (incf idx_win)
              )
        (incf idx_reg)
        finally (return (append flag nil)))
  )

(defun my_rotate:no-dedicated-window-p (win)
  "Return flag [1:true, 0:false ] of list for which 'win is window-dedicated-p"
  (mapcar #'(lambda (x) (if x 1 0)) (mapcar 'window-dedicated-p win))
  )

(defun my_rotate:count-windows:no-dedicated ()
  (length (my_rotate:window-list:no-dedicated))
  )

;;notused$ (defun my_rotate:count-windows:exclude-regex ()
;;notused$   "Return the number of windows each of which is not dedicated window and not matching my_rotate:exclude-regex-alist"
;;notused$   (length (my_rotate:exclude-p))
;;notused$   )

(defun my_rotate:count-windows:no-dedicated ()
  "Return the number of not dedicated windows."
  (length (delq t (mapcar 'window-dedicated-p (window-list-1))))
  )

(defun my_rotate:one-window-p:no-dedicated ()
  "Extended version of one-window-p. Ignore dedicated-windows."
  (let ( (num_win (my_rotate:count-windows:no-dedicated) ))
    (if (= num_win 1)
        t
      nil))
  )

;;;###autoload
(defun my_rotate:window-list:no-dedicated ()
  "@dev 
Return list of windows.
Ignored files are
- window-dedicated-p
"
  (let* (
         (wl (window-list-1))
         (flg2 (my_rotate:no-dedicated-window-p wl))
         )
    (loop
          for i2 in flg2 
          for i3 in wl
          if (> 1 i2) collect i3
          );loop
    );let*
  )

;;;###autoload
(defun my_rotate:window-list:exclude-regex ()
  "@dev 
Return list of windows.
Ignored files are
- window-dedicated-p
- named my_rotate:exclude-regex-alist"
  (let* (
         (wl (window-list-1))
         (flg1 (my_rotate:exclude-p wl))
         (flg2 (my_rotate:no-dedicated-window-p wl))
         )
    (loop for i1 in flg1
          for i2 in flg2 
          for i3 in wl
          if (> 1 (+ i1 i2))
          collect i3
          );loop
    );let*
  )

;;;###autoload
(defun my_rotate-layout ()
  (interactive)
  (let* ((len (length my_rotate-functions))
         (func (elt my_rotate-functions (% my_rotate-count len))))
    (prog1 (message "%s" func)
      (call-interactively func)
      (if (>= my_rotate-count (- len 1))
          (setq my_rotate-count 0)
        (incf my_rotate-count)))))

;;;###autoload
(defun my_rotate-window ()
  (interactive)
  (let ((wl (reverse (my_rotate:window-list:exclude-regex))))
    (my_rotate:window wl (window-buffer (car wl)))))

;;;###autoload
(defun my_rotate:even-horizontal ()
  (interactive)
  (my_rotate:refresh #'my_rotate:horizontally-n))

;;;###autoload
(defun my_rotate:even-vertical ()
  (interactive)
  (my_rotate:refresh #'my_rotate:vertically-n))

;;;###autoload
(defun my_rotate:main-horizontal ()
  (interactive)
  (my_rotate:refresh #'my_rotate:main-horizontally-n))

;;;###autoload
(defun my_rotate:main-vertical ()
  (interactive)
  (my_rotate:refresh #'my_rotate:main-vertically-n))

;;;###autoload
(defun my_rotate:tiled ()
  (interactive)
  (my_rotate:refresh #'my_rotate:tiled-n))

;;;###autoload
(defun my_rotate:original ()
  (interactive)
  (my_rotate:refresh #'my_rotate:tiled-n))

(defun my_rotate:main-horizontally-n (num)
  (if (<= num 2)
      (split-window-horizontally
       (floor (* (window-width) (/ 2.0 3.0))))
    (split-window-vertically)
    (other-window 1)
    (my_rotate:horizontally-n (- num 1))))

(defun my_rotate:main-vertically-n (num)
  (if (<= num 2)
      (split-window-vertically
       (floor (* (window-height) (/ 2.0 3.0))))
    (split-window-horizontally)
    (other-window 1)
    (my_rotate:vertically-n (- num 1))))

(defun my_rotate:horizontally-n (num)
  (if (<= num 2)
      (split-window-horizontally)
    (split-window-horizontally
     (- (window-width) (/ (window-width) num)))
    (my_rotate:horizontally-n (- num 1))))

(defun my_rotate:vertically-n (num)
  (if (<= num 2)
      (split-window-vertically)
    (split-window-vertically
     (- (window-height) (/ (window-height) num)))
    (my_rotate:vertically-n (- num 1))))

(defun my_rotate:tiled-n (num)
  (cond
   ((<= num 2)
    (split-window-vertically))
   ((<= num 6)
    (my_rotate:tiled-2column num))
   (t
    (my_rotate:tiled-3column num))))

(defun my_rotate:tiled-2column (num)
  (my_rotate:vertically-n (/ (+ num 1) 2))
  (dotimes (i (/ num 2))
    (split-window-horizontally)
    (other-window 2)))

(defun my_rotate:tiled-3column (num)
  (my_rotate:vertically-n (/ (+ num 2) 3))
  (dotimes (i (/ (+ num 1) 3))
    (my_rotate:horizontally-n 3)
    (other-window 3))
  (when (= (% num 3) 2)
    (other-window -1)
    (delete-window)))

(defun my_rotate:refresh (proc)
  (let ((window-num (my_rotate:count-windows:no-dedicated))
        (buffer-list (mapcar (lambda (wl) (window-buffer wl))
                             (my_rotate:window-list:no-dedicated))))
    (when (not (my_rotate:one-window-p:no-dedicated))
      (delete-other-windows)
      (save-selected-window
        (funcall proc window-num))
      (loop for wl in (my_rotate:window-list:no-dedicated)
            for bl in buffer-list
            do (set-window-buffer wl bl)))))

(defun my_rotate:window (wl buf)
  (when (not (my_rotate:one-window-p:no-dedicated))
    (cond
     ((equal (cdr wl) nil)
      (set-window-buffer (car wl) buf)
      (select-window (car wl)))
     (t
      (set-window-buffer (car wl) (window-buffer (cadr wl)))
      (my_rotate:window (cdr wl) buf)))))

(provide 'my_rotate)
;;; my_rotate.el ends here
