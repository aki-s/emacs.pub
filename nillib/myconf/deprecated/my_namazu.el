;;; -- namazu.el --
;;; http://www.bookshelf.jp/soft/meadow_52.html#SEC787
(setq namazu-search-num 100) ;; 1 ページに表示する結果数
(setq namazu-auto-turn-page t) 
(autoload 'namazu "namazu" nil t)
(setq namazu-index-alist
      '(("alias1" "~/Sites/namazu/index")
	("alias2" "~/Sites/namazu/index/index4pukiwiki")))
(setq namazu-default-index "alias2")
