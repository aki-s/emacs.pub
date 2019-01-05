;;; my_js.el ---

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

;;

;;; Code:

(require 'js2-mode) ;; js2-mode require prog-mode.el of emacs24
(unless (executable-find "ag")
  (message "[config-error] xref-js2 requires `ag (a.k.a. silversearcher-ag)`'")
  )

(require 'xref-js2)
(setq xref-js2-ignored-dirs '("bower_components" "build" "lib"))


(require 'import-js)

(defvar my_js:import-js:debug t)

(unless (executable-find "importjs")
  (message "[config-error] import-js.el requires node-module named import-js\
      You'd better install `fb-watchman` for performance of import-js.''"))

(defun my_js:import-js-init()
  (unless import-js-process
    (message "Try to start importjsd")
    (run-import-js))
;;   (if my_js:import-js:debug (set-process-buffer import-js-process (get-buffer-create "*import-js*")))
  (when my_js:import-js:debug (message "Server log would be written in /tmp/importjs.log."))
  )

(defun my_js:import-js-goto ()
  "Run import-js goto function, which returns a path to the specified module."
  (interactive)
  (import-js-check-daemon)
  (setq import-js-output "")
  (setq import-js-handler 'my_js:import-js-handle-goto)
  (import-js-send-input `(("command" . "goto")
                          ("commandArg" . ,(my_js:import-js-word-at-point)))))

(defun my_js:import-js-word-at-point ()
  "Get the module of interest.

Extract `[@scope/]module-name`'"

  (save-excursion
    (skip-chars-backward "^'\"")
    (let ((beg (point)) module)
      (skip-chars-forward "^'\"")
      (setq module (buffer-substring-no-properties beg (point)))
      module)))

(defun my_js:import-js-handle-goto (import-data)
  "Navigate to the indicated file using IMPORT-DATA.

If no file is found, do nothing."
  (let* ((goto-list (json-read-from-string import-data))
          (file-name (cdr (assoc 'goto goto-list))))
    (if (file-exists-p file-name)
      (find-file file-name)
      (message "File named `%s` is not found." file-name))))

(provide 'my_js)
(message "my_js loaded")


;;;; Alternative to Tern (Tern doesn't support es6.)
;; npm install -g eslint
;; npm install -g eslint-plugin-react
;; ~/.eslintrc

;;; my_js.el ends here
