;;; my_files.el ---                                  -*- lexical-binding: t; -*-

;; Copyright (C) 2017

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

;;
(require 'files)

;;; Code:

(setq vc-make-backup-files t) ; also backup versioned files (require 'vc-hooks)
;;;; ============================================================
;;;; Customize backup
;;;; ============================================================
;;;; [Format] BACKUPDIR/!path!to!file.~[version]~
;;;;
;; ref. http://stackoverflow.com/questions/151945/how-do-i-control-how-emacs-makes-backup-files

(defvar my_files--backupdir (expand-file-name "~/.emacs.d/backup/") "Must ends with /.")
(setq backup-inhibited nil)
(setq make-backup-files t) ; Non-nil means make a backup of a file the first time it is saved.
(add-to-list 'backup-directory-alist (cons ".*" my_files--backupdir))

;; (debug-on-entry make-backup-file-name-function)
;; (cancel-debug-on-entry make-backup-file-name-function)

(setq backup-by-copying t) ;; Copy all files, don't rename them.
(setq version-control t); default to nil ; Change from filename~ to filename.~n~
(setq kept-old-versions 2) ;;
(setq kept-new-versions 8) ;;
(setq delete-old-versions t);; Don't ask whether deleting excess backup versions.

(defun force-backup-of-buffer ()
  "Backup buffer each time it was saved.
Default strategy of Emacs is when file is first visited?
Once `backup-buffer' is called `buffer-backed-up' is set to 't.
"
  (let ((buffer-backed-up nil))
    (backup-buffer)))

(add-hook 'before-save-hook  'force-backup-of-buffer)

;;;; ============================================================
;;; Customize auto-save
;;;; ============================================================
;;;; [Format] AUTOSAVEDIR/#!path!to!file#
;;;; For concrete value for a visited buffer, see `buffer-auto-save-file-name'
;;;;
;;;; File `auto-save-list-file-name' contains map of files to be auto-saved.
;; - Suppose you modify a file named '/dir-to-F/F', buffer status becomes * and
;; '/dir-to-F/.#file -> @.PID' of emacs' a lock file(?) is created.
;; This unsaved buffer can be auto-saved.
;;
;; [Customized]
;; (setq auto-save-list-file-name nil)   ; prevent makeing '.save*' files
;; (setq auto-save-list-file-prefix nil) ; prevent makeing '.save*' files
;; `auto-save-list-file-name' is like as ~/.emacs.d/auto-save-list/.saves-<pid>-<hostname>~
;;
;; [Memo]
;;;; Built-in function `do-auto-save' messages 'Auto-saving...done'
;;;; files.el
;; - defines:`auto-save-hook'
;; - `auto-save-hook' is a hook called after `do-auto-save'
;; - `make-auto-save-file-name' generates name of #file#.
;;;; simple.el
;; - defines:`auto-save-mode-hook', `auto-save-mode'

(setq auto-save-default t)  ; Default to auto-save all visited file.
(setq auto-save-interval 60) ; Number of input events between auto-saves.
(setq auto-save-timeout 30) ; Number of seconds idle time before auto-save.
(setq delete-auto-save-files t) ; when save-buffer was called
(setq auto-save-file-name-transforms ;; Don't create #file# at the same location of original file was.
  `((".*" ,my_files--backupdir t))) ;; All auto saved file also goes to `my_files--backupdir'

;;------------------------------------------------
;; Unload function:

(defun my_files-unload-function ()
   "Unload function to ensure normal behavior when feature 'my_files is unloaded."
   (interactive)
)

(provide 'my_files)
;;; my_files.el ends here
