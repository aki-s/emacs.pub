;;; my_cask.el --- my_cask
;;; Commentary:

;;; Code:
(require 'cask "~/.cask/cask.el")
(require 'dash)
(require 'cl)
;; cask update --debug --verbose
(autoload 'eieio-defclass-autoload "eieio") ; For ubuntu  emacs 24.3.1

(defun shut-up-current-output ())
(let ((bundle (cask-initialize)))
  ;;;
  ;;; $ cask package-directory # @ x86_64-apple-darwin14.5.0, emacs24.5.1
  ;; Returned path
  ;; - until cask0.7.3(?) .cask/(emacs-version)/elpa
  ;; - since cask0.7.4 is .cask/(emacs-major-version).(emacs-minor-version)/elpa
  ;; When cask directory has changed you have to run cask command where Cask file exists.
  ;; For example if `load-path' doesn't have .cask/package/path/ check this fact.
;  (cask-install bundle)
  (setq load-path (-uniq (cask-load-path bundle)))

  ;;;bug?
  ;;[env] ubuntu emacs24.3.1 cask0.7.3
  ;;[problem]
  ;;[[3 files in cask-load-path were not set into load-path]]
  ;; .cask/24.3.1/elpa/dash-20141220.1452
  ;; .cask/24.3.1/elpa/epl-20140823.609
  ;; .cask/24.3.1/elpa/s-20140910.334
  ;;[reason]
  ;; Presume that if there are 2 file having the same name
  ;; under .cask directory,
  ;; cask doesn't set load-path for both of them.
  )

(defun my_cask-check-path ()
  "Check if setup `load-path' by Cask is done successfully."
  (eval-when-compile (require 'cl))
  (unless (loop for p in load-path
            thereis (string-match-p package-user-dir p))
    (error "Cask counldn't setup load-path"))
  t)
(my_cask-check-path)

(provide 'my_cask)
;;; my_cask.el ends here
