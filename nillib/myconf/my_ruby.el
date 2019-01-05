;;; my_ruby.el ---                                   -*- lexical-binding: t; -*-

;; Copyright (C) 2014

;; Author:  <@>
;; Keywords: ruby

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

;; - Presume PATH is set by `rbenv'.

;;; Code:
;;; Robe
;; Required gems are: pry.rb, pry-doc?

(require 'robe)
(autoload 'robe-mode "robe" "Code navigation, documentation lookup and completion for Ruby" t nil)
(autoload 'ac-robe-setup "ac-robe" "auto-complete robe" nil nil)
(add-hook 'robe-mode-hook 'ac-robe-setup)



(defun my_ruby-setup-hs()
  (require 'hideshow)
  (add-to-list 'hs-special-modes-alist
    '(ruby-mode
       "\\(def\\|do\\|{\\)" "\\(end\\|end\\|}\\)" "#"
       ruby-end-of-block nil))
  )
(my_ruby-setup-hs)



(eval-and-compile
  (require 'pcase)
  (require 'deferred)
  )

(declare-function string-trim-right "subr-x")
(defun my_ruby-check-gem-if-installed(gem)
  "Return t if GEM is installed else nil."
  (require 'pcase)
  (pcase (string-trim-right (shell-command-to-string (concat "gem list " gem " -i")))
    ("true" t)
    ("false" nil)))

(defun my_ruby-is-installed(gems)
  "Check if GEMS (list of strings) are installed in sequence, then return a list of booleans at corresponding index."
  (mapcar 'not
    (mapcar
      (apply-partially 'string-match-p "^ERROR:")
      (split-string
        (shell-command-to-string
          (concat "gem which " (mapconcat 'identity gems " ")))
        "[\n\r]" t))))

(defun my_ruby-install-ifnot(gems)
  "Install GEMS for current version of gem."
  (interactive)
  (unless (executable-find "gem") (message "No command named `gem' was found."))
  (lexical-let ((gem-version (string-trim-right (shell-command-to-string "gem --version")))
                 (this-f "my_ruby-install-ifnot"))

    (deferred:$
      (deferred:next
        (lambda ()
          (my_ruby-is-installed gems)))
      (deferred:nextc it
        (lambda (tbl)
          (let (tbd)
            (setq tbd (cl-loop for tb in tbl
                        for g in gems
                        if (null tb) collect g))
            (if tbd (progn
                      (deferred:process-shell (concat "gem install " (mapconcat 'identity tbd " ")))
                      (message "'%s installed %S for gem-%s" this-f tbd gem-version)
                      ))
            )
          ))
      (deferred:error it
        (lambda (err) (message "%s %S" this-f err))
        )
      )))

(defvar my_ruby-required-gems '("pry" "pry-doc" "rubocop") "List of required gems.")
(defun* my_ruby-prepare-robe-start()
  "Helper function to start `robe-doc'.
Use Gemfile as source if it `gem pry', else use `inf-ruby'
Run this function before calling `robe-doc' if launching `robe-doc' has failed.
@dev I have fix chain of deferred
"
  (interactive)
  (deferred:$
    (deferred:next 'my_ruby-install-ifnot my_ruby-required-gems)
    (deferred:nextc it 'my_ruby-start-inf-ruby)
    (deferred:error it
      (lambda (err) (message "Failed %S" err))
      )
    )
  )

(defun* my_ruby-start-inf-ruby()
  (require 'inf-ruby)
  (require 'comint)
  (if (comint-check-proc inf-ruby-buffer)
    (progn
      (message "inf-ruby would be running already.")
      (return-from my_ruby-start-inf-ruby)))

  (let* ((gemfile "Gemfile")
          (dirname (locate-dominating-file default-directory gemfile))
          (case-fold-search t)
          )
    (if dirname
      (unless (with-temp-buffer
                (insert-file-contents (concat dirname "/" gemfile))
                (goto-char (point-min))
                (re-search-forward "gem[\r\n\t ]+'pry" nil t)
                )
        (inf-ruby))
      (inf-ruby))
    (with-current-buffer inf-ruby-buffer
      (previous-buffer))
    )
  (message "Done 'my_ruby-start-inf-ruby")
  )

;;------------------------------------------------
;; Unload function:

(defun my_ruby-unload-function ()
  "Unload function to ensure normal behavior when feature 'my_ruby is unloaded."
  (interactive)
  )

(provide 'my_ruby)
;;; my_ruby.el ends here
