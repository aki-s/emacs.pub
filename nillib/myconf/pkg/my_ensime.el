;;; my_ensime.el --- for scala                       -*- lexical-binding: t; -*-

;; Copyright (C) 2015

;; Author:  <@>
;; Keywords: lisp

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

;;; Setup:
;; mkdir -p ~/.sbt/0.13/plugins
;; echo 'addSbtPlugin("org.ensime" % "ensime-sbt" % "0.2.3")' >> /Users/aki_shunsuke/.sbt/0.13/plugins/plugins.sbt

;;; Code:
(require 'ensime)
(setq ensime-auto-generate-config t)
;; (add-hook 'scala-mode-hook 'ensime-scala-mode-hook) ; line " (scala-mode 1)" error if elpa/ensime-20160428.811 & elpa/scala-mode-20160813.304
;;(setq ensime-completion-style 'auto-complete)

;; ;; but company-mode / yasnippet conflict. Disable TAB in company-mode with
;; (define-key company-active-map [tab] nil)

(defsubst start-complement-ac ()
  "Internal usage."
  (eval-and-compile (require 'auto-complete))
  (insert ".")
  (ac-trigger-key-command t))

(defsubst start-complement-co ()
  "Internal usage."
  (eval-and-compile (require 'company))
  (cond (company-backend
          (company-complete-selection))
    (t
      (insert ".")
      (company-complete))))

(defun scala-start-complement ()
  ""
  (interactive "*")
  (eval-and-compile (require 'ensime))
  (eval-and-compile (require 's))
  (when (s-matches? (rx (+ (not space)))
          (buffer-substring-no-properties (line-beginning-position) (point)))
    (delete-horizontal-space t))
  (cond ((not (and (ensime-connected-p) ensime-completion-style))
          (insert "."))
    ((eq ensime-completion-style 'company)
      (start-complement-co))
    ((eq ensime-completion-style 'auto-complete)
      (start-complement-ac))))

;;(autoload 'scala-mode-map "scala-mode2-map" "for scala-mode-map" nil 'keymap)
;; (require 'scala-mode2-map) ; no more exist
(define-key scala-mode-map (kbd ".") 'scala-start-complement)

;;;; DEBUG
(setq ensime--debug-messages nil)
(setq ensime-log-events t)
;; ensime-config-includes-source-file
;; ensime--source-root-set
;; ensime-idle-typecheck-timer


;;------------------------------------------------
;; Unload function:

(defun my_ensime-unload-function ()
  "Unload function to ensure normal behavior when feature 'my_ensime is unloaded."
  (interactive)
  )

(provide 'my_ensime)
;;; my_ensime.el ends here
