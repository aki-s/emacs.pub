;;; my_auto-complete.el: --- my_auto-complete
;;; Commentary:
;;; Code:

;;; ref.
;;;  http://d.hatena.ne.jp/rubikitch/20081109/autocomplete
;;; http://cx4a.org/software/auto-complete/manual.html
(eval-and-compile
  (require 'cl) ; For cl-remove-duplicates
  (require 'auto-complete)
  (require 'auto-complete-config))

;;;;-----------
;;;; @dev ; try-out
;;;;-----------
(when (require 'ac-ispell nil t) ; installed from cask
  (custom-set-variables
    '(ac-ispell-requires 4)
    '(ac-ispell-fuzzy-limit 4))

  (eval-after-load "auto-complete"
    '(progn
       (ac-ispell-setup)))

  (add-hook 'git-commit-mode-hook 'ac-ispell-ac-setup)
  (add-hook 'vc-git-log-edit-mode-hook 'ac-ispell-ac-setup)
  (add-hook 'mail-mode-hook 'ac-ispell-ac-setup)
  (add-hook 'emacs-lisp-mode-hook 'ac-ispell-ac-setup)
  )
;;;;-----------
;;;; @dev
;;;;-----------
(defgroup my_auto-complete nil
  "my extension for auto-complete"
  :group 'auto-complete
  :prefix "my_"
  )
(defvar my_ac-user-dict-dir "~/.emacs.d/share/dict")
(defvar my_ac-user-dicts (make-hash-table :test 'equal))
(defvar my_ac-user-dict (concat my_ac-user-dict-dir "/en_US.dic"))

(defface my_ac-spell-face
  ;;'((t (:background "#FF0000" :foreground "#000000" )  ))
  '((t (:background "#111111" :foreground "#440000" )  )) ;for debug
  "Face for spelling"
  :group 'my_auto-complete
  )

(ac-define-source my-dictionary
  `(
     (candidates . my_ac-source-candidates)
     (candidate-face . my_ac-spell-face)
     (prefix . ac-prefix-default)
     (symbol . "D")
     (limit . 6)
     (requires . 6) ; I don't misspell if length is smaller than ...
     ;; Should work on comment area? @see flyspell
     )
  )

(defun my_ac-source-candidates ()
  "ac-dictionary-files is always enabled when it is not intended."
  (let* (
          (filename my_ac-user-dict)
          (cache (gethash filename my_ac-user-dicts 'none)))
    (if (and cache (not (eq cache 'none)))
      cache
      (let (result)
        (ignore-errors
          (with-temp-buffer
            (insert-file-contents filename)
            (setq result (split-string (buffer-string) "\n" t))))
        (puthash filename result my_ac-user-dicts)
        result)))
  )

(defun my_ac-spell-enable()
  (setq ac-sources
    (remove-duplicates (push 'ac-source-my-dictionary ac-sources)))
  )

(defun my_ac-spell-disable()
  (setq ac-sources (delq 'ac-source-my-dictionary ac-sources))
  )

(defun toggle-my_ac-spell()
  (interactive)
  (if (null (member 'ac-source-my-dictionary ac-sources))
    (progn
      (my_ac-spell-enable)
      (message "my_ac-spell-enable done")
      )
    (progn
      (my_ac-spell-disable)
      (message "my_ac-spell-disable done")
      )
    ))

(add-to-list 'ac-dictionary-directories "~/.emacs.d/nillib/ac-dict") ; Cask version also sets this value automatically.
;; (setq ac-user-dictionary-files (concat my_ac-user-dict-dir "/en_US.dic")) ; Can be a list.

;; global-auto-complete-modeが有効になると変数ac-modesに登録されているメジャーモードのみ有効になる
;;$test$;;   (if (>= emacs-major-version 24 )
;;$test$;;       (global-auto-complete-mode 1))
(when (null global-auto-complete-mode )
;;; default configuration
  (ac-config-default);; called (global-auto-complete-mode 1)
  )
(add-to-list 'ac-modes 'web-mode)
(add-to-list 'ac-modes 'org-mode)
(add-to-list 'ac-modes 'ggtags-mode) (add-to-list 'ac-sources 'ac-source-gtags)

;;------------------------------------------------------------------------------
;;;; == C/C++ ==
;;------------------------------------------------------------------------------
(defun my_ac-sources-c ()
  (setq ac-sources (append '(ac-source-semantic) ac-sources)))
(add-hook 'c-mode-common-hook 'my_ac-sources-c)

(require 'auto-complete-c-headers)


(defun ac-cc-mode-clang-setup ()
  ;;debug  (message " * calling ac-cc-mode-clang-setup")
  (case (executable-find "clang-complete")
    ('nil (message "No command named 'clang-complete found."))
    (t
      (setq ac-clang-cflags
        (mapcar (lambda (item)(concat "-I" item))
          (split-string
            "
       /usr/include/c++/4.7
       /usr/include/c++/4.7/x86_64-linux-gnu
       /usr/include/c++/4.7/backward
       /usr/lib/gcc/x86_64-linux-gnu/4.7/include
       /usr/lib/gcc/x86_64-linux-gnu/4.7/include-fixed
       /usr/include/x86_64-linux-gnu
       /usr/include
       /usr/local/include
           "
            )))
      (setq ac-clang-flags ac-clang-cflags)
      ;; (setq ac-sources (append '(ac-source-clang-async ac-source-yasnippet) ac-sources))
      ;; (setq ac-sources '(ac-source-clang-async))
      (setq ac-sources (remove-duplicates (push 'ac-source-clang-async ac-sources)))
      ;;(message "DEBUG: call auto-complete-clang-async begin")
      (require 'auto-complete-clang-async)
      ;;(message "DEBUG: call auto-complete-clang-async end")
      ;;  -preprocessed
      ;;  (ac-clang-launch-completion-process)  ;error when opening file?
      ;;  (ac-clang-update-cmdlineargs) ;error when opening file?
      )
    )
  )

(defun ac-cc-mode-clang-config ()
  (message " * calling ac-cc-mode-clang-config")
  (add-hook 'c-mode-hook 'ac-cc-mode-clang-setup)
  (add-hook 'c++-mode-hook 'ac-cc-mode-clang-setup)
  (add-hook 'auto-complete-mode-hook 'ac-common-setup))

(ac-cc-mode-clang-config)


(add-to-list 'ac-sources 'ac-source-c-headers)

;;------------------------------------------------------------------------------
;;;; == PERL ==
;;------------------------------------------------------------------------------
;;; http://blog.iss.ms/2010/08/28/191049
;;(require 'auto-complete-config)
;;(add-to-list 'ac-dictionary-directories "~/.emacs.d/site-lisp/ac/ac-dict")

;; (add-hook 'cperl-mode-hook
;;           '(lambda ()
;;              (progn
;;                (setq indent-tabs-mode nil)
;;                (setq tab-width nil)
;;
;;                ; perl-completion
;;                (require 'auto-complete)
;;                (require 'perl-completion)
;;                (add-to-list 'ac-sources 'ac-source-perl-completion)
;;                (perl-completion-mode t)
;;               )))
;;
;;------------------------------------------------------------------------------

;; interactively call auto-complete-mode
;;(define-key ac-mode-map (kbd "M-TAB") 'auto-complete)

;;;;If autoComplete stops working as soon as I enable Flymake.
;;;;  coexist with flyspell
;;(ac-flyspell-workaround)

                                        ;(if ((eq system-type 'darwin))
;;$;;(if (eq system-type 'darwin)
;;$;;    (setq ac-auto-start 2)
;;$;;  (setq ac-auto-start 4))
;; ref. official. http://cx4a.org/software/auto-complete/manual.ja.html#ac-source-filename
;;
;;(ac-config-default) ;; initialize ac-sources. auto-complete-default-hooks
;;;
(defun my_ac-sources-sans-directory ()
  "For slow CPU, prevent directory completion"
  (interactive)
  (setq-default ac-sources
    '(
       ac-source-words-in-same-mode-buffers
       ac-source-functions
       ac-source-yasnippet
       ac-source-variables
       ac-source-abbrev
       ac-source-dictionary
       )))
;;;
(defun my_ac-sources-elisp ()
  (setq ac-sources
    '(
       ac-source-words-in-same-mode-buffers
       ac-source-features
       ac-source-symbols
       )))
(add-hook 'emacs-lisp-mode-hook  'my_ac-sources-elisp)

(cond
  ((eq system-type 'cygwin)
    (progn (my_ac-sources-sans-directory)
      (message "\tac-sources-sans-directory()")
      )
    )
  (t
    (add-to-list 'ac-sources 'ac-source-filename)
    (add-to-list 'ac-sources 'ac-source-files-in-current-dir)
    )
  )

(require 'my_global-vars)
(setq
  ac-comphist-file
  (expand-file-name
    (concat my_global-vars--user-emacs-tmp-dir
      "/ac-comphist.dat"))
  )


;;;; TBD: enable on specific mode
;; ac common settings
;;(custom-set-variables
(setq
 ;;;; defcustom from auto-complete.el
 ;;;  comment out means default value.
  ;;$ '(ac-delay 0.1)
  ;; ac-delay 0.8
  ac-delay 0.05 ;; without menu, show one complete
  ;;$ '(ac-auto-show-menu 0.8)
  ac-auto-show-menu 0.2 ;; show menu
  ;;$ '(ac-show-menu-immediately-on-auto-complete t)
  ;;$ '(ac-expand-on-auto-complete t)
  ;;$ '(ac-disable-faces '(font-lock-comment-face font-lock-string-face font-lock-doc-face))
  ;;$ '(ac-stop-flymake-on-completing t)
  ;;$ '(ac-use-fuzzy (and (locate-library "fuzzy") t))
  ;;$ '(ac-fuzzy-cursor-color "red")
  ;;$ '(ac-use-comphist t)
  ;;$ '(ac-comphist-threshold 0.7)
  ;;$ '(ac-comphist-file)
  ;;$ '(ac-user-dictionary nil)
  ;;$ '(ac-dictionary-files '("~/.dict"))
  ;;$ '(ac-dictionary-directories)
  ;;$ '(ac-use-quick-help t)
  ;;$ '(ac-quick-help-delay 1.5)
  ac-quick-help-delay 1.5  ;; show document about var/func
  ac-menu-height 10
  ac-quick-help-height 10
  ;;$ '(ac-quick-help-prefer-pos-tip t)
  ;;$ '(ac-candidate-limit nil)
  ;;$ '(ac-modes)
  ;;$ '(ac-compatible-packages-regexp)
  ;;$ '(ac-non-trigger-commands)
  ;;$ '(ac-trigger-commands)
  ;;$ '(ac-trigger-commands-on-completing)
  ;;$ '(ac-trigger-key nil)
  ;;error ac-trigger-key (kbd "C-S-p")
  ;;$ '(ac-auto-start 2)
  ;;ac-auto-start 10
  ;;$ '(ac-stop-words nil)
  ac-use-dictionary-as-stop-words nil ; for tern-completion
  ;;$ '(ac-ignore-case 'smart)
  ;;$ '(ac-dwim t)
  ;;$ '(ac-use-menu-map nil)
  ac-use-menu-map t
  ;;$ '(ac-use-overriding-local-map nil)
  ;;$ '(ac-disable-inline nil)
  ;;$ '(ac-candidate-menu-min 1)
  ;;$ '(ac-max-width nil)
  )

(defvar my_auto-complete-auto nil "Flag for auto complete show on/off")
(defun toggle-auto-complete-auto ()
  (interactive)
  (if my_auto-complete-auto
    (progn
      (setq
        ac-auto-show-menu t
        ac-auto-start nil
        ac-delay 0.4
        ac-quick-help-delay 1.5
        )
      (message "auto-complete auto show off")
      )
    (progn
      (setq
        ac-delay 0.1
        ac-quick-help-delay 0.8
        )
      (message "auto-complete auto show on")
      )
    ))
;;(define-key ac-mode-map (kbd "\C-S-p") 'ac-quick-help)

(global-set-key (kbd "C-S-p") 'ac-start) ;; pop auto-complete menu

;;; Filter out sources by type of `symbol'.
(define-key ac-completing-map (kbd "F") '(lambda () (interactive) (auto-complete (list ac-source-functions))))
(define-key ac-completing-map (kbd "V") '(lambda () (interactive) (auto-complete (list ac-source-variables))))
(define-key ac-completing-map (kbd "D") '(lambda () (interactive) (auto-complete (list ac-source-dictionary))))

(provide 'my_auto-complete)
;;; my_auto-complete.el ends here
