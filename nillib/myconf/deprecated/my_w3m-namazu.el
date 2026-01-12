;;; -- w3m-namazu.el
;;;namazu.el を使っていれば，特に設定しなくても， namazu.el の設定を使って検索できます． namazu.el を利用していなければ，以下のように設定しておきます． 
;;; http://web.mit.edu/~mkgray/afs/bar/afs/sipb.mit.edu/contrib/emacs/packages/w3m_el-1.2.8/README.namazu.ja
;; インデックスのディレクトリ
;; 複数あればスペースで区切る
					;(setq namazu-default-dir "c:/dic/namazu/index/www/ c:/dic/namazu/index/mail/")
(setq w3m-namazu-index-alist
      '(("alias1" "~/Sites/namazu/index")
	("alias2" "~/Sites/namazu/index/index4pukiwiki")))
(setq w3m-namazu-default-index "alias2")

