;; (defmacro user-full-name ()
;;  "masquerade user-full-name for auto-insert mode"
;;   (setq-default user-full-name "test")
;;   (prin1-to-string "test")
;; )
(require 'my_linum)
;; Line feed
(setq
 eol-mnemonic-dos "(CRLF)"
 eol-mnemonic-mac "(CR)"
 eol-mnemonic-unix "(LF)"
 line-number-mode nil
 column-number-mode t
 )

;;;; minor-mode-alist
;; (custom-set-faces
;;  '(mode-line ((t (:background "blue" :foreground "green" :box (:line-width -1 :style released-button)))))
;;  )

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
(defun my_mode-line-toggle-mode-line-format ()
  (interactive)
  (if (equal mode-line-format mode-line-format-original)
      (setq mode-line-format mode-line-format-custom)
      (setq mode-line-format mode-line-format-original)
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

(setq-default mode-line-format mode-line-format-custom)
;;; ref. default-mode-line-format

(defun my-mode-line-count-lines ()
  (setq my-mode-line-buffer-line-count (int-to-string (count-lines (point-min) (point-max)))))

(add-hook 'find-file-hook 'my-mode-line-count-lines)
(add-hook 'after-save-hook 'my-mode-line-count-lines)
(add-hook 'after-revert-hook 'my-mode-line-count-lines)
(add-hook 'dired-after-readin-hook 'my-mode-line-count-lines)

;;;; http://emacs-fu.blogspot.jp/2011/08/customizing-mode-line.html?showComment=1314399530368#c6534582178318427000
;; (setq mode-line-format
;;   (list
;;     ;; the buffer name; the file name as a tool tip
;;     '(:eval (propertize "%b " 'face 'font-lock-keyword-face
;;         'help-echo (buffer-file-name)))
;;
;;     ;; line and column
;;     "(" ;; '%02' to set to 2 chars at least; prevents flickering
;;       (propertize "%02l" 'face 'font-lock-type-face) ","
;;       (propertize "%02c" 'face 'font-lock-type-face)
;;     ") "
;;
;;     ;; relative position, size of file
;;     "["
;;     (propertize "%p" 'face 'font-lock-constant-face) ;; % above top
;;     "/"
;;     (propertize "%I" 'face 'font-lock-constant-face) ;; size
;;     "] "
;;
;;     ;; the current major mode for the buffer.
;;     "["
;;
;;     '(:eval (propertize "%m" 'face 'font-lock-string-face
;;               'help-echo buffer-file-coding-system))
;;     "] "
;;
;;
;;     "[" ;; insert vs overwrite mode, input-method in a tooltip
;;     '(:eval (propertize (if overwrite-mode "Ovr" "Ins")
;;               'face 'font-lock-preprocessor-face
;;               'help-echo (concat "Buffer is in "
;;                            (if overwrite-mode "overwrite" "insert") " mode")))
;;
;;     ;; was this buffer modified since the last save?
;;     '(:eval (when (buffer-modified-p)
;;               (concat ","  (propertize "Mod"
;;                              'face 'font-lock-warning-face
;;                              'help-echo "Buffer has been modified"))))
;;
;;     ;; is this buffer read-only?
;;     '(:eval (when buffer-read-only
;;               (concat ","  (propertize "RO"
;;                              'face 'font-lock-type-face
;;                              'help-echo "Buffer is read-only"))))
;;     "] "
;;
;;     ;; add the time, with the date and the emacs uptime in the tooltip
;;     '(:eval (propertize (format-time-string "%H:%M")
;;               'help-echo
;;               (concat (format-time-string "%c; ")
;;                       (emacs-uptime "Uptime:%hh"))))
;;     " --"
;;     ;; i don't want to see minor-modes; but if you want, uncomment this:
;;     ;; minor-mode-alist  ;; list of minor modes
;;     "%-" ;; fill with '-'
;;     ))



;;;; http://amitp.blogspot.jp/2011/08/emacs-custom-mode-line.html
;; Mode line setup
;; (setq-default
;;  mode-line-format
;;  '(; Position, including warning for 80 columns
;;    (:propertize "%4l:" face mode-line-position-face)
;;    (:eval (propertize "%3c" 'face
;;                       (if (>= (current-column) 80)
;;                           'mode-line-80col-face
;;                         'mode-line-position-face)))
;;    ; emacsclient [default -- keep?]
;;    mode-line-client
;;    "  "
;;    ; read-only or modified status
;;    (:eval
;;     (cond (buffer-read-only
;;            (propertize " RO " 'face 'mode-line-read-only-face))
;;           ((buffer-modified-p)
;;            (propertize " ** " 'face 'mode-line-modified-face))
;;           (t "      ")))
;;    "    "
;;    ; directory and buffer/file name
;;    (:propertize (:eval (shorten-directory default-directory 30))
;;                 face mode-line-folder-face)
;;    (:propertize "%b"
;;                 face mode-line-filename-face)
;;    ; narrow [default -- keep?]
;;    " %n "
;;    ; mode indicators: vc, recursive edit, major mode, minor modes, process, global
;;    (vc-mode vc-mode)
;;    "  %["
;;    (:propertize mode-name
;;                 face mode-line-mode-face)
;;    "%] "
;;    (:eval (propertize (format-mode-line minor-mode-alist)
;;                       'face 'mode-line-minor-mode-face))
;;    (:propertize mode-line-process
;;                 face mode-line-process-face)
;;    (global-mode-string global-mode-string)
;;    "    "
;;    ; nyan-mode uses nyan cat as an alternative to %p
;;    (:eval (when nyan-mode (list (nyan-create))))
;;    ))
;;
;; ;; Helper function
;; (defun shorten-directory (dir max-length)
;;   "Show up to `max-length' characters of a directory name `dir'."
;;   (let ((path (reverse (split-string (abbreviate-file-name dir) "/")))
;;         (output ""))
;;     (when (and path (equal "" (car path)))
;;       (setq path (cdr path)))
;;     (while (and path (< (length output) (- max-length 4)))
;;       (setq output (concat (car path) "/" output))
;;       (setq path (cdr path)))
;;     (when path
;;       (setq output (concat ".../" output)))
;;     output))
;;
;; ;; Extra mode line faces
;; (make-face 'mode-line-read-only-face)
;; (make-face 'mode-line-modified-face)
;; (make-face 'mode-line-folder-face)
;; (make-face 'mode-line-filename-face)
;; (make-face 'mode-line-position-face)
;; (make-face 'mode-line-mode-face)
;; (make-face 'mode-line-minor-mode-face)
;; (make-face 'mode-line-process-face)
;; (make-face 'mode-line-80col-face)
;;
;; (set-face-attribute 'mode-line nil
;;     :foreground "gray60" :background "gray20"
;;     :inverse-video nil
;;     :box '(:line-width 6 :color "gray20" :style nil))
;; (set-face-attribute 'mode-line-inactive nil
;;     :foreground "gray80" :background "gray40"
;;     :inverse-video nil
;;     :box '(:line-width 6 :color "gray40" :style nil))
;;
;; (set-face-attribute 'mode-line-read-only-face nil
;;     :inherit 'mode-line-face
;;     :foreground "#4271ae"
;;     :box '(:line-width 2 :color "#4271ae"))
;; (set-face-attribute 'mode-line-modified-face nil
;;     :inherit 'mode-line-face
;;     :foreground "#c82829"
;;     :background "#ffffff"
;;     :box '(:line-width 2 :color "#c82829"))
;; (set-face-attribute 'mode-line-folder-face nil
;;     :inherit 'mode-line-face
;;     :foreground "gray60")
;; (set-face-attribute 'mode-line-filename-face nil
;;     :inherit 'mode-line-face
;;     :foreground "#eab700"
;;     :weight 'bold)
;; (set-face-attribute 'mode-line-position-face nil
;;     :inherit 'mode-line-face
;;     :family "Menlo" :height 100)
;; (set-face-attribute 'mode-line-mode-face nil
;;     :inherit 'mode-line-face
;;     :foreground "gray80")
;; (set-face-attribute 'mode-line-minor-mode-face nil
;;     :inherit 'mode-line-mode-face
;;     :foreground "gray40"
;;     :height 110)
;; (set-face-attribute 'mode-line-process-face nil
;;     :inherit 'mode-line-face
;;     :foreground "#718c00")
;; (set-face-attribute 'mode-line-80col-face nil
;;     :inherit 'mode-line-position-face
;;     :foreground "black" :background "#eab700")

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
        ;;       ( (eq window-system nil)
        ;;         (setq color (cond ((minibufferp) default-color)
        ;;                           ((evil-insert-state-p) '("#e80000" . "#000000"))
        ;;                           ((evil-emacs-state-p)  '("#444488" . "#000000"))
        ;;                           ((buffer-modified-p)   '("#006fa0" . "#000000"))
        ;;                           (t default-color)))
        ;;         )
        ;;       ( (eq window-system 'x)
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
