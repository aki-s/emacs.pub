;;; my_eslint.el ---                                 -*- lexical-binding: t; -*-

;; Copyright (C) 2019

;; Author:  <>
;; Package-Version: 0.0.0
;; Package-Requires:
;; Keywords:
;; Created: 2019-01-06

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

;;

;;; Code:
(require 'flycheck)
(require 'add-node-modules-path)
(require 'cl-seq)
(require 'term)

(flycheck-add-mode 'javascript-eslint 'vue-mode)
(flycheck-add-mode 'javascript-eslint 'js-mode)
(flycheck-add-mode 'javascript-eslint 'js2-mode)

(defconst my_eslint:esintrc '(".eslintrc" ".eslintrc.yml" ".eslintrc.json"))
(defvar my_eslint:is-prompt-for-config t)
(defvar-local my_eslint:eslint-execpath nil)

(defun my_eslint:set-eslint-execpath-in-buffer()
  "Return nil if no eslint is found."
  (add-node-modules-path)
  (setf my_eslint:eslint-execpath (executable-find "eslint")))

(defun* my_eslint:prompt-for-config()
  "Prompt if no config of ESLint is found and `my_eslint:is-prompt-for-config' is t."
  (interactive)
  (let ((eslint-exec (my_eslint:set-eslint-execpath-in-buffer)))
    (unless (and
              my_eslint:is-prompt-for-config
              (or eslint-exec (prog1 nil (message "No command named eslint is found.")))
              (not (cl-reduce (lambda (a b) (or a b))
                     (mapcar (apply-partially #'locate-dominating-file default-directory)
                       my_eslint:esintrc))))
      (return-from my_eslint:prompt-for-config))
    ;; TODO: Improve by `read-char-choice'
    ;; ref. https://emacs.stackexchange.com/questions/32248/how-to-write-a-function-with-an-interactive-choice-of-the-value-of-the-argument
    (unless (yes-or-no-p (format "No config file for ESLint (%S) is found.\nDo you want to create?" my_eslint:esintrc))
      (when (yes-or-no-p "Do you want to disable this prompt for this session?")
        (my_eslint:toggle-auto-setup-prompt)
        (return-from my_eslint:prompt-for-config)))
    (let*
      ((at-dir (read-directory-name "Where do you want to create?: "
                 (or (vc-root-dir) default-directory)))
        (buf-name (format " *generate-eslintrc-%d*" (random 1000000)))
        (proc-name buf-name))
      (set-buffer (make-term proc-name "/bin/bash" nil "--norc"))
      (rename-buffer buf-name)
      (switch-to-buffer buf-name)
      (with-current-buffer buf-name
        ;; - Using `term' accepts <up>/<down> key-input, but it collapse display a bit.
        (term-mode)
        (term-char-mode)
        (setq buffer-read-only nil)
        (goto-char (point-max))
        (term-simple-send proc-name (format "cd %s" at-dir))
        (term-simple-send proc-name (mapconcat 'identity (list eslint-exec "--init") " "))
        (setq buffer-read-only t)
        ;; - Using `eshell' is more simple, but <up>/<down> key-input is not recognized.
        ;; Using Meta-p/Meta-n was alternate way, but this also collapse display.
        ;; ref. https://emacs.stackexchange.com/questions/7617/how-to-programmatically-execute-a-command-in-eshell
        )
      )))

(defun my_eslint:toggle-auto-setup-prompt()
  (setq my_eslint:is-prompt-for-config (not my_eslint:is-prompt-for-config)))

(defun my_eslint:init ()
  (my_eslint:prompt-for-config)
  )

;;------------------------------------------------
;; Unload function:

(defun my_eslint-unload-function ()
  "Unload function to ensure normal behavior when feature 'my_eslint is unloaded."
  (interactive)
  )

(provide 'my_eslint)
;;; my_eslint.el ends here
