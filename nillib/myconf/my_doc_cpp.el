;; It seems `cclookup' is no more maintained.
;; $ apt install -y cppreference-doc-en-html # then use DevHelp.app would be better.

;;;   http://github.com/tsgates/cclookup
;;;;;;----------------------------------------------------------------------
;;;;
;;;;Searching Local Documents
;;;;=========================
;;;;
;;;;Index the database by yourself
;;;;
;;;;1. download any versions of documents from 'http://www.cppreference.com/cppreference-files.tar.gz'
;;;;2. indexing by typing './cclookup.py -u [path]'
;;;;  ex) ./cclookup.py -u ./www.cppreference.com/wiki
;;(setq cclookup-dir "~/.emacs.d/share/doc/cpp")
(setq cclookup-dir "~/.emacs.d/share/cclookup")
(add-to-list 'load-path cclookup-dir)

;; load cclookup when compile time
(eval-when-compile (require 'cclookup))
(eval-when-compile (require 'cc-mode))

;; set executable file and db file
(setq cclookup-program (concat cclookup-dir "/cclookup.py"))
(setq cclookup-db-file (concat cclookup-dir "/cclookup.db"))

;; to speedup, just load it on demand
(autoload 'cclookup-lookup "cclookup"
  "Lookup SEARCH-TERM in the Python HTML indexes." t)

(autoload 'cclookup-update "cclookup"
  "Run cclookup-update and create the database at `cclookup-db-file'." t)

(eval-when-compile
  (require 'cc-mode)
  )
(define-key c++-mode-map "\C-ch" 'cclookup-lookup)
(provide 'my_doc_cpp)
