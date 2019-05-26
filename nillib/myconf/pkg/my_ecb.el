;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ECB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun non-ecb-window-list ()
  (interactive)
  (remove-if
   #'(lambda (window)
       (find (window-buffer window) (ecb-dedicated-special-buffers)))
   (window-list)))
;;  ecb-get-current-visible-ecb-buffers

(defun count-non-ecb-windows ()
  (interactive)
  "ignore ecb-window and mini-buffer"
  (length (non-ecb-window-list)))

;;;;--------------------------------------------------
;;;; debug
;;;;--------------------------------------------------

  ;;; Don't know details but completing-read show completion in minibuffer.

  ;;; Related functions
;; display-buffer
;; minibuffer.el
;; completion--in-region-1
;; minibuffer-scroll-window ; <- showed in minibuffer...

;; [Solution]
(add-to-list 'special-display-buffer-names '("*Completions*" my-display-completions))

(defun my-display-completions (buf)
  "put the *completions* buffer in the right spot
@TODO
- Consider dedicated windows.
"
  (let ((windows (delete (minibuffer-window) (non-ecb-window-list)))
        (pop-up-windows t)
        )
    (if (eq 1 (length windows))
        (progn
          (select-window (car windows))
          (split-window-vertically)))
    (let* ((windows (delete (minibuffer-window) (non-ecb-window-list)))
           (target-window (car windows))
           )
      (set-window-buffer target-window buf)
      target-window)))

;;(debug-on-entry 'ecb-buffer-obj)
;; (debug-on-entry 'assoc)
(defadvice ecb-buffer-obj (after ecb-buffer-obj-debug last activate)
  "@dev"
  ;;  (switc
  ;; (message "ecb-buffer-obj is called :%s\n" (ad-get-arg 0))
  )

(defvar toggle-my_ecb-debug nil "flag for debug mode on/off")
(defun toggle-my_ecb-debug ()
  "@dev"
  (interactive)
  (if toggle-my_ecb-debug
      (progn
        (setq
         toggle-my_ecb-debug  nil
         )
        )
    (progn
      (require 'tree-buffer)
      (setq
       tree-buffer-debug-mode t  ; tree-buffer.el
       toggle-my_ecb-debug  t
       )
      ;; (tree-buffer-select 0 nil)
      )
    )
  )

;;;;--------------------------------------------------
;;;; main
;;;;--------------------------------------------------


(require 'ecb nil t)

;;;###autoload
(defun my_ecb ()
  (interactive)
  "Customize and activate ecb."
    ;;;; tree-buffer.el
  ;;;; ecb.el
  (setq ecb-activation-selects-ecb-frame-if-already-active t)
  (progn
    (setq ecb-tree-buffer-style 'ascii-guides)
    (setq-default ecb-tree-indent 1)
    ;;(setq-default ecb-tree-expand-symbol-before 1)
    ;;      (setq-default ecb-tree-expand-symbol-before t) ; not overwritten on emacs23?
    ;;; my_ecb.el ---
    )
    ;;;; ecb-method-browser.el
  ;; ecb-show-tags, ecb-add-tags
  (progn
    ;; Default?: Show method in the sequence they are defined. <-> alphabetical order.

    ;;; func
    ;; ecb-ecb-buffer-registry-name-list
      ;;; vars
    ;; ecb-ecb-buffer-registry

    ;;
    ;; (setq ecb-highlight-tag-with-point-delay 1.2)
    ;;$00;; (setq
    ;;$;; '(ecb-auto-expand-tag-tree-collapse-other 'only-if-on-tag)
    (setq ecb-auto-expand-tag-tree-collapse-other nil)
    ;; (setq ecb-use-speedbar-instead-native-tree-buffer t) ;; not overwritten for emacs23?
    ;;      (setq ecb-use-speedbar-instead-native-tree-buffer nil) ;; not overwritten for emacs23?
    (setq ecb-options-version "2.40")
    (setq ecb-windows-width 40)
    ;; only-if-on-tag, always, nil
    ;;$00;;)

    ;;$00;; (custom-set-faces
    ;;$01;; (setq ecb-default-highlight-face '((t (:background "#000066"))))
    ;;$01;;      (setq ecb-tag-header-face '((t (:background "#660000"))))
    ;; (setq ecb-show-tags )

    )
  ;;$00;)
    ;;;; create tag for perl/shell
  ;; ecb-show-tags

  ;; (setq-default ecb-basic-buffer-sync nil); ecb-window-sync is '\C-c . s by default.
  (push 'fundamental-mode ecb-basic-buffer-sync)
  (push 'help-mode ecb-basic-buffer-sync)
  (setq-default ecb-source-file-regexps
                '((".*"
                   ("\\(^\\(\\.\\|#\\)\\|\\(~$\\|\\.\\(elc\\|obj\\|o\\|class\\|lib\\|dll\\|a\\|so\\|cache\\)$\\)\\)")
                   ("C\\:.*")
                   )))
  (setq-default ecb-create-layout-file "~/.emacs.d/share/.ecb-user-layouts.el")
  (setq ecb-tip-of-the-day nil)
  ;; (setq-default ecb-tip-of-the-day t)
  ;;$;; (setq-default ecb-windows-width 40)

  ;;    (require 'sr-speedbar)
  ;;    (setq sr-speedbar-right-side nil)

  ;; speedbar-frame-parameters's value is
  ;; ( (minibuffer)
  ;;  (width . 20)
  ;;  (border-width . 0)
  ;;  (menu-bar-lines . 0)
  ;;  (tool-bar-lines . 0)
  ;;  (unsplittable . t)
  ;;  (left-fringe . 0) )
  ;;

  (ecb-activate)
  (my_ecb_select-layout)
  ) ; my_ecb

;; (when window-system
;;  (speedbar t))
(defun my_ecb-set-ecb-windows-width ()
  ;;(setq-default ecb-windows-width 40)
  "TBD:"
  (interactive)
  (window-height
   (ecb-windows-width)
   (window-text-height)
   )
  )

;; (setq ecb-layout-name "top2");; top1: (dir,file,method), top2: (method)
(defun my_ecb-set-layout-ifp (name)
  "Avoid activation failure if selected layout does not defined."
  (if (member name (mapcar 'car ecb-available-layouts))
      (setq-default ecb-layout-name name)
    nil)
  )

(defun my_ecb-preferred-layout ()
  (setq ecb-layout-name "left-symboldef")
  (ecb-maximize-window-methods)
  )

(defun my_ecb_select-layout ()
  (when (stringp buffer-file-name)
       ;;; I should use function 'member' ?
    (cond
     ;;( (string-match "\\.el\\'" buffer-file-name) (progn (my_ecb-set-layout-ifp "emacs-lisp-rightDef") (ecb-maximize-window-methods)))
     ( (string-match "\\.el\\'" buffer-file-name) (progn (my_ecb-set-layout-ifp "emacs-lisp-rightDef") ))
     ( (string-match "\\.cpp\\'" buffer-file-name) (or (my_ecb-set-layout-ifp "leftright-add")(my_ecb-preferred-layout) ) )
     (t (prog1 (my_ecb-preferred-layout) ))
     ))
  (message "my_ecb_select-layout was called")
  )

;;
;;; (defface my_ecb-tag-header-face (ecb-face-default nil nil nil nil
;;;                                                   nil "SeaGreen1"
;;; nil nil t)
;;; ""
;;; :group 'ecb-faces
;;; )
;;
(defun toggle-ecb-window-sync ()
  (interactive)
  (if (boundp 'ecb-basic-buffer-sync)
      (progn
        (setq ecb-basic-buffer-sync nil); ecb-window-sync is '\C-c . s by default.
        (message "ecb-basic-buffer-sync is off")
        )
    (progn
      (setq ecb-basic-buffer-sync t); ecb-window-sync is '\C-c . s by default.
      (message "ecb-basic-buffer-sync is on")
      )
    ))

;;;###autoload
(defun my_ecb-toggle ()
  (interactive)
  (if ecb-minor-mode
      (ecb-deactivate)
    (ecb-activate)))
(define-key global-map [f2 f2] 'my_ecb-toggle)

(cond ((eq system-type 'darwin)
       '(ecb-source-path (quote (
                                 ("/" "/")
                                 ((concat (getenv "HOME") "/Documents/programming") "MyProg")))))
      ((eq system-type 'gnu/linux)
       '(ecb-source-path (quote (
                                 ("~" "HOME")))))
      )


(if (and (<= 24 emacs-major-version) (>= 3 emacs-minor-version))
    (progn
      ;;http://stackoverflow.com/questions/9877180/emacs-ecb-alternative
      (setq stack-trace-on-error t) ;; run ecb-activate with no error
      ;; (setq ecb-use-speedbar-instead-native-tree-buffer t)
      )
  )

(unless (string= window-system nil)
  ;;(require 'ecb-multiframe) ;; Just setting 'ecb-new-ecb-frame is enough?
                                        ;(load-library "ecb-multiframe")
;;;; @TBD create multi ecb-frame
  ;; ecb.el:1211 ecb-activate--impl
  ;; ecb-frame
  ;; (setq ecb-new-ecb-frame nil)
  ;; ecb-frame-parameter
  )

(defvar my_ecb-update-ecb-frame-regex nil)
(setq my_ecb-update-ecb-frame-regex "\\(^[ ]+\\)")
(defun my_ecb-update-ecb-frame()
  ;;; ref.
  ;; title-bar or mode-bar change hook should work
  ;; ecb-analyse-buffer-sync-hook
  ;; (edebug-on-entry ecb-analyse-buffer-sync) ;; ecb-analyse.el l.294
  ;; (edebug-on-entry ecb-update-methods-buffer--internal ) ;;need to edebug-defun ecb-update-methods-buffer--internal from ecb-method-browser.el beforehand
  ;; pre-command-hook post-command-hook
  ;; ecb-common-browser.el l.1503 (defmacro defecb-autocontrol/sync-function (fcn buffer-name-symbol
  ;; ecb-method-browser.el
  ;; ecb-set-selected-source
  "
@bug: '(wrong-number-of-arguments stringp nil)
@TBD: I'd like to run this func,if non ecb buffer is selected.
 Currently using window-configuration-change-hook to enable this feature.
  I should mimic the way method tree automatically change if buffer selected is changed.
ecb-update-methods-buffer--internal is called when updating

"
  ;;!!!!!!!! seems idle-timer is used.
  ;; ecb-idle-timer-alist
  ;; ecb-common-browser.el::ecb-run-with-idle-timer
  ;; ecb-autocontrol/sync-fcn-register
  ;; ref. timer-idle-list timer-activate-when-idle
  (if (and (not (minibufferp)) (boundp 'ecb-basic-buffer-sync))
      (if (or (null ecb-frame) (frame-live-p ecb-frame)) ;; ecb-frame exists
          (progn
            (let* (
                   (buf-name (buffer-file-name (window-buffer (selected-window))))
                   )
              (if (string-match  my_ecb-update-ecb-frame-regex buf-name)
                  (setq ecb-frame (selected-frame))
                )
              )
            );progn
        (progn
          (setq ecb-frame nil) ; ecb-frame is dead
          )
        );if
    (unless (null toggle-my_ecb-debug )
      (message "%s: ecb-frame is %s" this-command ecb-frame)
      ))
  )

;; (add-hook 'window-configuration-change-hook 'my_ecb-update-ecb-frame) ;; not proper solution.
;; (add-hook 'kill-buffer-hook 'my_ecb-update-ecb-frame)
;;(add-hook 'ecb-basic-buffer-sync-hook 'my_ecb-update-ecb-frame)
(defun my_ecb-activate-hook()
  (my_ecb_select-layout)
  (add-hook 'pre-command-hook 'my_ecb-update-ecb-frame)
  )
(add-hook 'ecb-activate-hook 'my_ecb-activate-hook)

(defun my_ecb-deactivate-hook ()
  ""
  (setq
   ecb-frame nil
   ecb-last-window-config-before-deactivation nil
   )
  (remove-hook 'pre-command-hook 'my_ecb-update-ecb-frame)
  )

(add-hook 'ecb-deactivate-hook 'my_ecb-deactivate-hook)

(defun ecb-activate--impl ()
  "Overwrited version by my_ecb to create pseudo ecb-frame for each frame "
  (when (or (null ecb-frame) (not (frame-live-p ecb-frame)))
    (setq ecb-frame (selected-frame)))

  (unless (and ecb-minor-mode (ecb-buffer-obj (selected-frame)))

    (let ((debug-on-error debug-on-error))
      ;; we activate only if all before-hooks return non nil
      (when (run-hook-with-args-until-failure 'ecb-before-activate-hook)

        ;; temporary changing some emacs-vars
        (when (< max-specpdl-size 3000)
          (ecb-modify-emacs-variable 'max-specpdl-size 'store 3000))
        (when (< max-lisp-eval-depth 1000)
          (ecb-modify-emacs-variable 'max-lisp-eval-depth 'store 1000))
        (when (and ecb-running-xemacs
                   (boundp 'progress-feedback-use-echo-area))
          (ecb-modify-emacs-variable 'progress-feedback-use-echo-area 'store t))

        ;; checking if there are cedet or semantic-load problems
        (ecb-check-cedet-load)
        (ecb-check-semantic-load)

        ;; checking the requirements
        (ecb-check-requirements)

        (condition-case err-obj
            (progn

              ;; initialize the navigate-library
              (ecb-nav-initialize)

              ;; enable basic advices (we need the custom-save-all advice
              ;; already here! Maybe it would be better to remove this advice
              ;; from the basic-advices and add it to upgrade-advices.....)
              ;;(ecb-enable-advices 'ecb-layout-basic-adviced-functions)

              ;; we need the custom-all advice here!
              (ecb-enable-advices 'ecb-methods-browser-advices)

              ;; maybe we must upgrade some not anymore compatible or even renamed
              ;; options
              (when (and ecb-auto-compatibility-check
                         (not ecb-upgrade-check-done))
                (ecb-check-not-compatible-options)
                (ecb-upgrade-not-compatible-options)
                (ecb-upgrade-renamed-options)
                (setq ecb-upgrade-check-done t))

              ;; first initialize the whole layout-engine
              (ecb-initialize-layout)

              ;; initialize internals
              (ecb-initialize-all-internals (not ecb-clear-caches-before-activate))

              ;; enable permanent advices - these advices will never being
              ;; deactivated after first activation of ECB unless
              ;; `ecb-split-edit-window-after-start' is not 'before-activation
              ;; (see `ecb-deactivate-internal')
              (ecb-enable-advices 'ecb-permanent-adviced-layout-functions)

              ;; enable advices for not supported window-managers
              (ecb-enable-advices 'ecb-winman-not-supported-function-advices)

              ;; enable advices for the compatibility with other packages
              (ecb-enable-advices 'ecb-compatibility-advices)

              ;; set the ecb-frame
              (let ((old-ecb-frame ecb-frame))
                (if ecb-new-ecb-frame
                    (progn
                      (run-hooks 'ecb-activate-before-new-frame-created-hook)
                      (setq ecb-frame (make-frame))
                      (put 'ecb-frame 'ecb-new-frame-created t))
                  (setq ecb-frame (selected-frame))
                  (put 'ecb-frame 'ecb-new-frame-created nil))
                ;; If ECB is acivated in a frame unequal to that frame which was
                ;; the ecb-frame at last deactivation then we initialize the
                ;; `ecb-edit-area-creators'.
                (if (not (equal ecb-frame old-ecb-frame))
                    (ecb-edit-area-creators-init)))
              (raise-frame ecb-frame)
              (select-frame ecb-frame)

              (ecb-enable-own-temp-buffer-show-function t)

              ;; now we can activate ECB

              ;; first we run all tree-buffer-creators
              (ecb-tree-buffer-creators-run)

              ;; activate the eshell-integration - does not load eshell but
              ;; prepares ECB to run eshell right - if loaded and activated
              (ecb-eshell-activate-integration)

              ;; we need some hooks
              (add-hook (ecb--semantic-after-partial-cache-change-hook)
                        'ecb-update-after-partial-reparse t)
              (add-hook (ecb--semantic-after-toplevel-cache-change-hook)
                        'ecb-rebuild-methods-buffer-with-tagcache t)
              ;;               (add-hook (ecb--semantic--before-fetch-tags-hook)
              ;;                         'ecb-prevent-from-parsing-if-exceeding-threshold)
              (ecb-activate-ecb-autocontrol-function ecb-highlight-tag-with-point-delay
                                                     'ecb-tag-sync)
              (ecb-activate-ecb-autocontrol-function ecb-basic-buffer-sync-delay
                                                     'ecb-basic-buffer-sync)
              (ecb-activate-ecb-autocontrol-function ecb-compilation-update-idle-time
                                                     'ecb-compilation-buffer-list-changed-p)
              (ecb-activate-ecb-autocontrol-function 'post
                                                     'ecb-layout-post-command-hook)
              (ecb-activate-ecb-autocontrol-function 'pre
                                                     'ecb-layout-pre-command-hook)
              (ecb-activate-ecb-autocontrol-function 0.5
                                                     'ecb-repair-only-ecb-window-layout)
              (ecb-activate-ecb-autocontrol-function 'post
                                                     'ecb-handle-major-mode-visibilty)
              (add-hook 'after-save-hook 'ecb-update-methods-after-saving)
              (add-hook 'kill-buffer-hook 'ecb-kill-buffer-hook)

              (add-hook 'find-file-hooks 'ecb-find-file-hook)

              ;; after adding all idle-timers and post- and pre-command-hooks we
              ;; activate the monitoring
              (ecb-activate-ecb-autocontrol-function 1 'ecb-monitor-autocontrol-functions)

              ;; We activate the stealthy update mechanism
              (ecb-stealthy-function-state-init)
              (ecb-activate-ecb-autocontrol-function ecb-stealthy-tasks-delay
                                                     'ecb-stealthy-updates)

              ;; running the compilation-buffer update first time
              (ecb-compilation-buffer-list-init)

              ;; ediff-stuff; we operate here only with symbols to avoid bytecompiler
              ;; warnings
              (ecb-activate-ediff-compatibility)

              ;; enabling the VC-support
              (ecb-vc-enable-internals 1)

              (add-hook (if ecb-running-xemacs
                            'activate-menubar-hook
                          'menu-bar-update-hook)
                        'ecb-compilation-update-menu)
              )
          (error
           ;;          (backtrace)
           (ecb-clean-up-after-activation-failure
            "Errors during the basic setup of ECB." err-obj)))

        (condition-case err-obj
            ;; run personal hooks before drawing the layout
            (run-hooks 'ecb-activate-before-layout-draw-hook)
          (error
           (ecb-clean-up-after-activation-failure
            "Errors during the hooks of ecb-activate-before-layout-draw-hook."
            err-obj)))

        (setq ecb-minor-mode t)

        ;; now we draw the screen-layout of ECB.
        (condition-case err-obj
            ;; now we draw the layout chosen in `ecb-layout'. This function
            ;; activates at its end also the adviced functions if necessary!
            ;; Here the directories- and history-buffer will be updated.
            (let ((ecb-redraw-layout-quickly nil)
                  (use-last-win-conf (and ecb-last-window-config-before-deactivation
                                          (equal ecb-split-edit-window-after-start
                                                 'before-deactivation)
                                          (not (ecb-window-configuration-invalidp
                                                ecb-last-window-config-before-deactivation)))))
              (ecb-enable-temp-buffer-shrink-to-fit ecb-compile-window-height)
              (if use-last-win-conf
                  (setq ecb-edit-area-creators
                        (nth 4 ecb-last-window-config-before-deactivation)))

              (ecb-redraw-layout-full 'no-buffer-sync
                                      nil
                                      (and use-last-win-conf
                                           (nth 6 ecb-last-window-config-before-deactivation))
                                      (and use-last-win-conf
                                           (nth 5 ecb-last-window-config-before-deactivation)))

              ;; if there was no compile-window before deactivation then we have
              ;; to hide the compile-window after activation
              (if (and use-last-win-conf
                       (null (nth 2 ecb-last-window-config-before-deactivation)))
                  (ecb-toggle-compile-window -1))

              (when (member ecb-split-edit-window-after-start
                            '(vertical horizontal nil))
                (delete-other-windows)
                (case ecb-split-edit-window-after-start
                  (horizontal (split-window-horizontally))
                  (vertical (split-window-vertically))))

              ;; now we synchronize all ECB-windows
              (ecb-window-sync)

              ;; now update all the ECB-buffer-modelines
              (ecb-mode-line-format) ;; @dev error arise here ?
              ;;(defun ecb-mode-line-make-modeline-str (str face) ; l.267 ecb-mode-line
              )
          (error
           (ecb-clean-up-after-activation-failure
            "Errors during the layout setup of ECB." err-obj)
           (setq  ecb-last-window-config-before-deactivation nil)
           )
          )

        (condition-case err-obj
            (let ((edit-window (car (ecb-canonical-edit-windows-list))))
              (when (and ecb-display-default-dir-after-start
                         (null (ecb-buffer-file-name
                                (window-buffer edit-window))))
                (ecb-set-selected-directory
                 (ecb-fix-filename (with-current-buffer (window-buffer edit-window)
                                     default-directory)))))
          (error
           (ecb-clean-up-after-activation-failure
            "Errors during setting the default directory." err-obj)))

        (condition-case err-obj
            ;; we run any personal hooks
            (run-hooks 'ecb-activate-hook)
          (error
           (ecb-clean-up-after-activation-failure
            "Errors during the hooks of ecb-activate-hook." err-obj)))

        (condition-case err-obj
            ;; enable mouse-tracking for the ecb-tree-buffers; we do this after
            ;; running the personal hooks because if a user putｴs activation of
            ;; follow-mouse.el (`turn-on-follow-mouse') in the
            ;; `ecb-activate-hook' then our own ECB mouse-tracking must be
            ;; activated later. If `turn-on-follow-mouse' would be activated
            ;; after our own follow-mouse stuff, it would overwrite our
            ;; mechanism and the show-node-name stuff would not work!
            (if (ecb-show-any-node-info-by-mouse-moving-p)
                (tree-buffer-activate-follow-mouse))
          (error
           (ecb-clean-up-after-activation-failure
            "Errors during the mouse-tracking activation." err-obj)))

        (setq ecb-minor-mode t)
        (message "The ECB is now activated.")

        (condition-case err-obj
            ;; now we display all `ecb-not-compatible-options' and
            ;; `ecb-renamed-options'
            (if (and ecb-auto-compatibility-check
                     (or (ecb-not-compatible-or-renamed-options-detected)
                         (not (ecb-options-version=ecb-version-p))))
                ;; we must run this with an idle-times because otherwise these
                ;; options are never displayed when Emacs is started with a
                ;; file-argument and ECB is automatically activated. I this
                ;; case the buffer of the file-argument would be displayed
                ;; after the option-display and would so hide this buffer.
                (ecb-run-with-idle-timer 0.25 nil 'ecb-display-upgraded-options)
              (ecb-display-news-for-upgrade))
          (error
           (ecb-clean-up-after-activation-failure
            "Error during the compatibility-check of ECB." err-obj)))

        ;; if we activate ECB first time then we display the node "First steps" of
        ;; the online-manual
        (ignore-errors
          (when (null ecb-source-path)
            (let ((ecb-show-help-format 'info))
              (ecb-show-help)
              (Info-goto-node "First steps"))))

        ;; display tip of the day if `ecb-tip-of-the-day' is not nil
        (ignore-errors
          (ecb-show-tip-of-the-day))

        (ecb-enable-advices 'ecb-layout-basic-adviced-functions)

        (condition-case err-obj
            ;;now take a snapshot of the current window configuration
            (setq ecb-activated-window-configuration
                  (ecb-current-window-configuration))
          (error
           (ecb-clean-up-after-activation-failure
            "Errors during the snapshot of the windows-configuration." err-obj)))
        ))))

;; (add-hook 'before-make-frame-hook 'my_ecb-make-frame-hook)

(defun my_ecb-make-frame-hook ()
  ;;  (setq ecb-windows-all-hidden t)
  )

;; (defun ecb-toggle-ecb-windows (&optional arg)
;;   "Toggle visibility of the ECB-windows.
;; With prefix argument ARG, make visible if positive, otherwise invisible.
;; This has nothing to do with \(de)activating ECB but only affects the
;; visibility of the ECB windows. ECB minor mode remains active!"
;;   (interactive "P")
;;   (unless (or (not ecb-minor-mode)
;;               (not (equal (selected-frame) ecb-frame)))
;;     (let ((new-state (if (null arg)
;;                          (not (ecb-windows-all-hidden))
;;                        (<= (prefix-numeric-value arg) 0))))
;; ;; Show ECB frame
;;       (if (not new-state)
;;           (progn
;;             (run-hooks 'ecb-show-ecb-windows-before-hook)
;;             (if (ecb-show-any-node-info-by-mouse-moving-p)
;;                 (tree-buffer-activate-follow-mouse))
;;             ;; if `ecb-buffer-is-maximized-p' is not nil then this means we
;;             ;; should only restore this one maximized buffer!
;;             (let ((compwin-hidden (equal 'hidden
;;                                          (ecb-compile-window-state))))
;;               (if (ecb-buffer-is-maximized-p)
;;                    (ecb-maximize-ecb-buffer (ecb-maximized-ecb-buffer-name))
;;                 (ecb-redraw-layout-full))
;;               (if compwin-hidden
;;                   (ecb-toggle-compile-window -1)))
;;             (run-hooks 'ecb-show-ecb-windows-after-hook)
;;             (message "ECB windows are now visible."))
;; ;; Hide ECB frame
;;         (unless (ecb-windows-all-hidden)
;;           (run-hooks 'ecb-hide-ecb-windows-before-hook)
;;           (tree-buffer-deactivate-follow-mouse)
;;           (let ((compwin-hidden (equal 'hidden
;;                                        (ecb-compile-window-state))))
;;             (ecb-redraw-layout-full nil nil nil ecb-windows-hidden-all-value)
;;             (if compwin-hidden
;;                 (ecb-toggle-compile-window -1)))
;;           (run-hooks 'ecb-hide-ecb-windows-after-hook)
;;           (message "ECB windows are now hidden."))))))




;;$TODO$;; (defun ecb-deactivate-internal (&optional run-no-hooks)
;;$TODO$;;   "Deactivates the ECB and kills all ECB buffers and windows."
;;$TODO$;;   (unless (not ecb-minor-mode)
;;$TODO$;;
;;$TODO$;;     (when (or run-no-hooks
;;$TODO$;;               (run-hook-with-args-until-failure 'ecb-before-deactivate-hook))
;;$TODO$;;
;;$TODO$;;       (setq ecb-last-window-config-before-deactivation
;;$TODO$;;             (ecb-current-window-configuration))
;;$TODO$;;
;;$TODO$;;       ;; deactivating the adviced functions
;;$TODO$;;       (dolist (adviced-set-elem ecb-adviced-function-sets)
;;$TODO$;;         ;; Note: as permanent defined advices-sets are not disabled here!
;;$TODO$;;         (ecb-disable-advices (car adviced-set-elem)))
;;$TODO$;;
;;$TODO$;;       (ecb-enable-own-temp-buffer-show-function nil)
;;$TODO$;;
;;$TODO$;;       (ecb-enable-temp-buffer-shrink-to-fit nil)
;;$TODO$;;
;;$TODO$;;       ;; deactivate and reset the speedbar stuff
;;$TODO$;;       (ignore-errors (ecb-speedbar-deactivate))
;;$TODO$;;
;;$TODO$;;       ;; deactivates the eshell-integration; this disables also the
;;$TODO$;;       ;; eshell-advices!
;;$TODO$;;       (ecb-eshell-deactivate-integration)
;;$TODO$;;
;;$TODO$;;       ;; For XEmacs
;;$TODO$;;       (tree-buffer-activate-follow-mouse)
;;$TODO$;;       (tree-buffer-deactivate-follow-mouse)
;;$TODO$;;
;;$TODO$;;       ;; remove the hooks
;;$TODO$;;       (remove-hook (ecb--semantic-after-partial-cache-change-hook)
;;$TODO$;;                    'ecb-update-after-partial-reparse)
;;$TODO$;;       (remove-hook (ecb--semantic-after-toplevel-cache-change-hook)
;;$TODO$;;                    'ecb-rebuild-methods-buffer-with-tagcache)
;;$TODO$;; ;;       (remove-hook (ecb--semantic--before-fetch-tags-hook)
;;$TODO$;; ;;                 'ecb-prevent-from-parsing-if-exceeding-threshold)
;;$TODO$;;       (ecb-stop-all-autocontrol/sync-functions)
;;$TODO$;;       (remove-hook 'after-save-hook 'ecb-update-methods-after-saving)
;;$TODO$;;       (remove-hook 'kill-buffer-hook 'ecb-kill-buffer-hook)
;;$TODO$;;
;;$TODO$;;       (remove-hook 'find-file-hooks 'ecb-find-file-hook)
;;$TODO$;;
;;$TODO$;;       ;; ediff-stuff
;;$TODO$;;       (ecb-deactivate-ediff-compatibility)
;;$TODO$;;
;;$TODO$;;       ;; disabling the VC-support
;;$TODO$;;       (ecb-vc-enable-internals -1)
;;$TODO$;;
;;$TODO$;;       ;; menus - dealing with the menu for XEmacs is really a pain...
;;$TODO$;;       (ignore-errors
;;$TODO$;;         (when ecb-running-xemacs
;;$TODO$;;           (save-excursion
;;$TODO$;;             (dolist (buf (buffer-list))
;;$TODO$;;               (set-buffer buf)
;;$TODO$;;               (if (car (find-menu-item current-menubar
;;$TODO$;;                                        (list ecb-menu-name)))
;;$TODO$;;                   (delete-menu-item (list ecb-menu-name)))))))
;;$TODO$;;
;;$TODO$;;       (remove-hook (if ecb-running-xemacs
;;$TODO$;;                        'activate-menubar-hook
;;$TODO$;;                      'menu-bar-update-hook)
;;$TODO$;;                    'ecb-compilation-update-menu)
;;$TODO$;;
;;$TODO$;;       ;; run any personal hooks
;;$TODO$;;       (unless run-no-hooks
;;$TODO$;;         (run-hooks 'ecb-deactivate-hook))
;;$TODO$;;
;;$TODO$;;       ;; clear the ecb-frame. Here we try to preserve the split-state after
;;$TODO$;;       ;; deleting the ECB-screen-layout.
;;$TODO$;;       (when (frame-live-p ecb-frame)
;;$TODO$;;         (raise-frame ecb-frame)
;;$TODO$;;         (select-frame ecb-frame)
;;$TODO$;;         (condition-case oops
;;$TODO$;;             (let* ((config (ecb-window-configuration-data))
;;$TODO$;;                    (window-before-redraw (nth 0 config))
;;$TODO$;;                    (pos-before-redraw (nth 1 config))
;;$TODO$;;                    (edit-win-data-before-redraw (nth 2 config))
;;$TODO$;;                    (edit-win-list-after-redraw nil))
;;$TODO$;;               ;; first we make all windows of the ECB-frame not dedicated and
;;$TODO$;;               ;; then we delete all ECB-windows
;;$TODO$;;               (ecb-select-edit-window)
;;$TODO$;;               (ecb-make-windows-not-dedicated ecb-frame)
;;$TODO$;;
;;$TODO$;;               ;; deletion of all windows. (All other advices are already
;;$TODO$;;               ;; disabled!)
;;$TODO$;;               (ecb-with-original-permanent-layout-functions
;;$TODO$;;                (delete-other-windows))
;;$TODO$;;
;;$TODO$;;               ;; some paranoia....
;;$TODO$;;               (set-window-dedicated-p (selected-window) nil)
;;$TODO$;;
;;$TODO$;;               ;; now we restore the edit-windows as before the deactivation
;;$TODO$;;               ;; (All other advices are already disabled!)
;;$TODO$;;               (if (= (length edit-win-data-before-redraw)
;;$TODO$;;                      (ecb-edit-area-creators-number-of-edit-windows))
;;$TODO$;;                   (ecb-with-original-permanent-layout-functions
;;$TODO$;;                    (ecb-restore-edit-area))
;;$TODO$;;                 (ecb-edit-area-creators-init))
;;$TODO$;;
;;$TODO$;;               (setq edit-win-list-after-redraw (ecb-canonical-edit-windows-list))
;;$TODO$;;
;;$TODO$;;               ;; a safety-check if we have now at least as many windows as
;;$TODO$;;               ;; edit-windows before deactivation. If yes we restore all
;;$TODO$;;               ;; window-data as before deactivation.
;;$TODO$;;               (when (= (length edit-win-list-after-redraw)
;;$TODO$;;                        (length edit-win-data-before-redraw))
;;$TODO$;;                 (dotimes (i (length edit-win-data-before-redraw))
;;$TODO$;;                   (let ((win (nth i edit-win-list-after-redraw))
;;$TODO$;;                         (data (nth i edit-win-data-before-redraw)))
;;$TODO$;;                     (set-window-buffer win (nth 0 data))
;;$TODO$;;                     (set-window-start win (nth 1 data))
;;$TODO$;;                     (set-window-point win (nth 2 data))
;;$TODO$;;                     (if (> (length edit-win-list-after-redraw) 1)
;;$TODO$;;                         (ecb-set-window-size win (nth 3 data)))
;;$TODO$;;                     )))
;;$TODO$;;
;;$TODO$;;               ;; at the end we always stay in that window as before the
;;$TODO$;;               ;; deactivation.
;;$TODO$;;               (when (integerp window-before-redraw)
;;$TODO$;;                 (ecb-select-edit-window window-before-redraw))
;;$TODO$;;               ;; if we were in an edit-window before deactivation let us go to
;;$TODO$;;               ;; the old place
;;$TODO$;;               (when pos-before-redraw
;;$TODO$;;                 (goto-char pos-before-redraw)))
;;$TODO$;;           (error
;;$TODO$;;            ;; in case of an error we make all windows not dedicated and delete
;;$TODO$;;            ;; at least all other windows
;;$TODO$;;            (ecb-warning "ecb-deactivate-internal (error-type: %S, error-data: %S)"
;;$TODO$;;                         (car oops) (cdr oops))
;;$TODO$;;            (ignore-errors (ecb-make-windows-not-dedicated ecb-frame))
;;$TODO$;;            (ignore-errors (delete-other-windows))))
;;$TODO$;;
;;$TODO$;;         (if (get 'ecb-frame 'ecb-new-frame-created)
;;$TODO$;;             (ignore-errors (delete-frame ecb-frame t))))
;;$TODO$;;
;;$TODO$;;       (ecb-initialize-layout)
;;$TODO$;;
;;$TODO$;;       ;; we do NOT disable the permanent-advices of
;;$TODO$;;       ;; `ecb-permanent-adviced-layout-functions' unless the user don't want
;;$TODO$;;       ;; preserving the split-state after reactivating ECB.
;;$TODO$;;       (when (not (equal ecb-split-edit-window-after-start 'before-activation))
;;$TODO$;;         (ecb-disable-advices 'ecb-permanent-adviced-layout-functions t)
;;$TODO$;;         (ecb-edit-area-creators-init))
;;$TODO$;;
;;$TODO$;;       ;; we can safely do the kills because killing non existing buffers
;;$TODO$;;       ;; doesnｴt matter. We kill these buffers because some customize-options
;;$TODO$;;       ;; takes only effect when deactivating/reactivating ECB, or to be more
;;$TODO$;;       ;; precise when creating the tree-buffers again.
;;$TODO$;;       (dolist (tb-elem (ecb-ecb-buffer-registry-name-list 'only-tree-buffers))
;;$TODO$;;         (tree-buffer-destroy tb-elem))
;;$TODO$;;       (ecb-ecb-buffer-registry-init)
;;$TODO$;;
;;$TODO$;;       (setq ecb-activated-window-configuration nil)
;;$TODO$;;
;;$TODO$;;       (setq ecb-minor-mode nil)
;;$TODO$;;
;;$TODO$;;       ;; restoring the value of temporary modified vars
;;$TODO$;;       (ecb-modify-emacs-variable 'max-specpdl-size 'restore)
;;$TODO$;;       (ecb-modify-emacs-variable 'max-lisp-eval-depth 'restore)
;;$TODO$;;       (when (and ecb-running-xemacs
;;$TODO$;;                  (boundp 'progress-feedback-use-echo-area))
;;$TODO$;;         (ecb-modify-emacs-variable 'progress-feedback-use-echo-area 'restore))))
;;$TODO$;;
;;$TODO$;;
;;$TODO$;;   (if (null ecb-minor-mode)
;;$TODO$;;       (message "The ECB is now deactivated."))
;;$TODO$;;   ecb-minor-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; AVOID ECB BUGS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq tramp-default-method "ssh")
(setq ecb-mode-line-display-window-number nil) ;; ecb-mode-line::ecb-mode-line-set has a bug. avoid

;; disable visit TAGS table especially in buffer name starting with '*'

;;;  TRY TO REF SYMBOL .
;;; ecb/ecb-symboldef.el
;; (defcustom ecb-symboldef-find-functions
;;   '((lisp-interaction-mode . ecb-symboldef-find-lisp-doc)
;;     (lisp-mode . ecb-symboldef-find-lisp-doc)
;;     (emacs-lisp-mode . ecb-symboldef-find-lisp-doc)
;;     (default . ecb-symboldef-find-definition))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FAIL TO START IF REMOTE FILE CANNOT BE ACCESSED
;;; BUF FILE NAME IS POINTING TO IT.
;; ecb-prescan-directories-exclude-regexps
;; (defcustom ecb-add-path-for-not-matching-files '(t . nil)

;; (defadvice '(tree-buffer-defpopup-command ecb-popup-sources-filter-by-regexp
;;  "Filter the sources by regexp by popup."
;;  (ecb-sources-filter-by-regexp))

    ;;;
;; (ecb-apply-filter-to-sources-buffer filter-regexp &optional filter-display)

;; Register doesn't contain a buffer position or configuration
                                        ;tmp    (setq ecb-clear-caches-before-activate t)

;;;; http://stackoverflow.com/questions/9184243/how-do-i-list-non-ecb-windows-in-emacs

;;$;; TODO
;;; Make node from root to current directory sticky
;; tree-buffer.el::tree-buffer-stickeynode-header-line-format
;; tree-buffer.el::tree-buffer-stickeynode-fetch-stickyline

;; ecb-activated-window-configuration
(message "my_ecb was loaded")

(provide 'my_ecb)
