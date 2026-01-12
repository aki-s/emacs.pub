;;; package: ---
;;; Commentary:
;;; Code:

;;;; Preparation of Hunspell
;;; hunspell -D # show pre configured locations of dictionaries.

;;;; Preparation for MacOSX
;;; port install hunspell hunspell-dict-en_US
;;; brew install hunspell # brew doesn't provides dictionary.

;;;; Preparation for Linux
;;; apt install hunspell
;;; yum install hunspell


(require 'ispell)
;;;debug (setq ispell-debug-buffer t)

(eval-after-load "ispell"
  '(progn
     (add-to-list 'ispell-skip-region-alist '("[^\000-\377]")) ; for japanese
     )
  )

;;; hunspell on OSX or emacs24?
(setq ispell-local-dictionary t)
(setq ispell-local-dictionary-alist
      '(
        ("en_US" ; ispell?
         "[A-Za-z]" "[^A-Za-z]" "[']" nil ("-d" "en_US") nil iso-8859-1)
        ("en-US" ; hunspell
         "[A-Za-z]" "[^A-Za-z]" "[']" nil ("-d" "en-US") nil iso-8859-1)
        ))

(setq-default ispell-program-name
              (or
               (prog1 (executable-find "hunspell")
                 (setq ispell-dictionary "en-US")
                 (setenv "DICPATH" (expand-file-name (concat user-emacs-directory "/share/dict/")))
                 (setenv "DICTIONARY" "en-US")
                 ) ; american -> en-US
               ;; Remove support for aspell, because it makes setup complex. (executable-find "aspell")  ; lang en_US
               (executable-find "ispell") ; en_US
               (message "ERROR no program was found for `ispell-program-name'")
               nil))

;; (setq ispell-current-personal-dictionary nil)
;; (setq ispell-dictionary-alist nil) ;default
;; (setq ispell-current-dictionary nil)

;;;; Stack trace
;; ispell-hunspell-dict-paths-alist ; (("en-US" "/Library/Spelling/en-US.aff"))
;; ispell-parse-hunspell-affix-file
;; ispell-hunspell-fill-dictionary-entry ; `ispell-dictionary' is passed.
;; ispell-start-process

;; ispell-find-hunspell-dictionaries

(provide 'my_ispell)
;;; my_ispell.el ends here
