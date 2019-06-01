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
;;untested;; ;;;; http://maruta.be/intfloat_staff/53
;;untested;; (require 'filecache)
;;untested;; (file-cache-add-directory-list
;;untested;;   (list "~" "~/bin/" "~/lib/")) ;; ディレクトリを追加
;;untested;; (file-cache-add-file-list
;;untested;;  (list "~/memo/memo.txt")) ;; ファイルを追加
;;untested;; (define-key minibuffer-local-completion-map "\C-c\C-i"
;;untested;;   'file-cache-minibuffer-complete)

(setq initial-scratch-message nil) ; startup.el : Make "*scratch*" has no text.

(require 'my_global-vars)
;;; Increase the number of history
;;(setq history-length 10000)
;;; Save history of mini buffer
(setq savehist-file (concat my_global-vars--user-emacs-tmp-dir "/history"))
(savehist-mode 1)

(setq ;; set custom variables before loading recentf.el
 recentf-save-file (concat my_global-vars--user-emacs-tmp-dir "/recentf" )
 recentf-max-saved-items 4000 ; Increase number of recently opened files
 recentf-exclude '("/TAGS$" "~" "#.*#")
;;;; recentf + tramp makes reaction too slow.
 ;;$;; (setq recentf-exclude '("^/[^/:]+:"))
 ;;; recentf + tramp makes reaction too slow. See recentf-keep
 recentf-auto-cleanup 'never
 recentf-initialize-file-name-history t
 )
(require 'recentf)
(require 'recentf-ext nil t); call recentf-mode internally

;;$test$;; (setq redisplay-dont-pause t);; experiment redisplay performance. may have bug.
;; ======================================================================
;;;; I/O
;;; http://www.bookshelf.jp/soft/meadow_24.html#SEC254
;;; 起動時から global-auto-revert-mode を有効にする
;;(global-auto-revert-mode 1)
;; detect and refresh buffer change by the other program.
(global-auto-revert-mode t)
;;; 特定のモードでのみ有効にする
;;(add-hook 'c-mode-hook 'turn-on-auto-revert-mode)
;;; global-auto-revert でも特定のモードでは無効にする
                                        ;(add-hook 'text-mode-hook
;;(lambda ()
;; (setq global-auto-revert-ignore-buffer t)))
;;; global-auto-revert でも特定のモードでは無効にする
                                        ;(setq global-auto-revert-ignore-modes
;;      '(text-mode))
;;; auto-revert-mode のモードライン表示を変更
                                        ;(setq auto-revert-mode-text " ARev")
;;; global-auto-revert でのモードライン表示を変更
;;(setq global-auto-revert-mode-text "")

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
  ;;@TODO need to consider ecb-frame
  ;;  (if (featurep 'ecb)
  ;;      (ad-do-it)
  ;;(progn
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
;; TODO
;; ======================================================================

;; (defmacro user-full-name ()
;;  "masquerade user-full-name for auto-insert mode"
;;   (setq-default user-full-name "test")
;;   (prin1-to-string "test")
;; )

;; http://stackoverflow.com/questions/6154545/emacs-change-case-of-a-rectangle
;;maby-unused (setq cua-enable-cua-keys nil)  ; enable only CUA's rectangle selections
;;maby-unused (load-library "cua-rect")
;; (cua-selection-mode 1) ;; http://stackoverflow.com/questions/11130546/search-and-replace-inside-a-rectangle-in-emacs

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

(setq gc-cons-threshold (* 256 1024 1024))
(setq max-lisp-eval-depth 7000)
(setq max-specpdl-size 9600000)
(setq garbage-collection-messages nil)

;; last-command, this-command, pre-command-hook, post-command-hook
;; (setq gc-cons-percentage 0.1);;
;; gc-elapsed gc-cons-percentage gcs-done
;;;;-----------------------------------------------
;;;; debug for timer
;;; list of variables for timer
;; timer-list
;; timer-idle-list
;; last-event-frame
;; timer-event-last
;; timer-event-last-1
;; timer-event-last-2
;; last-command

;; cancel-timer
;; (timer-event-handler tempbuf-timer)

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
(import-shell-env)

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

(import-from-shell "PATH" 'exec-path)
;;ref. process-environment
;;debug;; (princ (getenv "LIBPATH"))
;;debug;; (princ (getenv "PATH"))

(defun padding (int)
  "Return 'int times of space.
 `spaces-string' of rect.el was sufficient...(; v ;)
 "
  (let ( (pad "") )
    (if int
        (loop for i from 1 to int
              do
              (setq pad (concat pad " " ))
              ))
    (if pad
        pad
      (princ ""))))
;;    pad))

(defun open-library (lib)
  "@deprecated Use `find-library' of `find-func'.
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

(provide 'my_basic_func)
;;; my_basic_func.el ends here
