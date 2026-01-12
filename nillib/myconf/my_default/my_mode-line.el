(require 'my_linum)
(require 'my_spaceline)
(require 'map)
(require 'dash)
(require 'which-func)

;; Line feed
(setq
 eol-mnemonic-dos "(CRLF)"
 eol-mnemonic-mac "(CR)"
 eol-mnemonic-unix "(LF)"
 line-number-mode nil
 column-number-mode t
 )

(defvar mode-line-format-original mode-line-format)
(defvar mode-line-format-custom nil "my_mode-line custom format")
(defvar my_mode-line--idx-format-map nil)
(defvar my_mode-line--to-be-cycled
  '(my_spaceline-all-the-icons-theme
    mode-line-format-custom
    mode-line-format-original))
(map-let nil my_mode-line--idx-format-map
  (-each-indexed my_mode-line--to-be-cycled
    (lambda (idx item) (map-put my_mode-line--idx-format-map idx item) )))
(define-symbol-prop 'mode-line-format 'my_mode-line-current-format 0)

(defun my_mode-line-toggle-mode-line-format ()
  (interactive)
  (let* ((plist (symbol-plist 'mode-line-format))
         (current-format-idx (plist-get plist  'my_mode-line-current-format))
         (next-format-idx (% (1+ current-format-idx) (map-length my_mode-line--idx-format-map)))
         (next-format (map-elt my_mode-line--idx-format-map next-format-idx)))
    (message "Use %s" next-format)
    (setq mode-line-format next-format)
    (plist-put plist 'my_mode-line-current-format next-format-idx)
    ))

(setq-default mode-line-buffer-identification ; Use format saving space.
              (propertized-buffer-identification "|%b|"))

(if window-system ;; Utilize frame to show mode info
    (setq-default mode-line-format-custom
                  '(" "
                    ;;                " %p"  ; percentage
                    ;; (list 'line-number-mode " ")
                    ;;(:eval (when line-number-mode
                    (:eval (let (str )
                             (when my-mode-line-buffer-line-count
                               (setq str (concat "L" my-mode-line-buffer-line-count)))
                             str))
                    (list 'column-number-mode " C%2C")
                    mode-line-modified
                    mode-line-mule-info
                    (list 'evil-mode evil-mode-line-tag)
                    ;;////////////////////////////////////////
                    ;; CUSTOM PART
                    ;;////////////////////////////////////////
                    ;;evil-mode-line-tag
                    "#" (:eval (format "%d" (length (get-buffer-window-list nil nil t)))) ;; num of buffers visiting the file.
                    mode-line-buffer-identification ; ggtags appends 'ggtags-mode-line-project-name
                    (vc-mode vc-mode)
                    mode-line-process
                    ))
  (setq-default mode-line-format-custom
                '(" "
                  ;;                " %p"  ; percentage
                  ;; (list 'line-number-mode " ")
                  ;;(:eval (when line-number-mode
                  (:eval (when (featurep 'linum)
                           (let (str )
                             (when my-mode-line-buffer-line-count
                               (setq str (concat "L" my-mode-line-buffer-line-count)))
                             str)))
                  (list 'column-number-mode " C%2C")
                  mode-line-modified
                  mode-line-mule-info
                  (list 'evil-mode evil-mode-line-tag)
                  "|" mode-line-buffer-identification
                  ":" (:eval (format "%s" (gethash (selected-window) which-func-table which-func-unknown)))
                  "|" (vc-mode vc-mode)
                  mode-line-modes
                  ))
  )

;;;; ref.  http://www.emacswiki.org/emacs/ViewMode
;; Change mode line color when view-mode
;; from *info* Defining Faces
(defun change-mode-line-color ()
  (interactive)
  (when (get-buffer-window (current-buffer))
    (cond (window-system
           (cond (view-mode
                  (set-face-background 'mode-line "black")
                  (set-face-foreground 'mode-line "orange"))
                 (t
                  (set-face-background 'mode-line "black")
                  (set-face-foreground 'mode-line "white"))))
          (t
           (set-face-background 'mode-line
                                (if view-mode "red"
                                  "white"))))))

(defmacro change-mode-line-color-advice (f)
  "my_mode-line:"
  `(defadvice ,f (after change-mode-line-color activate)
     (change-mode-line-color)
     (force-mode-line-update))) ; subr.el

(defun my_evil-change-modeline-color ()
  "Change mode-line color according to evil state.

This function is effective when `evil-mode'.
face 'mode-line is defined at faces.el"
  (when (featurep 'evil)
    (let (color default-color)
      (setq default-color '((face-background 'mode-line) . (face-foreground 'mode-line)))
      (setq color
            (cond
             ((null (buffer-file-name)) default-color)  ;; color for temporary buffer
             ((and (buffer-modified-p) (evil-insert-state-p) ) '("black" . "red"))
             ((and (buffer-modified-p) (evil-emacs-state-p ) ) '("blue" . "gray"))
             ((and (buffer-modified-p) (evil-normal-state-p) ) '("black" . "green"))
             ((evil-insert-state-p) '("red" . "#000000") )
             ((evil-emacs-state-p ) '("blue"   . "#FFFFFF") )
             ((evil-normal-state-p) '("green"  . "#000000") )
             ((minibufferp) default-color)
             (t default-color)))
      (set-face-background 'mode-line (car color))
      (set-face-foreground 'mode-line (cdr color))
      (message "my_evil-change-modeline-color %S" color ) ; debug
      );let
    ))

(when nil ; Disable legacy configurations.
  (progn
    (change-mode-line-color-advice set-window-configuration)
    (change-mode-line-color-advice switch-to-buffer)
    (change-mode-line-color-advice pop-to-buffer)
    (change-mode-line-color-advice other-window)
    (change-mode-line-color-advice read-only-mode)
    (change-mode-line-color-advice read-only-mode)
    (change-mode-line-color-advice vc-next-action)
    (change-mode-line-color-advice view-mode-enable)
    (change-mode-line-color-advice view-mode-disable)
    (change-mode-line-color-advice bury-buffer)
    (change-mode-line-color-advice kill-buffer)
    (change-mode-line-color-advice delete-window)

    (add-hook 'post-command-hook 'my_evil-change-modeline-color)
    (add-hook 'pre-command-hook 'my_evil-change-modeline-color)
    ))

(provide 'my_mode-line)
;;; my_mode-line ends here
