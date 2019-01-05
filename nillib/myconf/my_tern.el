;;; my_tern.el --- Node module                       -*- lexical-binding: t; -*-

;; Copyright (C) 2017

;; Author:  <@>
;; Package-Version: 0.0.0
;; Package-Requires:
;; Keywords: javascript
;; Created: 2017-07-04

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

;;;; The Tern mode requires lexical scoping.
;;; - Tern is a stand-alone code-analysis engine for JavaScript.
;;; http://ternjs.net/
;; Tern is a stand-alone, editor-independent JavaScript analyzer that can
;; be used to improve the JavaScript integration of existing editors.
;;
;;; - Acorn is a tiny, fast JavaScript parser written in JavaScript.

;;;; SETUP
;; 1. Check if tern [as a server] can run in standalone mode.
;; $ .emacs.d/share/tern/bin/tern --persistent --verbose --port 54937 --strip-crs
;;  You may require additional modules like as `minimatch' `glob'
;;
;; 2. Install acorn [as a client]
;; $ sudo npm install -g acorn



;;; Code:
(require 'tern)
;;;; Investigation for development
;;;;$ Stack trace
;;$ tern.el
;; tern-run-query    (f query pos &optional mode)
;;- tern-run-request  (f doc)
;;-- tern-req (port doc c) ;vomit error (url-http-debug "Saw end of trailers..."))
;; -- tern-req-finished (c)
;;-- tern-find-server  (c &optional ignore-port)
;;--- tern-start-server (c)
;;
;;$ tern-auto-complete.el
;; tern-ac-complete-request
;;
;; @ref tern.el: tern-completion-at-point
;; tern-completion-matches-last
;; tern-completion-at-point-fn
;;- tern-do-complete
;;@ref (tern-run-query #'tern-do-complete '((type . "completions") (includeKeywords . t)) (point)))

(require 'vc)
(require 'dash)

(defvar my_tern:config-file-name ".tern-project")
(defvar my_tern:config-template-file-name "~/.emacs.d/share/insert/tern-project.json")
(defvar my_tern:ask-if-auto-setup t "Flag if auto setup is to be tried.")

(defun* my_tern:prompt-if-no-config-found ()
  "Create configuration file for Tern."
  (interactive)
  (unless my_tern:ask-if-auto-setup
    (message "Abort asking to create Tern config file, because %S is %s" 'my_tern:ask-if-auto-setup my_tern:ask-if-auto-setup)
    (return-from my_tern:prompt-if-no-config-found))
  (let ((conf-file (my_tern:locate-config (or (buffer-file-name) default-directory))))
    (when (and conf-file (file-exists-p conf-file)
          (return-from my_tern:prompt-if-no-config-found))))
  (unless (yes-or-no-p (format "No config file for Tern (%s) is found.\nDo you want to create?" my_tern:config-file-name))
    (when (yes-or-no-p "Do you want t/home/w/.tern-projecto disable this prompt for this session?")
      (my_tern:toggle-auto-setup-prompt))
      (return-from my_tern:prompt-if-no-config-found)
    )
  (let ((dir-table1 (my_tern:config-candidate-dirs))
         (dir-table2 (apply-partially #'completion-table-with-predicate
                       #'completion-file-name-table
                       #'file-directory-p
                       'strict))
         at-dir)
    (setq at-dir (completing-read (format "Specify directory to put `%s': " my_tern:config-file-name)
                   (completion-table-dynamic #'my_tern:completing-read-with-defaults)
                   ))
    (my_tern:create-config at-dir))
  )

(defun* my_tern:completing-read-with-defaults (user-input)
  (require 'find-file)
  (when (or (null user-input) (equal user-input "")) (return-from my_tern:completing-read-with-defaults (my_tern:config-candidate-dirs)))
  (let* ((f-cand (expand-file-name user-input "/"))
          (dir (file-name-directory f-cand))
          (base (file-name-base f-cand)))
    (cond
      ((or (null dir) (not (file-directory-p dir))) (list user-input))
      ((or (null base) (equal base "")) (ff-all-dirs-under dir))
      (t (list (concat "/" (file-name-completion base dir #'file-directory-p)))))))

(defun my_tern:toggle-auto-setup-prompt ()
  (interactive)
  (setq my_tern:ask-if-auto-setup (not my_tern:ask-if-auto-setup))
  (message "Toggled %S to %s" 'my_tern:ask-if-auto-setup my_tern:ask-if-auto-setup))

(defun my_tern:create-config (at-dir)
  (copy-file my_tern:config-template-file-name (concat at-dir "/" my_tern:config-file-name) nil)
  )

(defun my_tern:locate-config (from-path)
  "Locate directory having `my_tern:config-file-name'\
in parent directories of FROM-PATH.  Return nil if nothing is found."
  (let* ((parent-dir (locate-dominating-file from-path my_tern:config-file-name)))
    parent-dir))

(defun my_tern:config-candidate-dirs ()
  "Return nil, if no candidate is found."
  (-uniq (-non-nil
           (list (vc-root-dir)
             (locate-dominating-file default-directory "package.json")
             default-directory))))

(defun my_tern:setup ()
  (interactive)
  (unless (getenv "NODE_PATH") ; NODE_PATH becoming obsolute. See https://nodejs.org/api/modules.html
    ;; Set default
    (setenv "NODE_PATH"
      (mapconcat
        'expand-file-name (list
                            "~/local/lib/node_modules/"
                            "~/.emacs.d/share/"
                            )
        ":")))
    ;;; npm install -g jshint jslint # Only jshint was automatically chosen by flycheck?

     (require 'company)
     (require 'company-tern)
     (pushnew 'company-tern company-backends)
     (define-key tern-mode-keymap (kbd "C-S-p") 'company-tern)
     ;; Disable completion keybindings, as we use xref-js2 instead
     (define-key tern-mode-keymap (kbd "M-.") nil)
     (define-key tern-mode-keymap (kbd "M-,") nil)

     (my_tern:prompt-if-no-config-found)
     (company-mode 1)
     (my_tern:start-tern)
     (tern-mode 1)
     (message "[my_tern:setup] is called")
     )

;;;; tern-explicit-port may be O.K.
;;;; 49152 <= dynamic or private ports <= 65535
(defvar my_js-tern-server-port nil)

(defun my_tern:set-private-port-num (sym)
  "Return number ranging 49152 to 65535
 These numbers are suggested dynamic or private ports by IANA "
  ;;(get-process "Tern")
  (set sym (floor (+ 49152 (random 16384))))
  ;; Check if port is already used
  sym)
;;  ) ; 65535 - 49152
;; tern-known-port

;;;; share/tern/bin/tern
;;;; .tern-project
;;            --persistent
;; .tern-port --port

(defvar tern-server-proc nil)
(defvar tern-server-proc-obj nil)

(defun my_tern:start-tern ()
  "Run tern server for each buffer related to each file.
   The request/reponse to/from tern server is visible in buffer named 'tern-server-proc
   Just rewriting
   '(defun tern-start-server (c)
    ...
            (proc (apply #'start-process \"Tern\" nil tern-command))
   '
  may be sufficient.
  @ref. tern-start-server
  @dev
  Internally call node command.
  "
  (interactive)
  (setq tern-bin (executable-find "tern"))
  (unless tern-bin (throw 'no-bin "command `tern' was not found."))
  (set (make-local-variable 'tern-server-proc) nil)
  (set (make-local-variable 'tern-server-proc-obj) nil)
  ;;(if (get-process "Tern")
  ;;(if (and (stringp 'tern-server-proc) (get-process tern-server-proc))
  (if (symbol-value tern-server-proc)
    (progn
      (message "Tern is already running: %s" tern-server-proc)
      )
    (progn
      (if (null tern-explicit-port) (my_tern:set-private-port-num 'tern-explicit-port))
      (tern-use-server tern-explicit-port "127.0.0.1")
      ;; (setq tern-command (expand-file-name (concat user-emacs-directory "/share/tern/bin/tern")))
      (let ( (port (number-to-string tern-explicit-port)) )
        (if (and (boundp 'tern-bin) (atom 'tern-bin) )
          ;;             (setq tern-command `(,tern-command "--persistent" "--port" (number-to-string ,tern-explicit-port)))
          (setq tern-command (list tern-bin
                               "--persistent"  "--verbose"
                               "--port" port
                                        ; --no-port-file
                               )))
        (setf tern-server-proc (concat " *Tern" port "*" ))
        ;;(apply #'start-process "Tern" (get-buffer-create ) tern-command)
        (setf tern-server-proc-obj (apply #'start-process tern-server-proc (get-buffer-create tern-server-proc) tern-command))

        (set-process-query-on-exit-flag tern-server-proc-obj nil)
        ;;@TBD (set-process-sentinel proc (lambda (_proc _event)
        (message "my_js-tern-start: %s %s:%s" tern-command tern-project-dir tern-explicit-port)
        )))
  ;; debug
  (message "tern-explicit-port:%s" tern-explicit-port)
  (message "tern-known-port:%s" tern-known-port)
  (message "tern-server-proc-obj:%S" tern-server-proc-obj)
  (message "tern-server-proc:%s" tern-server-proc)
  )

;;;; DEBUG

(setq url-debug t) ; url-util @test
;; url-get-normalized-date ; url-util
(setq system-time-locale "ja") ; JST = GMT +9 ;@test

(defun my_js-tern-show-params()
  (interactive)
  (let* ((buf-str " *my_js-tern-show-params*")
          (buf (get-buffer-create buf-str)))
    (with-selected-window
      (display-buffer buf)
      (erase-buffer))
    ;; tern.el
    (princ (format "tern-activity-since-command:%s\n" tern-activity-since-command) buf)
    (princ (format "tern-buffer-is-dirty       :%s\n" tern-buffer-is-dirty) buf)
    (princ (format "tern-command-generation    :%s\n" tern-command-generation) buf)
    (princ (format "completion-at-point-functions :%s\n" completion-at-point-functions) buf)
    (princ (format "tern-explicit-port         :%s\n" tern-explicit-port) buf)
    (princ (format "tern-known-port            :%s\n" tern-known-port) buf)
    (princ (format "tern-last-argument-hints   :%s\n" tern-last-argument-hints) buf)
    (princ (format "tern-last-completions      :%s\n" tern-last-completions) buf)
    (princ (format "tern-last-point-pos        :%s\n" tern-last-point-pos) buf)
    (princ (format "tern-project-dir           :%s\n" tern-project-dir) buf)
    (princ (format "tern-server                :%s\n" tern-server)  buf)
    ;; tern-auto-complete.el
    (princ (format "tern-ac-complete-reply        :%s\n" tern-ac-complete-reply) buf)
    (princ (format "tern-ac-complete-request-point:%s\n" tern-ac-complete-request-point) buf)
    (princ (format "tern-last-point-pos           :%s\n" tern-last-point-pos) buf)
    ;; ac related
    ;;(princ (format "ac-fuzzy-enable           :%s\n" ac-fuzzy-enable) buf)
    (princ (format "ac-use-fuzzy           :%s\n" ac-use-fuzzy) buf)
    ))

;;------------------------------------------------
;; Unload function:

(defun my_tern-unload-function ()
  "Unload function to ensure normal behavior when feature 'my_tern is unloaded."
  (interactive)
  )

(provide 'my_tern)
;;; my_tern.el ends here
