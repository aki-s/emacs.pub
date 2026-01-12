;;; my_imenu_tests.el --- ert.el                     -*- lexical-binding: t; -*-

;; Copyright (C) 2014  

;; Author:  Syunsuke Aki
;; Keywords: lisp

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Run tests:
;; $ emacs -batch --directory . -l my_paren_tests.el -f ert-run-tests-batch-and-exit
;; @see info 5.6.3 Functions that Rearrange Lists

;;; Code:

(require 'ert)
(require 'lispxmp)
(load-library "my_paren")

;;-----------------------------------------------------------------
;; Variables for test
;;-----------------------------------------------------------------
(defvar subsamp6-3 'a)             ; => subsamp6-3
(defvar subsamp6-2 '"a")             ; => subsamp6-2
(defvar subsamp6-1 '("abc"))             ; => subsamp6-1
(defvar subsamp5-5-1 (list 'a nil  'b) "  is length==")             ; => subsamp5-5-1
(defvar subsamp5-5-0 (cons 'a  'b) " (cons 'a  'b) is safe-length==1")             ; => subsamp5-5-0
(safe-length subsamp5-5-0) ; => 1
(defvar subsamp5-8 '('("a" "b") "c" "d") "length==3")             ; => subsamp5-8
(defvar subsamp5-8-1 '('("a" "b") ("c" "d")) "length==2")             ; => subsamp5-8-1
(cons '("a" "b") (list "c" "d")) ; => (("a" "b") "c" "d")
(defvar subsamp5-7 '('("a" "b") "c") "length==2")             ; => subsamp5-7
;;err (defvar subsamp5-6 '('("a" "b") 'c))             ; => subsamp5-6
(defvar subsamp5-6 '('("a" "b")) "length==1")             ; => subsamp5-6
(defvar subsamp5-5 '('a . 'b) "('a quote b) is length==3. This should be 2?")             ; => subsamp5-5
(consp subsamp5-5) ; => t
(length subsamp5-5) ; => 3
(car subsamp5-5) ; => (quote a)
(cdr subsamp5-5) ; => (quote b)
(cadr subsamp5-5) ; => quote
(cddr subsamp5-5) ; => (b)
(defvar subsamp5-4 '('a  'b))             ; => subsamp5-4
(consp subsamp5-4) ; => t
(length subsamp5-4) ; => 2
(safe-length subsamp5-4) ; => 2
(defvar subsamp5-3 '('a  "b"))             ; => subsamp5-3
(defvar subsamp5-2-1 '("a"  "b" "c") "length==3")             ; => subsamp5-2-1
(defvar subsamp5-2-2 '("a"  "b" "c" "d") "length==4")             ; => subsamp5-2-2
(defvar subsamp5-2-3 '("a"  "b" "c" "d" "e") "length==5")             ; => subsamp5-2-3
(defvar subsamp5-2 '("a"  "b") "length==2")             ; => subsamp5-2
(defvar subsamp5-1 '("a" . "b"))             ; => subsamp5-1
(defvar subsamp4-5 '("Imports" ("a" . "b") "c"))             ; => subsamp4-5
(defvar subsamp4-5 '("Imports" "o" ("a" . "b") "c"))             ; => subsamp4-5
(defvar subsamp4-4 '("Imports" "o1" "o2" ("a" . "b")))             ; => subsamp4-4
(defvar subsamp4-3 '("Imports" "o" ("a" . "b")))             ; => subsamp4-3
(defvar subsamp4-2 '("Imports" ("a" . "b")))             ; => subsamp4-2
(defvar subsamp4-1 '(("Imports" ("a" . "b"))))             ; => subsamp4-1
(defvar subsamp3-2 '(("Imports" ("a" . "b")) ("Package" ("a" . "b"))))             ; => subsamp3-2
(defvar subsamp3-1 '("vtype" "var12" . "#<e>"))             ; => subsamp3-1
(defvar subsamp3-1-1 '("vtype" ("var12" . "#<e>")))             ; => subsamp3-1-1
(defvar subsamp3-1-2  (list "vtype" (cons "var12" "#<e>")))             ; => subsamp3-1-2
(defvar subsamp2-2 '("class" "class1-2" ("Variables" ("vtype" "var12" . "#<e>")) ("Methods" ("func11" "(arg12)" . "#<ff>")) ("*definition*" . "#<g>")))             ; => subsamp2-2
(defvar subsamp2-1 '("class" "class1-1" ("Variables" ("vtype" "var11" . "#<aa aa aa>")) ("Methods" ("void" "func11(arg11)" . "#<bb bb b>")) ("*definition*" . "#<c d>")))             ; => subsamp2-1


(defvar subsamp1-1 `("class" "class1"
                   ("Classes" 
                    ,subsamp2-1
                    ,subsamp2-2
                    )) )
(defvar subsamp1-2  `("Classes" 
                 ("class" "class1"
                  ("Classes" 
                   ,subsamp2-1
                   ,subsamp2-2
                   ))) )


(defvar samp0 `(
             ("Classes" 
              ("class" "class1"
               ("Classes" 
                ("class" "class1-1" 
                 ("Variables"
                  ("vtype" "var11" . "#<aa aa aa>"))
                 ("Methods" 
                  ("void" "func11(arg11)" . "#<bb bb b>"))
                 ("*definition*" . "#<c d>") 
                 )
                ("class" "class1-2"       
                 ("Variables"
                  ("vtype" "var12" . "#<e>"))
                 ("Methods" 
                  ("func11" "(arg12)" . "#<ff>"))
                 ("*definition*" . "#<g>") 
                 )                   ;; subsamp2
                )) ;; subsamp1
              )  ;car
             ("Imports" ("a" . "b"))
             ("Package" ("a" . "b"))
             ) )

;;-----------------------------------------------------------------
;; defun
;;-----------------------------------------------------------------
;;-----------------------------------------------------------------
;; Test case
;;-----------------------------------------------------------------
(when nil ;; for development purpose
  (tidy-paren (imenu--make-index-alist))
  (tidy-paren samp0)
  (tidy-paren subsamp1-1)
  (tidy-paren subsamp1-2)
  (tidy-paren subsamp2-1)
  (destructuring-bind (a &optional b) subsamp5-2
    (list a b)
    (listp b)             ; => 
    )
  (destructuring-bind (a . b) subsamp5-1
    (list a b)
    (listp b)             ; => 
    )
  )
(car '('a b)) ; => (quote a)
(safe-length (car '('a b))) ; => 2
(symbolp 'a) ; => t
;;(symbolp a) ; => 
(symbolp "a") ; => nil
(symbolp '("a")) ; => nil
(atom 'a) ; => t
(safe-length (atom 'a)) ; => 0
(safe-length 'a) ; => 0
(tidy-paren subsamp6-3)             ; => a
(tidy-paren subsamp6-2)             ; => "a"
(safe-length subsamp6-2)            ; => 0

(tidy-paren subsamp6-1)             ; => ("abc")
(safe-length subsamp6-1)            ; => 1
(mapcar 'tidy-paren subsamp6-1)     ; => ("abc")
(tidy-paren subsamp5-1)             ; => ("a" . "b")
(if (every 'listp subsamp5-1) (mapcar 'tidy-paren subsamp5-1))             ; => nil
(atom subsamp5-1)                   ; => nil
(safe-length subsamp5-1)            ; => 1
(tidy-paren subsamp5-2)             ; => "(\"a\" \"b\")\n"
(safe-length subsamp5-2)            ; => 2
(tidy-paren subsamp5-2-1)           ; => "(\"a\"\"b\"\"c\")\n"
(tidy-paren subsamp5-2-2)           ; => ("a" "b" "c" "d")
(tidy-paren subsamp5-2-3)           ; => ("a" "b" "c" "d" "e")
(tidy-paren subsamp5-3)             ; => "((quote a)\n \"b\" )"
(tidy-paren subsamp5-4)             ; => "((quote a)\n (quote b))"
(tidy-paren subsamp5-5)             ; => "((quote a)\n quote b)"
(tidy-paren subsamp5-6)             ; => ((quote ("a" "b")))
(tidy-paren subsamp5-7)             ; => "((quote \"(\\\"a\\\" \\\"b\\\")\n\")\n \"c\" )"
(tidy-paren subsamp5-8)             ; => "((quote \"(\\\"a\\\" \\\"b\\\")\n\")\n \"c\" \"d\")"
(tidy-paren subsamp5-8-1)           ; => "((quote \"(\\\"a\\\" \\\"b\\\")\n\")\n (c d))"
(replace-regexp-in-string "\\\\" "" (tidy-paren subsamp5-8)  )
(tidy-paren subsamp4-1)             ; => (("Imports" ("a" . "b")))
(tidy-paren subsamp4-2)             ; => "(\"Imports\" (\"a\" . \"b\"))\n"
(replace-regexp-in-string "\\\\" "" (tidy-paren subsamp4-2)  )
(tidy-paren subsamp4-3)             ; => "(\"Imports\"\"o\"(\"a\" . \"b\"))\n"
(tidy-paren subsamp4-4)             ; => ("Imports" "o1" "o2" ("a" . "b"))
(tidy-paren subsamp4-5)             ; => "(\"Imports\" \" ((a . b) \\\"c\\\" )\")\n"
(tidy-paren subsamp3-1)             ; => "(\"vtype\" (\"var12\" . \"#<e>\"))\n"
(tidy-paren subsamp3-1-1)           ; => "(\"vtype\" (\"var12\" . \"#<e>\"))\n"
(tidy-paren subsamp3-1-2)           ; => "(\"vtype\" (\"var12\" . \"#<e>\"))\n"
(tidy-paren subsamp3-2)             ; => "((\"Imports\" (\"a\" . \"b\"))\n (Package (a . b)))"
(tidy-paren subsamp2-1)             ; => ("class" "class1-1" "(\"Variables\" \"(\\\"vtype\\\" (\\\"var11\\\" . \\\"#<aa aa aa>\\\"))\n\")\n" "(\"Methods\" \"(\\\"void\\\" (\\\"func11(arg11)\\\" . \\\"#<bb bb b>\\\"))\n\")\n" ("*definition*" . "#<c d>"))
(tidy-paren subsamp2-2)             ; => ("class" "class1-2" "(\"Variables\" \"(\\\"vtype\\\" (\\\"var12\\\" . \\\"#<e>\\\"))\n\")\n" "(\"Methods\" \"(\\\"func11\\\" (\\\"(arg12)\\\" . \\\"#<ff>\\\"))\n\")\n" ("*definition*" . "#<g>"))

;(replace-regexp-in-string "\\\\" "" (tidy-paren subsamp2-2)  )

;;-------------------------------------------------------------
;; ert-deftest
;;-------------------------------------------------------------
(eval-when-compile 'subr)
;(declare "should")
(ert-deftest my_paren-subsamp6-1 ()
  ""
  )

(provide 'my_paren_test)
