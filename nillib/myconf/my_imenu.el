;;; my_imenu.el --- imenu extension

;; Copyright (C) 2014

;; Author:  Syunsuke Aki
;; Keywords:

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

;; Alpha level of release.
;; Worked on emacs-lisp-mode and java-mode.
;; Still requires test.

;;; Code:
(require 'imenu)

(require 'ggtags) ; ggtags-mode ggtags-find-project
(require 'gtags nil t) ; Avoid error caused by requiring binary gtags
(require 'helm)
(require 'helm-imenu) ; helm-imenu
(require 'helm-gtags) ; helm-gtags--include-regexp helm-gtags-mode helm-gtags-dwim
(require 'helm-lib) ; helm-current-line-contents
(require 'mode-local) ; define-overload

(defvar my_imenu-debug nil "Debug flag for my_imenu.el.")
;; (defun debug-message (&rest msg)
;;   "Print message if my_imenu-debug is 't."
;;   (if my_imenu-debug (apply 'message (format "%s" str) msg))
;;   )
(defun debug-message (msg)
  "Eval MSG if my_imenu-debug is 't."
  (if my_imenu-debug (eval msg))
  )

(defun my_imenu:toggle-debug-mode ()
  "Toggle 'my_imenu-debug."
  (interactive)
  (if my_imenu-debug
    (setq my_imenu-debug nil)
    (setq my_imenu-debug t)
    )
  (message "'my_imenu-debug is %s" my_imenu-debug)
  )

(defun my_imenu-reset-imenu-create-index-function ()
  "If some other library like as `semantic-create-imenu-index' steals imenu-create-index-function, fix it.
Function `imenu-default-create-index-function' exists as of emacs 24.5.1.
"
  (interactive)
  ;; (setq-local
  (setq-default
    imenu-create-index-function
    #'imenu-default-create-index-function)
  (setq-local
    imenu-create-index-function
    #'imenu-default-create-index-function)
  )

(defun my_imenu--in-alist (str alist &optional depth)
  "@dev Fix for imenu--in-alist
   Check whether the string 'str is contained in nested 'alist and
   return cons cell ( (symbol-name str) . position) if found.
   If function name and variable name is the same, then ... @TBD
   @ref (imenu--make-index-alist)
"
  (if (numberp depth)
    (progn
      (setf depth (1+ depth))
      (debug-message '(message "[depth] %s" depth)) ;; debug
      )
    (setq depth 0)
    )
  (let (elt head tail res
         (case-fold-search nil)
         )
    (setq res nil)
    (while alist
      ;; (tidy-paren alist)
      (setq elt (car alist)
        head (if (atom elt) elt (car elt)) ; head: Rescan, Classes, Variables, "class xxx"
        ;; elisp: (("*Rescan*" . -99) ("Variables" ("var1". <vpos1>)) ("fun1 . <fpos1>") ("fun2 . <fpos2>")  )
        ;; java: (("*Rescan*" . -99) ("Classes" ("class c1" ())) ("Imports" ("imv1" .<i1>)))
        tail (if (atom elt) elt (cdr elt)); tail: Position in buffer,or list remaining to be examined
        alist (cdr alist) ; alist: Group of list remaining to be examined
        )
      (cond ; Group of list
        ((string= head "*Rescan*")
          ;; Do nothing
          )
        ((string= head "Variables")
          (setq res (my_imenu--in-alist str tail depth))
          )
        ( (or (string= head "Classes"))
          (setq res (my_imenu--in-alist str tail depth))
          )
        ( (null head); block before calling string-match
          (my_imenu-reset-imenu-create-index-function)
          (message "Set 'imenu-create-index-function to #'imenu-default-create-index-function")
          )
        ( ; sub-group of "Classes"
          (string-match "class[\t ]+\\([^\"]+\\)" head ) ;@bug error if head is nil. @fixed?
          ;; (and head (string-match "class[\t ]+\\([^\"]+\\)" head ))
          (let (
                 (class-name (substring head (match-beginning 1) (match-end 1)))
                 )
            (if (string-match "*definition*" (caar tail)) ; tail is a list
              (setf (caar tail) class-name)
              )
            (setq res (my_imenu--in-alist str tail depth))
            )
          )
        ( ;
          (or (string= head "Imports"))
          ;; @TBD
          )
        ((not (consp elt)) ; recur 'my_imenu--in-alist
          (if (setq res (my_imenu--in-alist str alist depth))
            (setq alist nil))
          (debug-message '(message "found:(alist=%s|res=%s|elt=%s)" alist res elt)) ;debug
          (setq alist nil res elt))
        ((consp elt)
          (if (string-equal str head) ; @TODO type check [ret func-name arg ...]
            (setq res elt)
            )
          )
        (t
          ()
          ;; @TBD
          )
        );cond
      );while
    res))

(eval-when-compile (require 'cl))
(defmacro my_imenu-debug-funcall (&rest funcargs)
  "Message the results of FUNCARGS.
Format of the message is (returned value, FUNC, ARGS)."
  (let ((ret (cl-gensym))
         (func (caar funcargs))
         (args (cdar funcargs))
         )
    `(progn
       (setq ,ret ,@funcargs)
       (message "%S:ret=%S,func=%S,args=%S" this-command ,ret ',func ',args)
       (sit-for 10)
       )))

(eval-when-compile
  (require 'evil-core) ; evil-mode
  )

;;;###autoload
(define-overload my_imenu-jump ()
  "Quickly jump to the definition of function within selected buffer.
   Think this function is smarter version of anything-imenu.
   @ref. The form returned by function imenu--make-index-alist for java file is
anything-imenu fails, but helm-imenu work well. \(;v;)/
Just binding helm-imenu was sufficient...?
   @todo:
    - Create test case.
    - make work for perl code
   @bug:
        - It could't be jumped to defmacro*.
Is this a bug of 'imenu--make-index-alist or mine?
- Not work if 'defun is inside 'when in 'emacs-lisp-mode.
   '(
    (Classes
     (class class1
            (Classes
             (class class1-1
                    (Variables
                     (vtype var11 . #<>))
                    (Methods
                     (func11(arg11) . #<>))
                    (*definition* . #<>)
                    )
             (class class1-2
                    (Variables
                     (vtype var12 . #<>))
                    (Methods
                     (func11(arg12) . #<>))
                    (*definition* . #<>)
                    )
             )))  ;car
    (Imports (a . b))
    (Package (a . b))
    )
"
  (interactive)
 ;;  (push-mark) ; [C-x C-@][C-x C-SPC] pop-global-mark, [C-x c C-c SPC] helm-all-mark-rings, [] helm-global-mark-ring . TODO create my jump stack.

  (setq-local default-directory (expand-file-name default-directory)) ;; Sometimes "~" is set but, helm-gtag doesn't expand "~"
  (let* ((imenu-idx (imenu--make-index-alist)) ;; Bug here: If "This buffer cannot use `imenu-default-create-index-function'", then I have to create xxx-imenu-generic-expression?

          (name
            (or (ignore-errors (thing-at-point 'symbol t) ; fail on emacs24.3.1
                  )
              (thing-at-point 'symbol)))
          ;; should be automatically selected (imenu-create-index-function #'imenu-default-create-index-function) ;,or #'semantic-create-imenu-index
          ;; semantic-imenu-goto-function
          (marker (cdr (or
                         (imenu--in-alist name imenu-idx)
                         (my_imenu--in-alist name imenu-idx
                           ;; (if imenu-generic-expression (imenu--make-index-alist) (helm-imenu-candidates))
                           ;; (helm-imenu-candidates); my_imenu--in-alist doesn't support (helm-imenu-candidates)
                           ;; (imenu--make-index-alist)
                           ))))
          (pt (if (markerp marker) (marker-position marker)))
          ;;@TBD          (point-fun (cdr lst))
          ;;@TBD          (point-var (car lst))
          (pmarker (point-marker))
          (buf-name (buffer-name))
          (imenu-index-not-corrupted (< 1 (length imenu-idx)))
          )
    ;;(message "%s: %s" this-command imenu--index-alist) ; debug
    ;;(debug-message "%s: %s" this-command (tidy-paren imenu--index-alist))
    (debug-message '(message "imenu-create-index-function is %s\n%s: %S"
                      imenu-create-index-function
                      this-command (pp imenu--index-alist)))
    (:override
      (cond
      ;;;; ==================== Resolve within a buffer. ====================
      ;;;; ================================================================

      ;;;; Case: No search target
      ((null name)
        ;; imenu failes if invalid search target does not exists in imenu--index-alist, so you have to check beforehand if target exists.
        (if imenu-index-not-corrupted
          (my_imenu-debug-funcall (call-interactively 'helm-imenu))
          ;;$;; (let ((imenu-create-index-function 'imenu-default-create-index-function))
          ;; Bug here: imenu-create-index-function can be `ruby-imenu-create-index' if source is ruby
          ;; (eq imenu-create-index-function 'ggtags-build-imenu-index) => t
          ;; this cause error because '(ggtags-goto-imenu-index NAME LINE &rest ARGS)
          (my_imenu-debug-funcall (call-interactively 'helm-semantic-or-imenu))
        ))

   ;;;; Case: Search target and its definition was found at 'pt.
      ((and pt
         (numberp pt) ; by `semantic.el'(?) pt can be overlay.
         imenu-index-not-corrupted)
        (message "%s#imenu-default-goto-function" this-command)
        (my_imenu-debug-funcall (imenu-default-goto-function 'dummy pt))
        ;; (imenu (imenu-choose-buffer-index)
        )

      ;;;; ==================== Resolve with tag file. ====================
      ;;;; ================================================================
      ( (and (or (memq major-mode '(c-mode c++-mode)))
         ;; (string-match helm-gtags--include-regexp (helm-current-line-contents)) ;; limit to `include'
          (boundp semantic-mode) semantic-mode
          )
        (my_imenu-debug-funcall (call-interactively 'semantic-ia-fast-jump)))

      ;;;; Case: Search target includes the other files.
      ;;; [Note]
      ;;; Function `semantic-fetch-tags' only fetch `import' statements in Java.
      ;;; Function `semantic-create-imenu-index' returns nil in Java.
      (helm-gtags-mode
        (message "%s#helm-gtags-dwim" this-command)
        (condition-case e
          (my_imenu-debug-funcall (helm-gtags-dwim))
          (user-error
            (message "No GTAGS defind, fall back to local buffer %s#helm-imenu" this-command)
            (sit-for 1)
            (my_imenu-debug-funcall (helm-imenu))) ; When creating GTAGS is aborted.
          )
        )
      ((and ggtags-mode (ggtags-find-project) name)
;; bug here `ggtags-find-project' use "GTAGSROOT or GTAGSLIBPATH"
        (ignore-errors
          ;; fails sometimes at ggtags.el:with-display-buffer-no-window

          ;; (ggtags-find-tag-dwim name) ;; Use find-tag-marker-ring of `etags' as stack?
          (my_imenu-debug-funcall (helm-gtags-dwim))
           ;;; MEMO about stack
          ;; (plist-get (helm-gtags--get-context-info) :stack)
          ;; hash `helm-gtags--context-stack' store context
          )
        )
      (t
        (or (ignore-errors (helm-imenu) t) (imenu (imenu-choose-buffer-index)))
        )
      ))
    (require 'my_simple)
    (my_simple:push-mark pmarker) ; Push mark if successful jump.
    pt)); my_imenu-jump

;; M-o is bound to ggtags-navigation-map:ggtags-navigation-visible-mode
;; Need to call ggtags-navigation-mode-done
;;(global-set-key (kbd "M-o M-o") 'my_imenu-jump)
(global-set-key (kbd "M-O") 'my_imenu-jump)

;;-----------------------------------------------------------------
(require 'ggtags nil t);need lexical-binding
;; imenu-create-index-function is default to imenu-default-create-index-function
;; ref. semantic-create-imenu-index
(setq-local imenu-create-index-function #'ggtags-build-imenu-index)


;;; https://ztlevi.github.io/posts/Get%20your%20imenu%20ready%20for%20modern%20javascript/

(defvar my_imenu:js-generic-expression
  '(("describe" "\\s-*describe\\s-*(\\s-*[\"']\\(.+\\)[\"']\\s-*,.*" 1)
     ("it" "\\s-*it\\s-*(\\s-*[\"']\\(.+\\)[\"']\\s-*,.*" 1)
     ("test" "\\s-*test\\s-*(\\s-*[\"']\\(.+\\)[\"']\\s-*,.*" 1)
     ("before" "\\s-*before\\s-*(\\s-*[\"']\\(.+\\)[\"']\\s-*,.*" 1)
     ("after" "\\s-*after\\s-*(\\s-*[\"']\\(.+\\)[\"']\\s-*,.*" 1)
     ("Controller" "[. \t]controller([ \t]*['\"]\\([^'\"]+\\)" 1)
     ("Controller" "[. \t]controllerAs:[ \t]*['\"]\\([^'\"]+\\)" 1)
     ("Filter" "[. \t]filter([ \t]*['\"]\\([^'\"]+\\)" 1)
     ("State" "[. \t]state([ \t]*['\"]\\([^'\"]+\\)" 1)
     ("Factory" "[. \t]factory([ \t]*['\"]\\([^'\"]+\\)" 1)
     ("Service" "[. \t]service([ \t]*['\"]\\([^'\"]+\\)" 1)
     ("Module" "[. \t]module([ \t]*['\"]\\([a-zA-Z0-9_\.]+\\)" 1)
     ("ngRoute" "[. \t]when(\\(['\"][a-zA-Z0-9_\/]+['\"]\\)" 1)
     ("Directive" "[. \t]directive([ \t]*['\"]\\([^'\"]+\\)" 1)
     ("Event" "[. \t]\$on([ \t]*['\"]\\([^'\"]+\\)" 1)
     ("Config" "[. \t]config([ \t]*function *( *\\([^\)]+\\)" 1)
     ("Config" "[. \t]config([ \t]*\\[ *['\"]\\([^'\"]+\\)" 1)
     ("OnChange" "[ \t]*\$(['\"]\\([^'\"]*\\)['\"]).*\.change *( *" 1)
     ("OnClick" "[ \t]*\$([ \t]*['\"]\\([^'\"]*\\)['\"]).*\.click *( *" 1)
     ("Watch" "[. \t]\$watch( *['\"]\\([^'\"]+\\)" 1)

     ("Class" "^[ \t]*[0-9a-zA-Z_$ ]*[ \t]*class[ \t]*\\([a-zA-Z_$.]*\\)" 1)
     ("Class" "^[ \t]*\\(var\\|let\\|const\\)[ \t]*\\([0-9a-zA-Z_$.]+\\)[ \t]*=[ \t]*[a-zA-Z_$.]*.extend" 2)
     ("Class" "^[ \t]*cc\.\\(.+\\)[ \t]*=[ \t]*cc\..+\.extend" 1)

     ("Function" "\\(async\\)?[ \t]*function[ \t]+\\([a-zA-Z0-9_$.]+\\)[ \t]*(" 2) ;; (async)? function xxx (
     ("Function" "^[ \t]*\\([a-zA-Z0-9_$.]+\\)[ \t]*:[ \t]*\\(async\\)?[ \t]*function[ \t]*(" 1) ;; xxx : (async)? function (
     ("Function" "^[ \t]*\\(export\\)?[ \t]*\\(var\\|let\\|const\\)?[ \t]*\\([a-zA-Z0-9_$.]+\\)[ \t]*=[ \t]*\\(async\\)?[ \t]*function[ \t]*(" 3) ;; (export)? (var|let|const)? xxx = (async)? function (

     ;; {{ es6 beginning
     ("Function" my_imenu:js-exception-imenu-generic-expression-regexp 2) ;; (async)? xxx (e) { }
     ("Function" "^[ \t]*\\([A-Za-z_$][A-Za-z0-9_$.]*\\)[ \t]*:[ \t]*\\(async\\)?[ \t]*(" 1) ;; xxx : (async)? (
     ("Function" "^[ \t]*\\(export\\)?[ \t]*\\(var\\|let\\|const\\)?[ \t]*\\([A-Za-z_$][A-Za-z0-9_$.]*\\)[ \t]*=[ \t]*\\(async\\)?[ \t]*(" 3) ;; (export)? (var|let|const)? xxx = (async)? (
     ("Function" "^[ \t]*\\(export\\)?[ \t]*\\(var\\|let\\|const\\)?[ \t]*\\([A-Za-z_$][A-Za-z0-9_$.]*\\)[ \t]*=[ \t]*\\(async\\)?[ \t]*[A-Za-z_$][A-Za-z0-9_$.]*[ \t]*=>" 3) ;; (export)? (var|let|const)? xxx = (async)? e =>
     ;; }}

     ("Task" "[. \t]task([ \t]*['\"]\\([^'\"]+\\)" 1)))

;; this imenu generic expression aims to exclude for, while, if when aims to match functions in
;; es6 js, e.g. ComponentDidMount(), render() function in React
;; https://emacs-china.org/t/topic/4538/7
(defun my_imenu:js-exception-imenu-generic-expression-regexp ()
  ;; (async)? xxx (e) { }
  (if (re-search-backward "^[ \t]*\\(async\\)?[ \t]*\\([A-Za-z_$][A-Za-z0-9_$]+\\)[ \t]*([a-zA-Z0-9, ]*) *\{ *$" nil t)
      (progn
        (if (member (match-string 2) '("for" "if" "while" "switch"))
            (my_imenu:js-exception-imenu-generic-expression-regexp)
          t))
    nil))


(defun my_imenu:js2-setup-imenu ()
  (setq imenu-create-index-function 'imenu-default-create-index-function)
  (setq imenu-generic-expression my_imenu:js-generic-expression)
  )



;;; http://stackoverflow.com/questions/12703110/what-happened-to-the-ido-imenu-in-ruby-mode-function-in-emacs24
(defvar ruby-imenu-generic-expression
  '(("Methods"  "^\\( *\\(def\\) +.+\\)"          1))
  "The imenu regex to parse an outline of the ruby file")

(defun my_imenu:ruby-setup-imenu ()
;;  (make-local-variable 'imenu-generic-expression) ; already buffer-local on emacs25.2.2
;;  (make-local-variable 'imenu-create-index-function) ; already buffer-local on emacs25.2.2
  (setq imenu-create-index-function 'imenu-default-create-index-function)
  (setq imenu-generic-expression ruby-imenu-generic-expression))



;;00;; ;;;; ref. http://www.emacswiki.org/emacs-fr/ImenuMode
;;00;; (when t ;;;; not tested
;;00;;   (define-derived-mode my_imenu-selection-mode fundamental-mode "imenu"
;;00;;     "Major mode for imenu selection."
;;00;;     (suppress-keymap my_imenu-selection-mode-map)
;;00;;     (define-key my_imenu-selection-mode-map "j" 'next-line)
;;00;;     (define-key my_imenu-selection-mode-map "k" 'previous-line)
;;00;;     (define-key my_imenu-selection-mode-map "l" 'imenu-selection-select)
;;00;;     (define-key my_imenu-selection-mode-map "\C-m" 'imenu-selection-select)
;;00;;     (define-key my_imenu-selection-mode-map "h" 'kill-this-buffer)
;;00;;     )
;;00;;   (defvar my_imenu--selection-buffer " *imenu-select*")
;;00;;   (defvar my_imenu--target-buffer nil)
;;00;;   (declare-function which-function "which-func.el")
;;00;;   (defun my_imenu-make-selection-buffer (&optional index-alist)
;;00;;     (interactive)
;;00;;     (require 'which-func) ; provides which-function
;;00;;     (setq index-alist (if index-alist index-alist (imenu--make-index-alist)))
;;00;;     (let ((cur (which-function)))
;;00;;       (when (listp cur)
;;00;;         (setq cur (car cur)))
;;00;;       (setq my_imenu--target-buffer (current-buffer))
;;00;;       (switch-to-buffer my_imenu--selection-buffer)
;;00;;       (buffer-disable-undo)
;;00;;       (erase-buffer)
;;00;;       (dolist (x index-alist)
;;00;;         (insert (car x) "\n"))
;;00;;       (if cur (search-backward (concat cur "\n") nil t))
;;00;;       (my_imenu-selection-mode)))
;;00;;
;;00;;   (defun my_imenu-selection-select ()
;;00;;     (interactive)
;;00;;     (let ((sel (substring (thing-at-point 'line) 0 -1)))
;;00;;       (bury-buffer)
;;00;;       (switch-to-buffer my_imenu--target-buffer)
;;00;;       (imenu sel)))
;;00;;   );when

(provide 'my_imenu)
;;; my_imenu.el ends here
