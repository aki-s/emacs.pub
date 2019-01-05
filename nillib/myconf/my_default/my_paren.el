;;; my_paren.el --- parenthesis related configuration
;;; Commentary:

;; Copyright (C) 2012  Syunsuke Aki

;; Author: Syunsuke Aki
;; Keywords: lisp


;;; Code:
(eval-when-compile (require 'cl))
(require 'paren)
(show-paren-mode 1)

;;$notgood$;; (require 'skeleton)
;;$notgood$;; ;; under dev
;;$notgood$;; (setq skeleton-pair-alist
;;$notgood$;;       (list ?\( ?  _ " )")
;;$notgood$;;       )
;;$notgood$;; ;'(lambda()
;;$notgood$;; (defun my_paren()
;;$notgood$;;    "対応する括弧の挿入"
;;$notgood$;;    (interactive )
;;$notgood$;;    (make-variable-buffer-local 'skeleton-pair)
;;$notgood$;;    (make-variable-buffer-local 'skeleton-pair-alist)
;;$notgood$;;    (make-variable-buffer-local 'skeleton-pair-on-word)
;;$notgood$;;    (setq skeleton-pair-on-word t)
;;$notgood$;;    (setq skeleton-pair t)
;;$notgood$;;    (local-set-key (kbd "(") 'skeleton-pair-insert-maybe)
;;$notgood$;;    (local-set-key (kbd "[") 'skeleton-pair-insert-maybe)
;;$notgood$;;    (local-set-key (kbd "{") 'skeleton-pair-insert-maybe)
;;$notgood$;;    (local-set-key (kbd "`") 'skeleton-pair-insert-maybe)
;;$notgood$;;    (local-set-key (kbd "\"") 'skeleton-pair-insert-maybe)
;;$notgood$;;    )
;;$notgood$;; (my_paren)

;;$ paredit steals M-s (require 'paredit)
;;$ paredit steals M-s (add-hook  'emacs-lisp-mode-hook 'enable-paredit-mode)
;;$ paredit steals M-s (add-hook 'lisp-mode-hook 'enable-paredit-mode)
(setq ;; paren.el provided
 show-paren-delay 0.1
 show-paren-style 'expression ; always highlight area enclosed by parenthesis
 )

(defun my_paren-c-electric-backspace ()
 "Avoid $ sp--strict-regexp-quote: Wrong type argument: stringp, nil
When (kbd \"<delete>\") is called.
"
  (interactive)
  ;; (c-electric-backspace 1)
  (delete-char -1)
  )
;;--------------------------------------------------------------
(defun my_smartparens ()
  "@dev
  try out 'smartparens
@bug
  "
  (interactive)
  (load-library "smartparens") ; sp-point-in-string confilict with evil? (disable back space in evil insert mode)
  (smartparens-global-mode t)
  ;;@TBD
  ;; *
  (sp-pair "\"" nil :when '(sp-point-after-word-p))
  (sp-pair "\'" nil :when '(sp-point-after-word-p))
  ;;  (sp-pair "\"" nil :when '(sp-point-after-word-p))
  ;;(sp-pair "'" nil :when '(sp-point-after-word-p))
  (setq electric-pair-mode nil)
  (global-set-key (kbd "<backspace>") 'my_paren-c-electric-backspace)
  )

;;(my_smartparens)
(electric-pair-mode 1)

;; c-cleanup-list

;; (setq parens-require-spaces t); default to t
;; (require 'smartparens-config) ;option
;;TBD
                                        ; undo smartparen
;; (setq sp-undo-pairs-separately t)
;; buffer-undo-list undo-tree-canary

;;TBD00;; (defun my_paren ()
;;TBD00;; (save-excursion
;;TBD00;; (re-search-forward)
;;TBD00;; (re-search-backward)
;;TBD00;; (looking-at "")
;;TBD00;; )
;;TBD00;;
;;TBD00;; (define-key -mode-map "(" 'my_paren)

;;;; Make matched paren appear no near mouse pointer
(unless (member 'top (mapcar 'car tooltip-frame-parameters))
  (add-to-list 'tooltip-frame-parameters '(top . 1)))
(unless (member 'left (mapcar 'car tooltip-frame-parameters))
  (add-to-list 'tooltip-frame-parameters '(left . 1)))

(if window-system ; tooltip would not work without frame
  (defadvice show-paren-function (after show-matching-paren-in-tooltip activate)
    (ignore-errors (my_tooltip-show-matching-line))
  ))

(defun my_tooltip-show-matching-line ()
  "Show matching line number N and string of line S, when matching parenthesis is not visible.

Format is \"[N]S\""
  (interactive)
  (let* (
          (sclass (syntax-class (syntax-after (point))))
          (direction (cond
                       ((eq sclass 5) -1) ; close paren
                       ((eq sclass 4) 1)) ; open paren
            )
          (mpp (if direction (scan-sexps (if (= direction 1) (point) (1+ (point))) direction))) ; mpp := matched paren position
          )
      (unless (pos-visible-in-window-p mpp)
        (setq lnum (line-number-at-pos mpp))
        (setq lstring (save-excursion (goto-char mpp) (back-to-indentation)
                    (buffer-substring-no-properties (point) (line-end-position))))
        (setq txt (format "[%s]%s" lnum lstring))

        (tooltip-show txt))
    )
  )

(defun my_paren-context-jump ()
  "@dev
   Pop out of parenthesized area 1 level if <tab> was pressed.
   @ref yas--move-to-field
   "
  )

(defun atom-consp (str)
  "@dev @bug"
  (if (> (safe-length (uncons str)) 1 ) nil t)
  )

(defun uncons (str)
  " Remove recursive cons to initial cons.
  "
  (while (and
          (not (atom str))
          (null (cdr-safe str))
          )
    (setf str (car-safe str))
    (uncons str)
    )
  str)

(defun uncons-f (str)
  " Remove recursive cons to one string.
@dev
  "
  (while (and
          (null (cdr-safe str))
          )
    (setf str (concat str (car-safe str)))
    (uncons str)
    )
  str)

;(defun concat-any (&rest lst)
;  "@dev
;   Concatenate any type of argument as a string..
;  "
;  (let ((str ""))
;    (loop
;     for el in lst
;     do
;     (message "%s:%s:%s:%s" lst str el (type-of el))
;     (typecase el
;       ;(list   (add-to-list 'str (format "%s" el)))
;       ;(string (add-to-list 'str el str))
;       ;;(list   (setq str (concat str (format "%s" el))))
;       (list   (setq str (concat str "(" (mapconcat el) ")")))
;       (vector ()) ;@TBD
;       (string (setq str (concat str (format "%s" el ))))
;       (character ())
;       (atom ())
;       (null ())
;       );typecase
;     )
;  str))

(defun concat-any (&rest lst)
  "@dev
   Concatenate any type of argument as a string..
  "
  (let ((str ""))
    (when (> (length lst) 0)
     (setf el (pop lst))
     (message "%s:%s:%s:%s" lst str el (type-of el))
     (typecase el
       (list   (setq str (format "%s" el)))
       ;(string (add-to-list 'str el str))
       ;;(list   (setq str (concat str (format "%s" el))))
       ;(list   (setq str (concat str "(" (mapconcat el) ")")))
       (vector ()) ;@TBD
       (string (setq str (concat str (format "%s" el ))))
       (character ())
       (atom ())
       (null ())
       );typecase
     )
  str))

(eval-when-compile 'cl) ; defun*
;;ok (defun* tidy-paren (str &optional (left -1) (right -1))
;;ok   "@dev,
;;ok    Format parenthesized area of elisp for human friendly format.
;;ok    This func would already implemented by somebody. Implemented just programming for fun.
;;ok    @ref. anything-imenu-create-candidates
;;ok   "
;;ok   (incf left)
;;ok   (incf right)
;;ok   (require 'my_basic_func) ; spaces-string
;;ok   (message "%S:%S" (type-of str) str ) ; debug
;;ok   ;;  (if (consp str) ; nil/atom is not cons
;;ok   ;;(if (> (safe-length str) 1 ) ; not atomic cons. ref. (length 'a) is 2, but (atom 'a) is t .
;;ok   (if (and (> (safe-length str) 1 ) (not (atom str))) ; not atomic cons. ref. (length 'a) is 2, but (atom 'a) is t .
;;ok       ;;;; No supprise to fail if str is '("aand" . #<marker at 1013 in test-deferred.el>)
;;ok       ;;;; We need preprocessor to convert no symbol and no string to string.
;;ok       (progn ;0
;;ok         (let (
;;ok               (car-str (car str))
;;ok               (cdr-str (uncons (cdr str)))
;;ok               ret
;;ok               ) ;0
;;ok           (if (and (atom car-str) (not (null cdr-str))) ; car is atom
;;ok               ;;nottest (if (and (atom (car-safe cdr-str)) (not (null (car-safe cdr-str)))))  ; cadr is stom
;;ok               (cond;0
;;ok                ((and (atom (car-safe cdr-str)) (> (safe-length str) 3) )
;;ok                 (setq ret (mapcar 'tidy-paren str))
;;ok                 ;;(setq ret (mapcar '(lambda (x) (tidy-paren x left right)) (list str) ))
;;ok                 )
;;ok                ((and (atom (car-safe cdr-str)) (> (safe-length str) 2) )
;;ok                 ;error (setq ret (concat   (format "%S" car-str) " " (car-safe cdr-str) (tidy-paren (uncons (cdr-safe cdr-str)) left right) "\n" )) ; shift
;;ok                 (setq ret (list  car-str (car-safe cdr-str) (tidy-paren (uncons (cdr-safe cdr-str)) left right))) ; shift
;;ok                 )
;;ok               ;;22 ((and (atom (car-safe cdr-str)) (> (safe-length str) 1) (listp cdr-str) )
;;ok               ;;22  (setq ret (list car-str (mapcar '(lambda (x) (tidy-paren x left right)) (list cdr-str) )))
;;ok               ;;22  )
;;ok                ( t
;;ok                  (setq ret (concat "(" (format "%S %S" car-str (tidy-paren cdr-str left right)) ")\n"))
;;ok                  ;;(setq ret (list  car-str (tidy-paren cdr-str left right)))
;;ok                  )
;;ok                );cond0
;;ok             (progn ; car is not atom
;;ok               ;; process car
;;ok               ;;(setq ret (concat (spaces-string left) "(" ret (tidy-paren car-str left right) ) )
;;ok               ;;  (setq ret (concat-any (spaces-string left) (tidy-paren car-str left right) ) )
;;ok               (setq ret (concat (spaces-string left) (format "%S" (tidy-paren car-str left right)) ) )
;;ok               ;; process cdr
;;ok               (if (atom cdr-str) ; end recursion
;;ok                   (setq ret (concat ret " " (format "%S" (if (null cdr-str) "" cdr-str )) " \)"))
;;ok                 ;; (setq ret (concat "(" ret (format " %s%s)" (spaces-string left) (tidy-paren cdr-str left right))))
;;ok
;;ok                 ;; (setq ret (concat "(" ret (format " %s%s)" (spaces-string left) (mapcar '(lambda (x) (tidy-paren x)) '(cdr-str left right)))))
;;ok                 (setq ret (concat "(" ret (format " %s%s)" (spaces-string left) (mapcar '(lambda (x) (tidy-paren x left right)) (list cdr-str)))))
;;ok                 )
;;ok               )
;;ok             ret)
;;ok           );let0
;;ok         );progn0
;;ok     ;;   (format "%s" str)  ; return atomic cons
;;ok     str  ; return atomic cons
;;ok     )
;;ok   );tidy-paren

(defun* tidy-paren (str &optional (left -1) (right -1))
  "@dev,
   Format parenthesized area of elisp for human friendly format.
   This func would already implemented by somebody. Implemented just programming for fun.
   @ref. anything-imenu-create-candidates pp.el::pp
   @TODO The result is list or string depending on the situation. Need to be a string.
   Implementation should be macro, because handling '(' and ')' is too tedious.
  "
  (incf left)
  (incf right)
  (require 'my_basic_func) ; spaces-string
  (message "%S:%S" (type-of str) str ) ; debug
  ;;  (if (consp str) ; nil/atom is not cons
  ;;(if (> (safe-length str) 1 ) ; not atomic cons. ref. (length 'a) is 2, but (atom 'a) is t .
  (cond
   ((> (safe-length str) 1 ) ; not atomic cons. ref. (length 'a) is 2, but (atom 'a) is t .
      ;;;; No supprise to fail if str is '("aand" . #<marker at 1013 in test-deferred.el>)
      ;;;; We need preprocessor to convert no symbol and no string to string.
    (progn ;0
      (let (
            (car-str (car str))
            (cdr-str (uncons (cdr str)))
            ret
            ) ;0
        (if (and (atom car-str) (not (null cdr-str))) ; car is atom
            ;;nottest (if (and (atom (car-safe cdr-str)) (not (null (car-safe cdr-str)))))  ; cadr is stom
            (cond;0
             ((and (atom (car-safe cdr-str)) (> (safe-length str) 3) )
              (setq ret (mapcar 'tidy-paren str))
              )
             ((and (atom (car-safe cdr-str)) (> (safe-length str) 2) )
              (setq ret (concat   (format "(%S%S%S" car-str (car-safe cdr-str) (tidy-paren (uncons (cdr-safe cdr-str)) left right))  (if (eq (last str) (cdr-safe cdr-str)) "\)" "") "\n" )) ; shift
              ;;(setq ret (list  car-str (car-safe cdr-str) (tidy-paren (uncons (cdr-safe cdr-str)) left right))) ; shift
              )
             ( t
               (setq ret (concat "(" (format "%S %S" car-str (tidy-paren cdr-str left right)) ")\n"))
               )
             );cond0
          (progn ; car is not atom
            (setq ret (concat (spaces-string left) (format "(%s" (tidy-paren car-str left right)) ) )
            ;; process cdr
            (cond
             ((atom cdr-str) ; end recursion
              (setq ret (concat ret " " (format "%S" (if (null cdr-str) "" cdr-str )) " \)"))
              )
             ((and (atom (car-safe cdr-str)) (> (safe-length str) 2) )
              (setq ret (concat ret (format " %S %S" (car-safe cdr-str) (tidy-paren (uncons (cdr-safe cdr-str)) left right)) (if (atom (uncons (cdr-safe cdr-str))) "\)" "") )) ; shift
              )
             ((markerp (cdr cdr-str))
              ;; do nothing.    Avoids  'cdr-str: Wrong type argument: listp, #<marker at 331 in xx.cpp>'.
              )
;;             ((markerp cdr-str)
;;              )
             (t
              (setq ret (concat ret (format " %s%s)" (spaces-string left) (mapcar #'(lambda (x) (tidy-paren x left right)) cdr-str))))
              )
             )
            )
          ret)
        );let0
      );progn0
    )
   ;;   (format "%s" str)  ; return atomic cons
   ((atom str) str)  ; return atomic cons
   ((symbolp str) str)
   (t str)
   );cond0
  );tidy-paren

(defun* tidy-paren-1 (str )
  (interactive)
 (replace-regexp-in-string "\\\\" "" (tidy-paren str)  )
 )

;; (if (cdr str) dot-list  )
;;$ (listp (cdr (cons 2 1 ))) ; => nil
;;$ (listp (cdr '(2 1 ))) ; => t

;;$ (safe-length (cons 2 1  )) ; => 1
;;$ (safe-length '(2 1  )) ; => 2

(provide 'my_paren)
;;; my_paren.el ends here
