;;; packages --- my_macro

;;; Commentary:
;;;; ref. macroexpand
;;;; closure sec
;; ref. http://e-arrows.sakura.ne.jp/2010/03/macros-in-emacs-el.html

;;; Code:
(eval-when-compile (require 'cl))
(defmacro load-library-lazy (lib-name)
  "@dev
defferred.el may be alternate way to load library ."
  ;;(run-with-timer SECS REPEAT FUNCTION &rest ARGS)
  (incf SEC)
  `(run-with-timer SECS nil (load-library ,lib-name nil t))
  )

;;(defmacro load-library-nodeps (lib-fname feature)
;;  "@dev
;;\"require\" inside required library make dependency deep.
;;Avoid this with this macro."
;;  `(if (and (not (featurep ,feature)) (locate-library ,feature) )
;;     (progn 
;;       (message ,lib-fname)
;;       (load-library ,lib-fname)
;;       )
;;     ))

(defmacro load-library-nodeps (lib-fname &optional feature)
  "@DEV
\"require\" inside required library make dependency deep. Avoid this with this macro.
Usually 'lib-fname and 'feature is equal, so 2nd argument is optional.
"
  ;; make-symbol, symbol-name, intern
  (declare (indent 1) (debug let))
  `(let* ( 
          (lib ,lib-fname) 
          (ft (if (null 'feature) lib  ,feature) )
          )
     (if ft
         (message "Feature tried to load is %s" ft)
         (message "Library tried to load is %s" lib)
         )
     (if (and 
          (not (featurep 'ft)) 
          (locate-library lib) 
          )
         (progn 
           (load-library lib)
           )))
  )

;;ref. edmacro.el
;;obsolete?;; ;;;http://e-arrows.sakura.ne.jp/2010/02/vim-to-emacs.html
;;obsolete?;; ;; dmacro
;;obsolete?;; ;; 2回同じ操作をすると自動でマクロ登録
;;obsolete?;; (defconst *dmacro-key* "\C-q")
;;obsolete?;; (global-set-key *dmacro-key* 'dmacro-exec)
;;obsolete?;; (autoload 'dmacro-exec "dmacro" nil t)



(provide 'my_macro)
;;; my_macro ends here
