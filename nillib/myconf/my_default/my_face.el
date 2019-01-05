;;; package --- Font setting.
;;; Commentary:
;; Conflict with my_frame about font.

;;;; (list-faces-display)

;;; Code:

;;-------------------------------------------------
;; Jananese
;;-------------------------------------------------
;;$;; ;; http://d.hatena.ne.jp/o0cocoron0o/20101006/1286354957
;;$;; ;; 全角スペース、タブの強調表示
;;$;; (defface my-face-b-1 '((t (:background "medium aquamarine"))) nil)
;;$;; ;;(defface my-face-b-2 '((t (:background "medium aquamarine"))) nil)
;;$;; ;;(defface my-face-b-2 '((t (:background "#033344"))) nil) ;
;;$;; ;;(defface my-face-b-2 '((t (:background "#011122"))) nil) ; green
;;$;; ;;(defface my-face-b-2 '((t (:background "#881122"))) nil) ; yellow
;;$;; ;;(defface my-face-b-2 '((t (:background "#FF00FF"))) nil) ; purple
;;$;; (defface my-face-b-2 '((t (:background "#220022"))) nil)
;;$;; (defface my-face-u-1 '((t (:foreground "SteelBlue" :underline t))) nil)
;;$;; (defvar my-face-b-1 'my-face-b-1)
;;$;; (defvar my-face-b-2 'my-face-b-2)
;;$;; (defvar my-face-u-1 'my-face-u-1)
;;$;; (defadvice font-lock-mode (before my-font-lock-mode ())
;;$;;   (font-lock-add-keywords
;;$;;    'major-mode
;;$;;    '(
;;$;;      ("　" 0 my-face-b-1 append)
;;$;; 	("\t" 0 my-face-b-2 append)
;;$;;      ("[ ]+$" 0 my-face-u-1 append)
;;$;;      )
;;$;;    ;; 'makefile-mode
;;$;;    ;; '(
;;$;;    ;; 	("\t" 0 my-face-b-2 append)
;;$;;    ;;   )
;;$;; ))
;;$;; (ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
;;$;; (ad-activate 'font-lock-mode)

(defun font-lock-mode-t () (font-lock-mode t))
(add-hook 'find-file-hooks
          'font-lock-mode-t)
;;          '(lambda ()
;;             (if font-lock-mode nil
;;               (font-lock-mode t))) t)

;;(set-face-foreground 'modeline "light steel blue")	; change modeline color to 'light steel blue'.

(require 'font-lock)
;;  (if  (locate-library "paren") (require 'paren))
(require 'paren)
;;test:paren.el  (setq-default show-paren-style 'expression)                    ; カッコ内の色も変更
(if (window-system)
    (progn ;; window-system
;;;; ------------- white background  -----------------
      ;;	(set-background-color "#cccccc")
      ;;	(set-face-background 'show-paren-match "#fff5ee") ;;  Face inside parenthesis. (light pink)
      ;;    (set-face-foreground 'show-paren-match "#000000")
;;;; ------------- black background  -----------------
      (defvar my_face-background-color  "#111111")
      ;;(set-background-color my_face-background-color)
      (defvar my_face-foreground-color "#00ff00")
      ;;(set-foreground-color my_face-foreground-color)

      (setq default-frame-alist
            (append default-frame-alist
                    `(
                      (background-color . ,my_face-background-color)
                      (foreground-color . ,my_face-foreground-color)
                      (alpha . 83)
                      )))
      (set-face-background 'show-paren-match "#000000")
      (set-face-foreground 'show-paren-match "#00ff00")
      (set-face-underline-p 'show-paren-match "red" nil)
      ;;	(set-face-underline-p 'show-paren-match "#aa1111" nil)
      ;;   (set-face-attribute 'show-paren-match nil :underline "#c5d564") ;; for white background ;; not working on console. bug?
      ;;   (set-face-attribute 'show-paren-match nil :underline "#352a4") ;; for black background
      )
  (progn ;; console
    ;;  (set-face-attribute 'show-paren-match nil :underline t) ;; not working on console. bug?
    (set-face-background 'show-paren-match "#e5f5c4")
    (set-face-foreground 'show-paren-match "#000000")
    )
  )

(when   (locate-library "paren")
  (if (eq 'debug 'debug )
      (progn (message "\tparen:face-foreground:%s"
                      (face-foreground 'show-paren-match))
             (message "\tparen:face-background:%s"
                      (face-background 'show-paren-match))
             (message "\tparen:face-underline-p:%s"
                      (face-underline-p 'show-paren-match))
             (message "\tparen:face-attribute:%s"
                      (face-attribute 'show-paren-match :underline))
             )))

(defun color-at-point ()
  (interactive)
  (read-color "foreground at point/ background at point : " nil nil t )
  )

;;;; http://www.emacswiki.org/emacs/NicFerrier
;;$untested;; (defvar dark-background nil)
;;$untested;;
;;$untested;; (defun toggle-dark-background ()
;;$untested;;   (interactive)
;;$untested;;   (let ((difficult-colors
;;$untested;;          '("red" "blue" "medium blue")))
;;$untested;;     (mapc
;;$untested;;      (lambda (face)
;;$untested;;        (and (member (face-attribute face :foreground)  difficult-colors)
;;$untested;;             (set-face-bold-p face (not dark-background))))
;;$untested;;      (face-list)))
;;$untested;;   (setq dark-background (not dark-background)))
;;$untested;;

;; ref. faces.el  jde-java-font-lock.el
(defun my_face-keyword-lisp-face ()
  "@bug
   @TODO show location with fringe
   @TODO create javadoc keyword face
@bug (downcase ...)
  "
  (interactive)
  (require 'font-lock)
  (let (
        (dev "@\\(FIXME\\|TODO\\|TBD\\|DEV\\|BUG\\)" )
        (ref "@\\(SEE\\|REF.\\)")
        ;;        (ok  "@\\<\\(DONE\\)")
        )
    ;; Highlight additional keywords
    ;; jit-lock-function
    (font-lock-add-keywords nil '(
                                  ;;error ((symbol-value dev) 1 font-lock-warning-face t)
                                  ;;@TBD ((downcase dev) 1 font-lock-warning-face t)
                                  ))
    (font-lock-add-keywords nil '(
                                  ;;@TBD (ref 1 font-lock-doc-face t)
                                  ;;@TBD ((downcase ref) 1 font-lock-doc-face t)
                                  ))
    (font-lock-add-keywords nil '(
                                  ;;                                  (ok 1 font-lock-doc-face t))
                                  ))
    );let
  )

(add-to-list 'emacs-lisp-mode-hook 'my_face-keyword-lisp-face)
(add-hook 'org-mode-hook 'my_face-keyword-lisp-face)


(provide 'my_face)
;;; my_face.el ends here
