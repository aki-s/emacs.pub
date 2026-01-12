;; ===== pukiwiki-mode =====

(defun my_pukiwiki ()
;  ""
; (interactive)

(setq pukiwiki-auto-insert t)
(autoload 'pukiwiki-edit "pukiwiki-mode" nil t)
(autoload 'pukiwiki-index "pukiwiki-mode" nil t)
(autoload 'pukiwiki-edit-url "pukiwiki-mode" nil t)
(setq pukiwiki-site-list
      '(   ("lange" "http://lange.local/~ShunsukeAki/pukiwiki/" nil utf-8)
	   ("pro" "http://pro.local/~akisyunsuke/pukiwiki-1.4.7_notb_utf8/index.php" nil utf-8)



	   ;;errror "Args out of range"
					;	    ("lange" "http://lange.local/~ShunsukeAki/pukiwiki/index.php" nil utf-8)
					;	    ("lan" "http://lange.local/~ShunsukeAki/pukiwiki/?RecentChanges" nil utf-8)

	   ;; open with pukiwiki-edit-url for URL encoded.
					;	    ("pukiwiki" "http://www.bookshelf.jp/pukiwiki/pukiwiki.php?%A5%A2%A5%A4%A5%C7%A5%A2%BD%B8%2Fpukiwiki-mode" nil utf-8)
					;	    ("pukiwiki-mode" "http://www.bookshelf.jp/pukiwiki/pukiwiki.php?アイデア集/pukiwiki-mode" nil euc-jp-dos)


	   ;;	    ("Meadow" "http://www.bookshelf.jp/pukiwiki/pukiwiki.php" nil euc-jp-dos)
	   ;;          ("Kawacho" "http://kawacho.don.am/wiki/pukiwiki.php" nil euc-jp-dos)
	   ;;          ("macemacs" "http://macemacsjp.sourceforge.jp/index.php" nil euc-jp-dos)
	   ;;          ("Xyzzy" "http://xyzzy.s53.xrea.com/wiki/wiki.php" nil euc-jp-dos)

	   ))

;; (setq pukiwiki-password-alist
;;       '(("wiki.monaos.org" "name" "password"))
;;         )


)

;; test
(defadvice pukiwiki-mode (after pukiwiki-mode-hook (arg))
  "run hook as after advice"
  (run-hooks 'pukiwiki-mode-hook))

(provide 'my_pukiwiki)
