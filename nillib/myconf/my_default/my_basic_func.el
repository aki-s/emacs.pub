;;; my_basic_func.el --- ""
;;; Commentary:
;;-------------------------------------------------------------------
;;           vvvvvvv
;; This file must be loaded befor any other my library is loaded.
;;           ^^^^^^^
;;-------------------------------------------------------------------

;;; Code:
;;-------------------------------------------------
;; auto-edit
;;-------------------------------------------------
;; Maintainer's Time-stamp: <2014-02-16 20:51:15 >

;;; (require 'time-stamp)
;;; (time-stamp-toggle-active)
;;; (add-hook 'before-save-hook 'update-time-stamp-txt)

;;-------------------------------------------------
;;-------------------------------------------------

(eval-and-compile (require 'cl))

;; magic word to prevent the error below
(defvar warning-suppress-types nil)
;;; symbol's value as variable is void : warning-suppress-types

(eval-when-compile (load-library "man")) ; Man-switches
(defun toggle-man-switches  ()
  (interactive)
  (if (string= Man-switches "")
      (setq Man-switches "-a")
    (setq Man-switches "")
    )
  (message "Man-switches %s" Man-switches)
  )

(setq transient-mark-mode nil)
;; Enable to jump between `mark-ring' repeatedly like C-u C-SPC C-SPC ...
(setq set-mark-command-repeat-pop t) ; Same for `evil-jump-backward'

;;; `toggle-truncate-lines' is defined in `simple.el'
(cond ((version< emacs-version "24.5.1")
       (defun my_toggle-truncate-lines ()
         "Toggle truncate line."
         (declare (obsolete toggle-truncate-lines "24.?.?"))
         (interactive)
         (if truncate-lines
             (setq truncate-lines nil)
           (setq truncate-lines t))
         (recenter))
       ;; C-c C-l runs the command c-toggle-electric-state, `cc-cmds.el'
       (global-set-key (kbd "\C-c t") 'my_toggle-truncate-lines) ;; overwritten by cc-mode?
       )
      (t
       (global-set-key (kbd "\C-c t") 'toggle-truncate-lines)
       ))

;;;;<< equal to 'kill-whole-line @ bindings.el.gz:line868
;; http://d.hatena.ne.jp/plasticster/20110201/1296581964
                                        ;(defun backward-kill-line (arg)
                                        ;  "Kill chars backward until encountering the end of a line."
                                        ;  (interactive "p")
                                        ;  (kill-line 0))
;;; http://www.dennougedougakkai-ndd.org/~delmonta/emacs/20.html
                                        ;(global-set-key (kbd "C-\177") 'backward-kill-line) ;\177 == [DEL]
;;(global-set-key (kbd "C-<DEL>") 'backward-kill-line)
;; Isn't \C-x <DEL> is enough?
;;;;>>

;; (global-set-key (kbd "C-c DEL") 'kill-whole-line)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; ファイルの先頭が #! で始まるファイルに実行権限を
;; をつける。
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun chmod+x ()
  (save-restriction
    (widen)
    (if (string= "#!" (buffer-substring 1 (min 3 (point-max))))
        (let ((name (buffer-file-name)))
          (or (char-equal ?. (string-to-char (file-name-nondirectory name)))
              (let ((mode (file-modes name)))
                (set-file-modes name (logior mode (logand (/ mode 4) 73)))
                (message (concat "Wrote " name " (+x)"))))
          ))))
(add-hook 'after-save-hook 'chmod+x)

;;-------------------------------------------------
;;;; additional function for etags
;;-------------------------------------------------
;; 再帰的にファイルを検索させて、etags を実行させる。
(defun etags-find (dir pattern)
  " find DIR -name 'PATTERN' |etags -"
  (interactive
   "DFind-name (directory): \nsFind-name (filename wildcard): ")
  (shell-command
   (concat "find " dir " -type f -name \"" pattern "\" | etags -")))

;;-------------------------------------------------
;;;; face
;;-------------------------------------------------
;;ソースを読むか, M-x list-faces-display か, M-x describe-face-at-pointで
;; ref http://dminor11th.blogspot.jp/2011/08/face.html
;; (get-char-property (point) 'face)
(defun describe-face-at-point ()
  "Return face used at point."
  (interactive)
  (message "%s" (get-char-property (point) 'face)))


(defun emacs-server-title-bar ()
  ;;  (if (server-running-p)
  ;;  (if (file-exists-p (format "/tmp/emacs%d/%s" (user-uid) server-name))
  (if (and (boundp 'server-soket-dir) (boundp 'server-name))
      (set-terminal-title server-name ":" default-directory )
    (set-terminal-title             ":" default-directory )))

(add-hook 'find-file-hook 'emacs-server-title-bar)

;; ref. http://d.hatena.ne.jp/sr10/20120323/1332498671
(defun set-terminal-title (&rest args)
  ""
  (interactive "sString to set as title: ")
  (let ((tty (frame-parameter nil
                              'tty-type)))
    (when (and tty
               (eq t (compare-strings "xterm" 0 5 tty 0 5)))
      (send-string-to-terminal (apply 'concat
                                      "\033]0;"
                                      `(,@args "\007"))))))

;; ======================================================================
;; coding rule
;; ======================================================================
(setq require-final-newline t)
;; ======================================================================
;; tips
;; ======================================================================
;; If we read a compressed file, uncompress it on the fly:
;; (this works with .tar.gz and .tgz file as well)
(auto-compression-mode 1)
;; Emacsからの質問を y/n で回答する
(fset 'yes-or-no-p 'y-or-n-p)
;; enable mouse in nil-terminal
;; (xterm-mouse-mode 1)
;; カーソル位置のファイルパスやアドレスを "C-x C-f" で開く
(ffap-bindings)
(load-library "find-file")

(setq initial-scratch-message nil) ; startup.el : Make "*scratch*" has no text.

(require 'my_global-vars)
;;; Increase the number of history
;;; Save history of mini buffer
(setq savehist-file (concat my_global-vars--user-emacs-tmp-dir "/history"))
(savehist-mode 1)

(use-package recentf
  :config
  (setq ;; set custom variables before loading recentf.el
   recentf-save-file (concat my_global-vars--user-emacs-tmp-dir "/recentf" )
   recentf-max-saved-items 4000 ; Increase number of recently opened files
   recentf-exclude
   '("/TAGS$"
     "~[0-9]+~$" ; backup files
     "#.*#" ; temp file for vim ?
     )
;;;; recentf + tramp makes reaction too slow.
   ;;$;; (setq recentf-exclude '("^/[^/:]+:"))
 ;;; recentf + tramp makes reaction too slow. See recentf-keep
   recentf-auto-cleanup 'never
   history-length 1000
   recentf-initialize-file-name-history t
   )
  )

;; ======================================================================
;;;; I/O
;;; http://www.bookshelf.jp/soft/meadow_24.html#SEC254
;;; 起動時から global-auto-revert-mode を有効にする
(global-auto-revert-mode t) ;; detect and refresh buffer change by the other program.

(require 'ediff)
;; コントロール用のバッファを同一フレーム内に表示
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
;; diffのバッファを上下ではなく左右に並べる
(setq ediff-split-window-function 'split-window-horizontally)

;; ======================================================================
;; Window
;; ======================================================================
;;(setq split-width-threshold 100)
(setq
 split-width-threshold  140
 split-height-threshold 80
 )

(defun my_basic_func:remember-window-layout (&optional window)
  "Remember current window layout to register `w'."
  (interactive)
  (window-configuration-to-register ?w)
  (message "Registered current window layout to register 'w")
  )
(global-set-key (kbd "\C-x 4 4") 'my_basic_func:remember-window-layout)

(defvar my_delete-other-windows-hooks '() "Hook run at the end.")
(defun my_delete-other-windows(&optional window)
  "Extended version of `delete-other-windows'.
Internally calls `delete-other-windows.'
"
  (interactive)
  (if (and
       (= (count-if nil (mapcar 'window-dedicated-p (window-list))) 1)
       (get-register ?1))
      (progn
        ;; set-window-configuration
        ;; window-state-put
        (jump-to-register ?1)
        )
    (progn
      ;; (current-window-configuration)
      ;; window-state-get
      ;; window-persistent-parameters
      (window-configuration-to-register ?1)
      (delete-other-windows window)
    ))
  (run-hooks my_delete-other-windows-hooks)
)
(global-set-key (kbd "\C-x 1") 'my_delete-other-windows)


;; ======================================================================
;; Emacs
;; ======================================================================


(defun reload-feature (feature)
  (interactive "SInput feature you wanto reload: ")
  (if (featurep feature)
      (unload-feature feature)
    )
  (load-library (format "%s" feature))
  )
;;;; <OCCUR>
;;;; http://stackoverflow.com/questions/20401012/highlight-a-name-throughout-an-emacs-buffer
(defun region-str-or-symbol ()
  "Return the contents of region or current symbol."
  (if (region-active-p)
      (buffer-substring-no-properties
       (region-beginning)
       (region-end))
    (thing-at-point 'symbol)))

(defun occur-dwim ()
  "Call `occur' with a sane default."
  (interactive)
  (push (region-str-or-symbol) regexp-history)
  (call-interactively 'occur))

(defun open-stingy-height-window (&optional buf)
  "TBD:"
  (interactive)
  (window-text-height)
  )
;;;; </OCCUR>;; highlight-symbol-occur in highlight-symbol.el is better

(defun show-buffer-process ()
  "@dev"
  (interactive)
  (let (buf (current-buffer))
    (message "%s:\n%s" buf (get-buffer-process buf))
    )
  )

(defun my_copy-visited-buffer-name()
  "Copy currently visited buffer name to OS clipboard."
  (interactive)
  (let ((f (buffer-file-name)))
    (kill-new f)
    (message "String \"%s\" was copied to OS clipboard." f)
    )
  )

;;-------------------------------------------------
;;;; not default lib
;;-------------------------------------------------

(require 'color-moccur)
(require 'grep-a-lot);; Each result of grep to separate buffer
(grep-a-lot-setup-keys)

(setq gc-cons-threshold 100000000)
(setq max-lisp-eval-depth 7000)
(setq max-specpdl-size 9600000)
(setq garbage-collection-messages nil)

(defun open-library (lib)
  "Duplicate declaretion of `find-library' of `find-func'.
but `find-library' was so slow compared to this func.
Try to locate and open elisp library."
  (interactive (list(read-from-minibuffer "library: " (thing-at-point 'symbol t))))
  (let ((suffix '(".el" ".el.gz"))
        (li (locate-library lib)))
    (if li
        (progn
          (let ((l (file-name-sans-extension li)))
            (find-file
             (concat l
                     (loop for i in suffix
                           if (file-exists-p (concat l i))
                           return i)))
            )
          )
      (message "Not found")
      )
    )
  )

(defun replace-square-braces-to-curry-ones(start end)
  "Replace [ to {, ] to } in region START END."
  (interactive "r")
  (save-restriction
    (narrow-to-region start end)
    (cl-mapc #'(lambda (from to)
                 (goto-char (point-min))
                 (while (search-forward from nil t) (replace-match to nil t)))
             '("[" "]") '("{" "}"))))

(provide 'my_basic_func)
;;; my_basic_func.el ends here
