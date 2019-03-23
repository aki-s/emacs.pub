;;;; ~/.emacs.d/src/emacs/lisp/vc/vc-hooks.el
;; (RCS CVS SVN SCCS Bzr Git Hg Mtn Arch GIT)

(require 'vc)

(defun vc-handled-backends-off ()
  (setq vc-handled-backends nil )
  (remove-hook 'find-file-hooks 'vc-find-file-hook)
  (message "vc-handled-backends off"))

(defun vc-handled-backends-on ()
;;  (setq vc-handled-backends '(CVS) )
  (add-hook 'find-file-hooks 'vc-find-file-hook)
  (message "vc-handled-backends on"))

(defun my_vc-set-backends (vc-backends)
  (interactive
   (list (read-from-minibuffer (format "vc-handles %S: "  vc-handled-backends ) "(CVS Git)"  nil "(CVS Git)"  nil ))
   )
  (setq vc-handled-backends `,vc-backends)
  (message "vc-handled-backends set to %s." vc-handled-backends)
  )

(defun toggle-vc-mode ()
  (interactive)
  (if vc-handled-backends
      (vc-handled-backends-off)
    (vc-handled-backends-on)
    ))

;; (vc-handled-backends-off)
;; (vc-handled-backends-on) ;; too slow if backend is Git or encrypted ?


;;$untested$;; ;;;; ref. http://www4.kcn.ne.jp/~boochang/emacs/pcl-cvs-vc.html
;;$untested$;; ;; log 入力の改行コード対応
;;$untested$;; (modify-coding-system-alist 'process "cvs" '(undecided . undecided-unix))
;;$untested$;;
;;$untested$;; ;;
;;$untested$;; ;; 以下は Meadow 用の設定です、Emacs 21 では必要ありません。
;;$untested$;; ;;
;;$untested$;;
;;$untested$;; ;; cvs.exe に引数を与えるときの設定
;;$untested$;; (define-process-argument-editing
;;$untested$;;   "/cvs\\.exe\\'"
;;$untested$;;   (lambda (x)
;;$untested$;;     (let ((command (car x))
;;$untested$;;           (argument (cdr x)))
;;$untested$;;       (setq argument (cygnus-process-argument-quoting argument))
;;$untested$;;       (concat
;;$untested$;;         (unix-to-dos-filename command) " "
;;$untested$;;         (unix-to-dos-argument (mapconcat (function concat) argument " ")
;;$untested$;;                               nil nil nil nil)))))
;;$untested$;;
;;$untested$;; ;;
;;$untested$;; ;; cvs が ediff を利用する際に buf1 の coding-system を buf2 に合わせる
;;$untested$;; ;; ShiftJIS コードのファイルのみを管理する場合は必要ありません。
;;$untested$;; ;;
;;$untested$;; (defadvice cvs-ediff-diff (before cvs-ediff-diff-change-coding activate)
;;$untested$;;   "convert coding system before cvs-ediff-diff"
;;$untested$;;   (save-excursion
;;$untested$;;     (let ((buf2 (ad-get-arg 1)))
;;$untested$;;       (set-buffer buf2)
;;$untested$;;       (let ((buf1 (ad-get-arg 0))
;;$untested$;;             (coding-system buffer-file-coding-system))
;;$untested$;;         (set-buffer buf1)
;;$untested$;;         (set-buffer-file-coding-system coding-system)))))
;;(setq vc-cvs-diff-switches "-abBu")
;;(setq vc-cvs-diff-switches '("-b" "--unchanged-line-format=" "--old-line-format=" "--new-line-format=:%dn: %L" ))

;;test (setq
;;test  vc-cvs-diff-switches
;;test    '(
;;test ;;    "-c" ;; show context lines
;;test  ;;err    "-C 3" ;; show context line 1
;;test  ;;err    "-U 3"
;;test      "-b"  ;; ignore difference of line feed
;;test      "--old-line-format='- %dn %L'"
;;test      "--new-line-format='+ %dn: %L'"
;;test      "--unchanged-group-format=''"
;;test      "--unchanged-line-format=''"
;;test      ;;"--old-group-format=%<
;;test      "--old-group-format='@@ -%df,1 +%dF,1 @@
;;test %<
;;test
;;test '"
;;test      ;; enable emacs func diff-goto-source to work
;;test      "--new-group-format='@@ -%df,10 +%dF,10 @@
;;test %>
;;test
;;test '"
;;test      ;;;; diff-hunk-header-re-unified for diff-outline: @@ \-[0-9]+,[0-9]+ \+[0-9]+,[0-9]+ @@
;;test ;;useless     "--label=@@ -%f, +%F, @@"
;;test ;;     "--label=---"
;;test      )
;;test  )
(setq
 vc-cvs-diff-switches
 '(
   "-u"
   )
 )
(setq
 vc-git-diff-switches
 '(
   "-w" ; ignore change of white space
   )
 )
;;;; ~/.emacs.d/src/emacs/lisp/vc/diff-mode.el
;;; stack trace

;; diff-sanity-check-context-hunk-half
;; diff-sanity-check-hunk
;; diff-find-source-location
;; diff-goto-source

;; diff-font-lock-keywords
;; diff-hunk-text
;; diff-find-file-name , diff-find-source-location
;; (BUF LINE-OFFSET POS SRC DST SWITCHED).

;; (defun diff-goto-source (&optional other-file event)
;;   "Overwritten by my_vc.el: Jump to the corresponding source line.
;; `diff-jump-to-old-file' (or its opposite if the OTHER-FILE prefix arg
;; is given) determines whether to jump to the old or the new file.
;; If the prefix arg is bigger than 8 (for example with \\[universal-argument] \\[universal-argument])
;; then `diff-jump-to-old-file' is also set, for the next invocations."
;;   (interactive (list current-prefix-arg last-input-event))
;;   ;; When pointing at a removal line, we probably want to jump to
;;   ;; the old location, and else to the new (i.e. as if reverting).
;;   ;; This is a convenient detail when using smerge-diff.
;;   (if event (posn-set-point (event-end event)))
;;   (let ((rev (not (save-excursion (beginning-of-line) (looking-at "[-<]")))))
;;     (pcase-let ((`(,buf ,line-offset ,pos ,src ,_dst ,switched)
;;                  (diff-find-source-location other-file rev)))
;;       (pop-to-buffer buf)
;;       (goto-char (+ (car pos) (cdr src)))
;;       (diff-hunk-status-msg line-offset (diff-xor rev switched) t))))
;;


(defun diff-sanity-check-hunk ()

  ;; A plain diff.
  (t
   ;; TODO.
   ))

(provide 'my_vc)
