;;; http://dev.ariel-networks.com/articles/emacs/part2/
;;; http://blog.iss.ms/2010/08/28/191049
;; anything
;;   ref:「Emacsテクニックバイブル」 pp.302-
;;

;;; Figure out at which point anything is loading tramp.
;;; http://stackoverflow.com/questions/1706157/in-emacs-how-do-i-figure-out-which-package-is-loading-tramp

;;(eval-after-load "tramp"  '(debug))
;; anthing.el and anything-config.el call tramp.
;; (if (not (= 0 (shell-command "type cmigemo" "*Messages*"))) ;;++IfNoMigemo
(if (< max-lisp-eval-depth 5000)
    (setq max-lisp-eval-depth 5000);; avoid 'Variable binding depth exceeds max-specpdl-size'
  )
(if (< max-specpdl-size 6000)
    (setq max-specpdl-size 6000)
  )
;; (if (not (= 0 (shell-command "type cmigemo" ))) ;;++IfNoMigemo
(if (eq system-type "cygwin")
    (progn ;Cygwin
      ;;           (setq current-language-environment "English")
      (require 'anything-startup))
  (setq anything-idle-delay        1.5) ; originally 0.5
  (setq anything-input-idle-delay  0.3) ; originally 0.1

  ;;      (let ((current-language-environment "English"))
  ;;      (message "%s" current-language-environment)
  ;;      )
  (progn
    (require 'my_anything-startup); Mac/linux
    (setq-default migemo-isearch-enable-p nil)
    (setq anything-idle-delay        1.5) ; originally 0.5
    (setq anything-input-idle-delay  0.2) ; originally 0.1
    ) )
;;(setq current-language-environment "Japanese") ;--IfNoMigemo

;;(require 'anything-migemo)
;;(global-set-key (kbd "S-M-SPC") 'anything )
;;(define-key anything-map "\C-@" 'anything-previous-line)
;; http://www.emacswiki.org/cgi-bin/wiki/Anything

;; (setq my-anything-keybind (kbd "C-x b"))
(global-unset-key (kbd "M-c"))
;; (setq my-anything-keybind (kbd "M-c"))
(global-set-key "\M-c" 'my-anything_f )
;; (Defvar my-anything-keybind (kbd "C-c b"))
;; (setq my-anything-keybind (kbd "C-\;"))
;; (global-set-key my-anything-keybind 'anything)
;;(global-set-key my-anything-keybind 'my-anything_f)
;; (define-key anything-map my-anything-keybind 'anything-exit-minibuffer) ;; enabled but unkown
;;(define-key anything-map (kbd "C-M-n") 'anything-next-source)
;;(define-key anything-map (kbd "C-M-p") 'anything-previous-source)
(defun my-anything_f ()
  (interactive)
  (anything-other-buffer
   '(
     ;;     anything-c-source-buffers+
     anything-c-source-recentf
     ;;$;;    anything-c-source-buffers
     ;;     anything-c-source-files-in-current-dir ;; When tramp is activated, this make emacs freeze?
     ;;     anything-c-source-file-name-history  ;; duplicate func ? with anything-c-source-recentf
     ;;anything-c-source-buffer-not-found
     ;;anything-c-source-imenu
     ) " *my-anything*"))

(setq-default anything-candidate-number-limit 30)

;;;;ref. http://www.emacswiki.org/emacs/RubikitchAnythingConfiguration
;;; RubikitchAnythingConfiguration
;; (@* "reset anything.el state")
(eval-when-compile (require 'cl))
(defun anything-reset ()
  "Clear internal state of `anything'."
  (interactive)
  (loop for v in '(anything-candidate-buffer-alist anything-candidate-cache
                                                   anything-current-buffer
                                                   anything-saved-selection anything-saved-action
                                                   anything-buffer-file-name anything-current-position
                                                   anything-last-sources anything-saved-current-source
                                                   anything-compiled-sources)
        do (set v nil))
  (loop for b in (buffer-list)
        for name = (buffer-name b)
        when (string-match "^ ?\\*anything" name)
        do (kill-buffer b)))

;; $ ;; ミニバッファ入力でanythingを使うかどうかは M-x anything-read-string-mode でトグルできるが、これだとすべての入力に対して使うか使わないかのどちらかになる。anythingを使う入力の種類を指定したい場合は次のようにする。
;; $ ;;
;; $ ;; (anything-read-string-mode '(string variable command))

;;$000;; (defun anything-cleanup ()
;;$000;;   "Clean up the mess when anything exit or quit."
;;$000;;   (anything-log "start cleanup")
;;$000;;   (with-current-buffer anything-buffer
;;$000;;     ;; rubikitch: I think it is not needed.
;;$000;;     ;; thierry: If you end up for any reasons (error etc...)
;;$000;;     ;; with an anything-buffer staying around (visible),
;;$000;;     ;; You will have no cursor in this buffer when switching to it,
;;$000;;     ;; so I think this is needed.
;;$000;;     (setq cursor-type t)
;;$000;;     ;; Call burry-buffer whithout arg
;;$000;;     ;; to be sure anything-buffer is removed from window.
;;$000;;     (bury-buffer)
;;$000;;     ;; Be sure we call this from anything-buffer.
;;$000;;     (anything-funcall-foreach 'cleanup))
;;$000;;   (anything-new-timer 'anything-check-minibuffer-input-timer nil)
;;$000;;   (anything-kill-async-processes)
;;$000;;   (anything-log-run-hook 'anything-cleanup-hook)
;;$000;;   (anything-hooks 'cleanup)
;;$000;;   (anything-frame-or-window-configuration 'restore) ;; <- caused error?
;;$000;;   ;; This is needed in some cases where last input
;;$000;;   ;; is yielded infinitely in minibuffer after anything session.
;;$000;;   (anything-clean-up-minibuffer))
;;$000;;
;;$000;;
;;$000;; (defun anything-clean-up-minibuffer ()
;;$000;;   "Remove contents of minibuffer."
;;$000;;   (let ((miniwin (minibuffer-window)))
;;$000;;     ;; Clean only current minibuffer used by anything.
;;$000;;     ;; i.e The precedent one is active.
;;$000;;     (unless (minibuffer-window-active-p miniwin)
;;$000;;       (with-current-buffer (window-buffer miniwin)
;;$000;;         (delete-minibuffer-contents)
;;$000;;         ))))
;;$000;;

(provide 'my_anything)
;;; my_anything ends here
