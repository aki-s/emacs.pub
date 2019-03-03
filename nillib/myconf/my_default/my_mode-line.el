(require 'my_linum)
;; Line feed
(setq
 eol-mnemonic-dos "(CRLF)"
 eol-mnemonic-mac "(CR)"
 eol-mnemonic-unix "(LF)"
 line-number-mode nil
 column-number-mode t
 )

(set-face-attribute
  'mode-line nil
  :background "blue"
  :foreground "green"
  :box '(:line-width -1 :style released-button)
)

;;;; ref. http://stackoverflow.com/questions/8190277/how-do-i-display-the-total-number-of-lines-in-the-emacs-modeline
(defvar my-mode-line-buffer-line-count nil)
(make-variable-buffer-local 'my-mode-line-buffer-line-count)
(defvar mode-line-format-original mode-line-format)
(defvar mode-line-format-custom nil "my_mode-line custom format")
(require 'map)
(require 'dash)
(defvar my_mode-line--idx-format-map nil)
(map-let nil my_mode-line--idx-format-map
  (-each-indexed
      '(spaceline-all-the-icons-theme mode-line-format-custom mode-line-format-original)
    (lambda (idx item) (map-put my_mode-line--idx-format-map idx item) )))

(require 'use-package)
(use-package spaceline)
(use-package spaceline-all-the-icons
  :after spaceline
  :init
  ;; Suppress error by declaring undefined variables.
  (defvar  mode-line t)
  (defface mode-line '((default)) "")
  (defvar powerline-active2 nil)
  (defface powerline-active2 '((default)) "")
  (defvar powerline-inactive2 nil)
  (defface powerline-inactive2 '((default)) "")
  :config
  (spaceline-all-the-icons-theme)
  (define-symbol-prop 'mode-line-format 'my_mode-line-current-format 0)
  )

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

(setq-default mode-line-buffer-identification   (propertized-buffer-identification "|%b|")) ; Use space saving format

(require 'which-func)

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

(defun my-mode-line-count-lines ()
  (setq my-mode-line-buffer-line-count (int-to-string (count-lines (point-min) (point-max)))))

(add-hook 'find-file-hook 'my-mode-line-count-lines)
(add-hook 'after-save-hook 'my-mode-line-count-lines)
(add-hook 'after-revert-hook 'my-mode-line-count-lines)
(add-hook 'dired-after-readin-hook 'my-mode-line-count-lines)

;;;; ref.  http://www.emacswiki.org/emacs/ViewMode
;; Change mode line color when view-mode
;; from *info* Defining Faces
(defun change-mode-line-color ()
  "@dev
@see my_evil.el
"
  (interactive)
  (when (get-buffer-window (current-buffer))
    (cond (window-system
           (cond (view-mode
                  (set-face-background 'mode-line "black")
                  (set-face-foreground 'mode-line "orange")
                  )
                 (t
                  (set-face-background 'mode-line "black")
                  (set-face-foreground 'mode-line "white")))
           )
          (t
           (set-face-background 'mode-line
                                (if view-mode "red"
                                  "white"))))))

(defmacro change-mode-line-color-advice (f)
  "my_mode-line:"
  `(defadvice ,f (after change-mode-line-color activate)
     (change-mode-line-color)
     (force-mode-line-update))) ; subr.el

(progn
  (change-mode-line-color-advice set-window-configuration)
  (change-mode-line-color-advice switch-to-buffer)
  (change-mode-line-color-advice pop-to-buffer)
  (change-mode-line-color-advice other-window)
  (change-mode-line-color-advice toggle-read-only)
  (change-mode-line-color-advice vc-toggle-read-only)
  (change-mode-line-color-advice vc-next-action)
  (change-mode-line-color-advice view-mode-enable)
  (change-mode-line-color-advice view-mode-disable)
  (change-mode-line-color-advice bury-buffer)
  (change-mode-line-color-advice kill-buffer)
  (change-mode-line-color-advice delete-window)
  ;; for windows.el
  (change-mode-line-color-advice win-switch-to-window)
  (change-mode-line-color-advice win-toggle-window)
  )


(defun my_evil-change-modeline-color ()
  "Change mode-line color according to evil state.

This function is effective when `evil-mode'.
face 'mode-line is defined at faces.el"
  (when (featurep 'evil)

    (let ( color
           (default-color (cons (face-background 'mode-line) (face-foreground 'mode-line)))
           )
      (cond
        ( t
          (setq color (cond
                        ((null (buffer-file-name)) default-color)  ;; color for temporary buffer
                        ((and (buffer-modified-p) (evil-insert-state-p) ) '("black" . "yellow"))
                        ((and (buffer-modified-p) (evil-emacs-state-p ) ) '("black" . "blue"))
                        ((and (buffer-modified-p) (evil-normal-state-p) ) '("black" . "green"))
                        ((evil-insert-state-p) '("yellow" . "#000000") ) ; yellow
                        ((evil-emacs-state-p ) '("blue"   . "#FFFFFF") ) ; blue
                        ((evil-normal-state-p) '("green"  . "#000000") )  ; green
                        ((minibufferp) default-color)
                        (t default-color)
                        ))
          )
        )
      (set-face-background 'mode-line (car color))
      (set-face-foreground 'mode-line (cdr color))
      ;; (message "my_evil-change-modeline-color %S" color ) ; debug
      );let
    )
  ); defun my_evil-change-modeline-color

(add-hook 'post-command-hook 'my_evil-change-modeline-color)
(add-hook 'pre-command-hook 'my_evil-change-modeline-color)


(provide 'my_mode-line)
;;; my_mode-line ends here
