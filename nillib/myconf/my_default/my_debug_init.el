;;; package: --- my_debug_init.el
;;; Commentary:
;;; Code:
(message (format " DEBUG: %-20s (current-buffer)" (current-buffer)))
(message (format " DEBUG: %-20s window-system" (prin1-to-string window-system)))
;;(message (format " DEBUG: %-20s server-socket-dir" (prin1-to-string server-socket-dir)))

;;;; Symbol's value as variable is void: 
;;(message (format "%s" (prin1-to-string current-frame-configuration)))
;;(message (format "%s" (prin1-to-string default-frame-alist)))
;;(message (format "%s" (prin1-to-string frame-terminal)))

;;;
;; ENCODING 
;;(message (format " DEBUG: keyboard-coding-system %s" keyboard-coding-system))
;;(message (format " DEBUG: terminal-coding-system %s" terminal-coding-system))
;;(message (format " DEBUG: buffer-file-coding-system %s" buffer-file-coding-system))

;;(require 'my-debug_encoding);bug

;;trace;;;; (require 'trace)
;;trace;; (trace-function-background 'integer-or-marker-p)
;;trace;; (trace-function-background 'call-interactively)
;;trace;; (trace-function-background 'call-interactively-p)
;;trace;; (trace-function-background 'create-default-fontset)
;;trace;; (trace-function-foreground FUNCTION &optional BUFFER CONTEXT)

(message "my_debug_init.el::%s" (frame-parameters))

(if (require 'paren)
    (progn (message "\tparen:face-foreground:%s"
                    (face-foreground 'show-paren-match-face))
           (message "\tparen:face-background:%s"
                    (face-background 'show-paren-match-face))
           (message "\tparen:face-underline-p:%s"
                    (face-underline-p 'show-paren-match-face))
           ))

(require 'font-lock)
(defvar font-lock-verbose t)

;; (display-supports-face-attributes-p :underline)
;;; Stop elisp when encountered error.

;; (setq debug-on-error t)
;; (setq debug-on-error t
;;       debug-on-signal t
;;       )
(when (>= emacs-major-version 24) 
  (setq debug-on-error t
			;;;  func
        ;;			debug
                                        ;toggle-debug-on-quit
                                        ;toggle-debug-on-error
			;;; var
        ;; "Window is dedicated to"
        debug-on-signal nil
        debug-trace t ;; *edebug-trace*
        ;; (debug-on-entry 'signal)
        )
  (add-to-list 'debug-ignored-errors "Viper bell")
  (add-to-list 'debug-ignored-errors "Cannot analyze buffers not supported by Semantic") 
  )
;;;; http://stackoverflow.com/questions/3257480/how-to-debug-elisp
;;;  debug-on-entry followed by a function you want to enter using the debugger.
;;; toggle-debug-on-error -- Enter the debugger when when an error is raised.
;;; toggle-debug-on-quit -- Enter the debugger when the user hits C-g
(toggle-debug-on-error)
;; (backtrace) command is also usefull.

;;$;; Look at variable load-history to see defined functions. <- apropos-library do this.
(setq message-log-max 1000);; default to 100

(defvar my_debug-keylogging nil)
(defvar my_debug-keylogging-outfile (expand-file-name "~/.emacs.d/tmp/my_debug-keylogging.txt"))
(defun toggle-keylogger ()
  "Function to monitor keys typed.
   Useful when used with auto-revert-mode, auto-revert-tail-mode."
  (interactive)
  (if my_debug-keylogging
      (or (setq my_debug-keylogging nil) 
          (open-dribble-file nil)
          (message "keylogger is disabled:%s" my_debug-keylogging-outfile) )
    (or (setq my_debug-keylogging t)
        (open-dribble-file my_debug-keylogging-outfile)
        (message "keylogger is enabled:%s" my_debug-keylogging-outfile))
    )) 

;;;; memory management
;;$todo$;; (garbage-collect) ((435265 . 51916) (64473 . 28) (2415 . 941) 2567363 646690 (387 . 335) (2552 . 202) (88820 . 8985))
;;$todo$;; gc-cons-percentage 0.1
;;$todo$;; gc-cons-threshold 800000
;; ref. http://www.gnu.org/software/emacs/manual/html_node/elisp/Garbage-Collection.html

;;; ref. http://dev.ariel-networks.com/articles/software-design-200802/elisp-debug/



;;;; debug for timer

;; list of variables for timer
; timer-list
; timer-idle-list
; last-event-frame
; timer-event-last
; timer-event-last-1
; timer-event-last-2
; last-command

; (timer-event-handler tempbuf-timer)

(defun my_debug_init-unload-function ()
   (interactive)
   ""
)
(provide 'my_debug_init)

;;; my_debug_init.el ends here
