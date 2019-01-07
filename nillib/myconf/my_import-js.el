;;; my_import-js.el ---                              -*- lexical-binding: t; -*-

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
(require 'import-js)

(defvar my_import-js:import-js:debug t)

(unless (executable-find "importjs")
  (message "[config-error] import-js.el requires node-module named import-js\
      You'd better install `fb-watchman` for performance of import-js.''"))

(defun my_import-js:import-js-init()
  (unless import-js-process
    (message "Try to start importjsd")
    (run-import-js))
;;   (if my_import-js:import-js:debug (set-process-buffer import-js-process (get-buffer-create "*import-js*")))
  (when my_import-js:import-js:debug (message "Server log would be written in /tmp/importjs.log."))
  )

(defun* my_import-js:import-js-goto ()
  "Run import-js goto function, which returns a path to the specified module."
  (interactive)
  (require 'files)
  (require 'json)
  ;; Prevent ImportJs misunderstand local-filename for module-name.
  (let ((target (my_import-js:import-js-word-at-point))
         pbase-dir
         pfile)
    (when (equal target
            (file-name-sans-extension (file-name-nondirectory (buffer-file-name))))
      (setq pbase-dir (concat (import-js-locate-project-root default-directory) "/node_modules/" target))
      (setq pfile (concat pbase-dir "/package.json"))
      (find-file-read-only (concat pbase-dir "/" (cdr (assoc-string 'main (json-read-file pfile)))))
    (return-from my_import-js:import-js-goto)))
  ;; Normal goto process.
  (import-js-check-daemon)
  (setq import-js-output "")
  (setq import-js-handler 'my_import-js:import-js-handle-goto)
  (import-js-send-input `(("command" . "goto")
                          ("commandArg" . ,(my_import-js:import-js-word-at-point)))))

(defun my_import-js:import-js-word-at-point ()
  "Get the module of interest.

Extract `[@scope/]module-name`'"

  (save-excursion
    (skip-chars-backward "^'\"")
    (let ((beg (point)) module)
      (skip-chars-forward "^'\"")
      (setq module (buffer-substring-no-properties beg (point)))
      module)))

(defun my_import-js:import-js-handle-goto (import-data)
  "Navigate to the indicated file using IMPORT-DATA.

If no file is found, do nothing."
  (let* ((goto-list (json-read-from-string import-data))
          (file-name (cdr (assoc 'goto goto-list))))
    (if (file-exists-p file-name)
      (find-file file-name)
      (message "File named `%s` is not found." file-name))))

;;------------------------------------------------
;; Unload function:

(defun my_import-js-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_import-js is unloaded."
   (interactive)
)

(provide 'my_import-js)
;;; my_import-js.el ends here
