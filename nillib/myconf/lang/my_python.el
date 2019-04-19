;;; my_python.el ---

;; Copyright (C) 2014

;; Author:  <@>
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
;; Switch to only rely on pyenv would be the best solution, because I
;; use `anaconda@.

;;$; ##; Setup pyenv
;;$; git clone https://github.com/pyenv/pyenv.git ~/.pyenv
;;$; cat <<'EOL' >> ~/.bashrc
;;$; export PYENV_ROOT="$HOME/.pyenv"
;;$; export PATH="$PYENV_ROOT/bin:$PATH"
;;$; eval "$(pyenv init -)"
;;$; EOL


;;

;;; Code:
;;;; ref. http://tkf.github.io/emacs-jedi/released/
(require 'python)
(require 'jedi)
(require 'my_flycheck:python)

(add-hook 'python-mode-hook 'jedi:setup)
;; (setq jedi:setup-keys t)                      ; optional
(setq jedi:complete-on-dot t)                 ; optional
(setq jedi:get-in-function-call-delay 0)
(setq python-environment-virtualenv
        (append (list "virtualenv" "--system-site-packages" "--quiet")
                `("--python" ,(executable-find "python"))))

(defun my_python-version ()
  "Get python version in the format of x.y.z."
 (let ((version (shell-command-to-string "python --version")))
  (when (string-match "\\([0-9]\\.[0-9]\\.[0-9]\\)" version)
  (match-string 0 version))))

;;info;; jedi:environment-root
;;info;; python-environment-directory
;;info;; python-environment-default-root-name
(defun my_python:setup-flycheck ()
  "Setup format checker `flake8'.
>>> .dir-locals.el
;; ((python-mode
;;   (flycheck-flake8rc . \"setup.cfg\")))
>>> setup.cfg
;; [flake8]
;; builtins = _
;; ignore = E111,E114
"
  (require 'cl)
  (loop for m in (list "pylint"
                   "flake8" "flake8-import-order" "flake8-docstrings"
                   "pep8-naming")
    do
    (unless (executable-find m) (async-shell-command (concat "pip install " m)))
    )
  )

(defun my_python:setup-jedi ()
  ;; TODO: Use `pyenv which XXX'.
  (pcase system-type
    (`darwin
      (cond
        ((executable-find "virtualenv") t) ; This virtualenv can be from python2 or 3.
        ((executable-find "virtualenv-2.7")
          (setq python-environment-virtualenv '("virtualenv-2.7" "--system-site-packages" "--quiet")))
        (t (async-shell-command "pip install virtualenv epc jedi"))
        ))))


(defun my_python:goto-definition()
  "Jump to definition
@dev: marker manager should be extracted as a package."
  (interactive)
  (unless (require 'my_imenu nil t)
    (message "required library 'my_imenu is not found."))
  (or
    ;; Try
    (let ((p (point))
           (pm (point-marker))
           (d (jedi:goto-definition))
           (is_success)
           )
      (deferred:sync! d)
      (setq is_success (not (eq p (point))))
      (if is_success (my_imenu-push-mark pm))
      is_success)
    ;; Fallback
    (my_imenu-jump)
    ))

(define-key python-mode-map (kbd "C-c h") 'jedi:show-doc)
(define-key python-mode-map (kbd "M-O") 'my_python:goto-definition)
(define-key python-mode-map (kbd "C-S-j") 'jedi:complete)

(when nil ; for debug
  (setq jedi:server-args
    '("--log-level" "DEBUG"
       "--log-traceback"))
  )

(defun my_python:virtual-env-dir ()
  ""
  (interactive)
  (concat user-emacs-directory "/.python-environments/" (my_python-version)))

(setq jedi:server-args
  ;; $ virtualenv
  `("--virtual-env" , (my_python:virtual-env-dir)))
(setq python-environment-default-root-name (my_python-version))

(defun my_python:setup-virtualenv (env-dir)
  "Setup env at ENV-DIR if it is not setup yet."
  (interactive)
  (unless (file-directory-p env-dir)
  ;; Use 'python-environment-directory as the flag if setup for my_python.el is completed
    (my_python:setup-jedi)
    (jedi:install-server)
    (my_python:setup-flycheck)
    ))

(my_python:setup-virtualenv (my_python:virtual-env-dir))
(provide 'my_python)
;;; my_python.el ends here
