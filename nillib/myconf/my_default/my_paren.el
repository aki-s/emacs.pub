;;; my_paren.el --- parenthesis related configuration
;;; Commentary:

;; Copyright (C) 2012  Syunsuke Aki

;; Author: Syunsuke Aki
;; Keywords: lisp


;;; Code:
(eval-when-compile (require 'cl))
(require 'paren)
(show-paren-mode 1)

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

(defun* tidy-paren (str &optional (left -1) (right -1))
  "@dev,
   Format parenthesized area of elisp for human friendly format.
   This func would already implemented by somebody. Implemented just programming for fun.
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
