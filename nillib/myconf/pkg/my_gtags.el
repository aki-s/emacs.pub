;;; my_gtags: --- customize ggtags ---
;;; Commentary:

;;;; http://www.emacswiki.org/emacs/GnuGlobal
;;; http://e-arrows.sakura.ne.jp/2010/02/vim-to-emacs.html

;;; Code:

(eval-when-compile (require 'cl))
(eval-when-compile (require 'subr-x)) ; string-join string-empty-p
(if (executable-find "gtags")
  (progn
    (when (require 'ggtags nil 'noerror)

      (set-face-attribute 'compilation-info nil :foreground "black" :background "gray") ; For color of `ggtags-mode-line-project-name'

      (add-hook 'emacs-lisp-mode-hook 'ggtags-mode)
      (add-hook 'java-mode-hook 'ggtags-mode)
      (add-hook 'scala-mode-hook 'ggtags-mode)
      (add-hook 'ruby-mode-hook 'ggtags-mode)
      (add-hook 'help-mode-hook 'ggtags-mode)

      (defadvice ggtags-update-tags (around ggtags-update-tags-force-nodirty activate)
        "Avoid gtags update error by advice.
;;;; TODO : ggtags.el
;;; Problem: When `global -u' returns exit code 1, gtags jump fails.
;;; Condition: v6.5.1 global : `global -u' vomits error if user has no read permission for a file. Update of GTAGS seems to be successful.
;;; Inspection:
;;; line 777         (ggtags-with-current-project
;;; (ggtags-project-dirty-p (ggtags-find-project)) ;=> t
"
        (condition-case nil
          ad-do-it
          (error (message "Recover global -u update error by advice.")
            (ggtags-update-tags-finish)); catch all
          )
        )

      (defadvice ggtags-after-save-function (around my_gtags-skip_ggtags-after-save-function activate)
        "@dev @todo: check if this advice is working well.
Skip update of gtags if global is already running.
 This happens with low CPU, slow network, or maybe when database is corrupted."
        (if (member "helm-gtags-update-tag" (mapcar 'process-name (process-list)))
          (progn (message "helm-gtags-update-tag is already running by the other cause. Skip update because updating tag is too slow.")
            (sit-for 2))
          ad-do-it
          )
        )

      ); cond require 'ggtags
    );cond

  (message "\tERROR: Cannot find gtags command.")

  );if

;; --------------------------------------------------------------------------------
;; --------------------------------------------------------------------------------

;;;; https://github.com/glimberg/emacs/blob/master/gl-ccmode.el
(defun gl-gtags-create-or-update ()
  "Create or update the gnu global tag file"
  (interactive)
  (if (not (= 0 (call-process "global" nil nil nil " -p"))) ; tagfile doesn't exist?
    (let ((olddir default-directory)
           (topdir (read-directory-name
                     "gtags: top of source tree:" default-directory)))
      (cd topdir)
      (shell-command "gtags -q && echo 'created tagfile'")
      (cd olddir)) ; restore
    ;; tagfile already exists; update it
    (shell-command "global -u 2> /dev/null && echo 'updated tagfile'")))

;;00;; (defun gl-next-gtag ()
;;00;;   "Find next matching tag, for GTAGS."
;;00;;   (interactive)
;;00;;   (let ((latest-gtags-buffer
;;00;;          (car (delq nil  (mapcar (lambda (x) (and (string-match "GTAGS SELECT" (buffer-name x)) (buffer-name x)) )
;;00;;                                  (buffer-list)) ))))
;;00;;     (cond (latest-gtags-buffer
;;00;;            (switch-to-buffer latest-gtags-buffer)
;;00;;            (next-line)
;;00;;            (gtags-select-it nil))
;;00;;           ) ))


(defvar my_gtags-assoc-prj-db nil
  "Association list between gtagdb and current default-directory")
(defvar my_gtags-dbpath nil
  "If the root of source code [GTAGROOT] and gtags db path [GTAGSDBPATH] is not the same
  ( e.g. GTAGTOOT is remote and GTAGSDBPATH is local ),
  and if you have multiple project, you need to manage gtag dbpath per file or per directory.
This is buffer local variable automatically decided by project root directory. "
  )

(defun my_gtags-setenv ()
  "@dev"
  (interactive)
  (cond
    ( (string-match (getenv "HOME") (expand-file-name default-directory))
      (progn
        (let ( (user ) )
          (setq gtags-rootdir "/home/" user ); set GTAGSROOT
          (setenv "GTAGSDBPATH" "/home/tags/" user)
          )
        )
      )
    (t
      (setq gtags-rootdir nil)
      (setenv "GTAGSDBPATH" )
      )
    ); cond
  (message "GTAGSDBPATH: %s\nGTAGSROOT: %s" my_gtags-dbpath gtags-rootdir)
  )


(make-variable-buffer-local 'my_gtags-dbpath)
(defun my_gtags-autoupdate ()
  (interactive)
  (when
    (and (not (string-match "/usr/include" (expand-file-name default-directory)))
      (and (not (string-match "/usr/local" (expand-file-name default-directory)))
        (and (not (string-match "/Library" (expand-file-name default-directory)))
          (and (not (string-match "/System" (expand-file-name default-directory)))
            (and (not (string-match "/Developer" (expand-file-name default-directory)))
              (and (not (string-match "/Users/grant/Development/RCX/External" (expand-file-name default-directory)))
                (and (not (string-match "/var" (expand-file-name default-directory)))
                  (and (not (string-match "/tmp" (expand-file-name default-directory)))
                    (not (string-match "/opt" (expand-file-name default-directory))))))))))
      (gl-gtags-create-or-update))))

;; --------------------------------------------------------------------------------
;; --------------------------------------------------------------------------------

(require 'cedet-global)
(require 'semantic/db-global)
(when (cedet-gnu-global-version-check t)  ; Is it ok?
  ;;http://www.randomsample.de/cedetdocs/cedet/GNU-Global.html#GNU-Global
  ;; Configurations for GNU Global and CEDET
  (cedet-gnu-global-version-check)

  (setq ede-locate-setup-options
    '(ede-locate-global
       ede-locate-base))
  (semanticdb-enable-gnu-global-databases 'c-mode)
  (semanticdb-enable-gnu-global-databases 'c++-mode)

  (setq-default semantic-symref-tool "global")
  )

;;;; ***** http://www.gnu.org/software/global/globaldoc_toc.html

;;; (setenv "GTAGSLIBPATH" "/usr/include:") ; $ cd /usr/include; gtags;
;;; prefix or suffix `:' in GTAGSLIBPATH cause `helm-gtags--path-libpath-p' cause error.


(defun my_gtags-gtagslibpath-prepend-uniqly (path)
  "Prepend PATH to environmental variable GTAGSLIBPATH."
  (interactive)
  (let* ((libpath (getenv "GTAGSLIBPATH"))
          (paths (mapcar #'expand-file-name
                   (and libpath (split-string libpath "[ :]" t))))
          (uniq-paths (loop for p in paths
                        if (and p (not (member p up)))
                        collect p into up
                        finally return up)))
    (setenv "GTAGSLIBPATH"
      (string-join
        (pushnew (expand-file-name path) uniq-paths :test #'equal)
        ":"))))

(my_gtags-gtagslibpath-prepend-uniqly "~/.emacs.d")
(setenv "GTAGSLOGGING" "/tmp/emacs-gtag.log") ; For debug
(setenv "GTAGSROOT") ;; unset because `ggtags-find-project' always returns this value.

(defun my_gtags-get-java-gtagslibpath ()
  "Dynamically get directory of GTAGS for Java.
Assume src.zip is unzipped and tag exists under the root dir."
  (let ((jhome (getenv "JAVA_HOME")))
    (if jhome
      (concat jhome "/src")
      (progn
        (case system-type
          ('darwin
            (concat (string-trim (shell-command-to-string "java_home")) "/src/"))
          ('gnu/linux ; Assume `java-1.8.0-openjdk-src' is installed and unzipped.
            (concat (string-trim (shell-command-to-string "dirname $(dirname $(readlink -n $(readlink -n $(which java))))")) "/src/"))
          (t
            "")
          )))))

(defvar major-mode_gtagslibpath nil "Hash table between `major-mode' and its gtagslibpath.")
(setq major-mode_gtagslibpath (make-hash-table :test 'equal))
(puthash 'java-mode `(,(my_gtags-get-java-gtagslibpath)) major-mode_gtagslibpath)
(require 'lisp-mode) ; emacs-lisp-mode
(puthash 'emacs-lisp-mode `("~/.emacs.d") major-mode_gtagslibpath)
(let ((inc (getenv "INCLUDE")))
  (if inc
    (puthash 'c-mode (split-string inc ":" t) major-mode_gtagslibpath)
    (puthash 'c-mode '("/usr/include") major-mode_gtagslibpath) ; default
    )
  )

(defun my_gtags-add-include(mode inc-path)
  "Add INC-PATH to shell variable gtagslibpath for emacs major MODE"
  (interactive
    (list
      (completing-read
        "major-mode: "
        obarray
        (lambda(s) (and
                     (commandp s)
                     (string-match-p ".*-mode$" (symbol-name s)))) t)
      (read-file-name "path-to-gtags: " nil nil t)
      ))
  (puthash mode
    (pushnew inc-path (gethash mode major-mode_gtagslibpath) :test 'equal)
    major-mode_gtagslibpath)
  )

(defun my_gtags-update-gtagslibpath()
  "Update GTAGSLIBPATH according to mode.
if there is no candidate for GTAGSLIBPATH, unset it."
  (interactive)
  (let* ((lst-of-paths (gethash major-mode major-mode_gtagslibpath))
          (p (string-join lst-of-paths ":")))
    (if (string-empty-p p)
      (setenv "GTAGSLIBPATH")
      (setenv "GTAGSLIBPATH" p)
      )
    (message "Update GTAGSLIBPATH=`%s'" p)
    ))

(defun my_gtags:print-gtagslibpath ()
  "Print the GTAGSLIBPATH (for debug purpose)."
  (interactive)
  (message "GTAGSLIBPATH=%s" (getenv "GTAGSLIBPATH"))
  )

;; For ggtag.el
;; global-pygments-plugin/sample.globalrc

;;--------------------------------------------------
(provide 'my_gtags)
;;; my_gtags.el ends here
