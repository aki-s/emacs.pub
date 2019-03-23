;;; package: --- my_auto-async-byte-compile

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

;;; Code:

(require 'auto-async-byte-compile)

(defun my_aabc-display-buffer (buffer-or-name)
  ""
  (let ( (num_win
          (length (delq t (mapcar 'window-dedicated-p (window-list-1)))) ))
    (if (= num_win 1)
        (split-window))
    (display-buffer buffer-or-name))
  )

(setq
 ;; '(auto-async-byte-compile-exclude-files-regexp nil)
 auto-async-byte-compile-exclude-files-regexp
 "\\(/junk/\\|init.el\\|nil.el\\|.*_tests.el\\|.dir-locals.el\\|.mc-lists.el\\)"
 ;; '(auto-async-byte-compile-init-file "~/.emacs.d/initfuncs.el")
 ;; auto-async-byte-compile-display-function 'display-buffer ; If #window is 1, take over the window. not good.
 ;; auto-async-byte-compile-display-function 'display-buffer-pop-up-window ; take over message window. not good.
 ;; auto-async-byte-compile-display-function 'display-buffer-pop-up-frame
 auto-async-byte-compile-display-function 'my_aabc-display-buffer
 )
(add-hook 'emacs-lisp-mode-hook 'enable-auto-async-byte-compile-mode)

(defvar aabc/hide-if-noerror t "Flag for my_aabc-hide-buf.")

(defun toggle-my_auto-async-byte-compile-autohide ()
  "Toggle if popped up is automatically closed or not."
  (interactive)
  (if aabc/hide-if-noerror
      (progn
        (setq aabc/hide-if-noerror nil)
        (message "set aabc/hide-if-noerror nil.")
        )
    (progn
      (setq aabc/hide-if-noerror t)
      (message "set aabc/hide-if-noerror t.")
      )
    )
  )

(defun bury (compiled-file aabc-win result-buffer)
  "@dev"
  (interactive)
  (when (and (buffer-live-p compiled-file) )
    (select-window aabc-win)(bury-buffer result-buffer)
    (message "aabc/display-function res- %s other- %s" result-buffer (other-buffer result-buffer))  (set-buffer (other-buffer result-buffer)  ))
  )

(defvar close-after-sec-default 1 "Close compilation window after this second.")
(defvar close-after-sec-penalty 5 "Plus another this sec if warning is shown.")

(defadvice aabc/display-function (around my_aabc-hide-buf last nil activate)
  "Hide *auto-async-byte-compile* result-buffer if  status is 'normal."
  (let* (
         aabc-win
         (current-buf (buffer-name))
         (current-win (get-buffer-window current-buf t))
         (num_win (or (count-windows-non-dedicated)(one-window-p))) ;; @TODO should consider dedicated window
         ;; walk-windows
         ;; (verbose t)
         ;;(verbose nil) ;; debug purpose
         (verbose my_aabc/debug-msg)
         case
         ;; @TODO should consider window is dead or alive
         )
    ad-do-it
    (when (and (not (eq status 'error))  (eq aabc/hide-if-noerror t))
      (let ( (close-after close-after-sec-default) )
        (if (eq status 'warning )
            (setq close-after (+ close-after close-after-sec-penalty )))
        (setq aabc-win (get-buffer-window result-buffer t))
        (if (window-live-p aabc-win)
            (progn
              (with-selected-window  aabc-win
                (goto-char (point-max))
                (insert (format "my_auto-async-byte-compile::aabc/display-function %s" status))
                (run-with-timer close-after nil
                                `(lambda ()
                                   (if (window-live-p ,aabc-win)
                                       (with-selected-window ,aabc-win
                                         (cond
                                          ((= ,num_win 1) ; cond1
                                           (switch-to-buffer ,current-buf)
                                           (delete-other-windows)
                                           (setq case 1)
                                           )
                                          ((>= ,num_win 2) ; cond2
                                           (if (not buffer-file-name); if1
                                               ;; in aabc-win
                                               (progn
                                                 (switch-to-buffer (car (first (window-prev-buffers (get-buffer-window (get-buffer ,result-buffer)t)))))
                                                 (if ,verbose (message "%S" (window-prev-buffers (get-buffer-window (get-buffer ,result-buffer)t))))
                                                 (setq case 3)
                                                 )
                                             (progn
                                               (setq case 4)
                                               (my_aabc/debug-msg ,verbose ,num_win 4)
                                               )
                                             ) ;if1
                                           )
                                          (t
                                           ;; do nothing
                                           )
                                          ); cond
                                         ;;finally
                                         (if ,verbose (message "aabc:[case %s]|#window %s|buffer-file-name %s| result-buffer %s | current-buf %s" case ,num_win (if buffer-file-name (ff-basename buffer-file-name)) ,result-buffer ,current-buf))
                                         )) ))))
          );if
        ))
    );when
  ); aabc/display-function

(defvar my_aabc/debug-msg nil "If t then debug message is shown.")

(defun my_aabc/debug-msg (verbose num_win case )
  (if verbose (message "[%2d] case %2d" num_win case))
  )

(provide 'my_auto-async-byte-compile)
;;; my_auto-async-byte-compile ends here
