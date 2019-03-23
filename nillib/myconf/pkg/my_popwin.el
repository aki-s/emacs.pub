;; 

;;; Code:
;; ----- http://what-linux.seesaa.net/article/158528332.html
;; ----  http://dukeiizu.blogspot.jp/2011/02/emacs-popwinel.html
;; --    http://dev.ariel-networks.com/articles/emacs/part4/
;; --    http://what-linux.seesaa.net/article/158528332.html
(require 'popwin)
(setq popwin:close-popup-window-timer-interval 0.1);; default 0.05
(setq display-buffer-function 'popwin:display-buffer)
(setq popwin:special-display-config
      '(
        (" *auto-async-byte-compile*" :noselect t)
        ("*Help*" :noselect t)
        ("*Completions*" :noselect t)
        ("*compilatoin*" :noselect t)
        ;;("*Occur*")
        ;; ("*Kill Ring*")
        ("*sdic*")
        ))

;; popwin collapse ecb window layout.

;;(popwin:window-config-tree)
;;(popwin:create-popup-window)
;;dev;; (defun popwin:window-config-tree ()
;;dev;;   "Return `window-tree' with replacing window values in the tree
;;dev;; with persistent representations."
;;dev;;   (destructuring-bind (root mini)
;;dev;;       (window-tree)
;;dev;;     (list (popwin:window-config-tree-1 root) mini)))

;;(defun popwin:window--subtree (window &optional next)

(defun popwin:ecb-window-p (window)
  (if (string-match "[ ]*ECB" (buffer-name (window-buffer window)))
      t
    nil)
  )

                                        ; (count-non-ecb-windows)

;;22(defun popwin:window--subtree (window &optional next)
;;22  "@dev
;;22 Only work if only one ecb-buffer is visible?
;;22 
;;22   Improved to ignore ecb window 
;;22  window-edges return the corrdinate of
;;22   upper-left(x1,y1), lower-right(x2,y2)
;;22 eval (popwin:window-tree) to test this function.
;;22   window--subtree is from window.el
;;22 "
;;22  
;;22  (let ( 
;;22        (org-window window) 
;;22        list 
;;22        )
;;22    (while window
;;22      (setq list
;;22            (cons
;;22             (cond
;;22              
;;22              ;;11;;               (when next (window-next-sibling window)
;;22              ;;11;;                (setq window (when next (window-next-sibling window)))
;;22              ;;11;;               ; (message "%s"(window-buffer window));debug
;;22              ;;11;;                (popwin:window--subtree window t)
;;22              ;;11;;                )
;;22              ;;00;;               ((popwin:ecb-window-p  window) ;; should be window-dedicated-p for generalization?
;;22              ;;00;;                (setq window (when next (window-next-sibling window)))
;;22              ;;00;;                 window ) ;; no need to go subtree
;;22              ((window-top-child window)
;;22               (cons t (cons (window-edges window)   ; vertical-split -
;;22                             (popwin:window--subtree (window-top-child window) t))))
;;22              ((window-left-child window)
;;22               (cond 
;;22                ( (popwin:ecb-window-p  (window-left-child window))
;;22                  
;;22                  (if (eq 1 (count-non-ecb-windows))
;;22                      (cons nil (cons (window-edges window) ; horizontal-split |
;;22                                      (popwin:window--subtree (window-next-sibling (window-left-child window)) t))) ; if t
;;22                    (cons nil (cons (window-edges window) ; horizontal-split |
;;22                                    ;;22  (setq window (when next (window-next-sibling (window-left-child window)))) 
;;22                                    ;; (cons nil (cons (window-edges (window-child window)) ; horizontal-split |
;;22                                    (popwin:window--subtree (window-next-sibling (window-left-child window)) t))) ;if nil
;;22                    );if
;;22                                        ;(setq next nil)
;;22                  ;;22  window) ;; no need to go subtree
;;22                  )
;;22                (t 
;;22                 (cons nil (cons (window-edges window) ; horizontal-split |
;;22                                 (popwin:window--subtree (window-left-child window) t))))))
;;22              (t window)) ; normal visible window
;;22             list)); setq list
;;22      ;;00;;       (if next 
;;22      ;;00;;         (setq window (window-next-sibling window))
;;22      (setq window (when next (window-next-sibling window))); loop condition for while
;;22                                        ;00  (setq next t)
;;22                                        ;00  ); window has window generated with C-x {2,3}
;;22      );while
;;22    ;;(message "%s" list)
;;22    (nreverse list)
;;22    );let
;;22  ) ; popwin:window--subtree
;;22
;;eval-test; (popwin:window-tree)

(if (= 1 1)
    (defun popwin:window--subtree (window &optional next)
      (if next
          (window--subtree window next)
        (window--subtree window )
        )
      )
  );if


;;(window-next-sibling (selected-window))
(defun popwin:window-tree (&optional frame)
  "window--subtree is from window.el"
  (setq frame (window-normalize-frame frame))
  (popwin:window--subtree (frame-root-window frame) t)) ;; mod

(defun popwin:window-config-tree ()
  "Original window configuration before activation of pop-tree.
  Should ignore window-dedicated window.
   (car (popwin:window-config-tree)) must be root window.
 related func is popwin:create-popup-window
 "
  ;;11  (condition-case er
;;  (lexical-let ( root nil )
    ;; (destructuring-bind (root mini)
  (let* (
         (wt (window-tree))
         (root (nth 0 wt))
         (mini (nth 1 wt))
         ) 
;;        (popwin:window-tree) ;; mod
;;        (window-tree)
      ;;(when (windowp mini) (list (popwin:window-config-tree-1 root) mini)))
      (list (popwin:window-config-tree-1 root) mini))
    ;;11 );lexical-let
    ;;00    (error nil
    ;;00           ;;  (error-message-string er) 
;;    ) ;; return nil?
  ;;11    ); condition-case
  ); popwin:window-config-tree

(eval-when-compile (require 'cl)) ;;destructuring-bind is from cl-macs.el l.563

;;oldver;;(defun popwin:window-config-tree-1 (node)
;;oldver;;  (if (windowp node)
;;oldver;;      (list 'window
;;oldver;;            (window-buffer node)
;;oldver;;            (window-edges node)
;;oldver;;            (eq (selected-window) node))
;;oldver;;;;    (destructuring-bind (dir edges . windows) node 
;;oldver;;        (let* (; use let* instead of destructuring-bind
;;oldver;;               (dir (nth 0 node) )
;;oldver;;               (edges (nth 1 node) )
;;oldver;;               (windows (cdr node) )
;;oldver;;               )
;;oldver;;      (append (list dir edges)
;;oldver;;              (mapcar 'popwin:window-config-tree-1 windows)))))

(defun popwin:window-config-tree-1 (node)
  (if (windowp node)
      (list 'window
            node
            (window-buffer node)
            (popwin:window-point node)
            (window-start node)
            (window-edges node)
            (eq (selected-window) node)
            (window-dedicated-p node))
;;    (destructuring-bind (dir edges . windows) node
        (let* (; use let* instead of destructuring-bind
               (dir (nth 0 node) )
               (edges (nth 1 node) )
               (windows (cdr node) )
               )
      (append (list dir edges)
              (mapcar 'popwin:window-config-tree-1 windows)))))

;;00;; (defun popwin:close-popup-window ()
;;00;; ;; (defun popwin:restore-window-outline (NODE OUTLINE)
;;00;; ;;
;;00;; Restore window outline accoding to the structures of NODE
;;00;; which is a node of `window-tree' and OUTLINE which is a node of
;;00;; `popwin:window-config-tree'.
(defun popwin:close-popup-window ()
  "Close the popup window and restore to the previous window
 configuration."
  (message "popwin:close-popup-window was called")
  (unwind-protect
      (when popwin:popup-window
        (popwin:stop-close-popup-window-timer)
        (if (and (popwin:popup-window-live-p)
                 (window-live-p popwin:master-window))
            (delete-window popwin:popup-window))
        (popwin:restore-window-outline (car (popwin:window-tree))
                                       popwin:window-outline))
    (setq popwin:popup-buffer nil
          popwin:popup-window nil
          popwin:focus-window nil
          popwin:window-outline nil
          popwin:context-stack nil
          ))
  )

;;00;; (defun* popwin:create-popup-window (&optional (size 15) (position 'bottom) (adjust t))
;;00;;   "@dev cause error"
;;00;;   (let* ((root (car (popwin:window-config-tree)))
;;00;;          (root-win (popwin:last-selected-window))
;;00;;          (hfactor 1)
;;00;;          (vfactor 1))
;;00;;     (delete-other-windows root-win)
;;00;;     (let ((root-width (window-width root-win))
;;00;;           (root-height (window-height root-win)))
;;00;;       (destructuring-bind (master-win popup-win offset)
;;00;;           (popwin:create-popup-window-1 root-win size position)
;;00;;         (when adjust
;;00;;           (if (popwin:position-horizontal-p position)
;;00;;               (setq hfactor (/ (float (- root-width size)) root-width))
;;00;;             (setq vfactor (/ (float (- root-height size)) root-height))))
;;00;;         (message "%S" (popwin:replicate-window-config master-win root offset hfactor vfactor))
;;00;;         (popwin:replicate-window-config master-win root offset hfactor vfactor)
;;00;;         (list master-win popup-win)))))

(defun* popwin:create-popup-window (&optional (size 15) (position 'bottom) (adjust t))
  "@dev cause error"
  (let* ((root (car (popwin:window-config-tree)))
         (root-win (popwin:last-selected-window))
         (hfactor 1)
         (vfactor 1))
    (popwin:save-selected-window
     (delete-other-windows root-win))
    (let ((root-width (window-width root-win))
          (root-height (window-height root-win)))
      (when adjust
        (if (floatp size)
            (if (popwin:position-horizontal-p position)
                (setq hfactor (- 1.0 size)
                      size (round (* root-width size)))
              (setq vfactor (- 1.0 size)
                    size (round (* root-height size))))
          (if (popwin:position-horizontal-p position)
              (setq hfactor (/ (float (- root-width size)) root-width))
            (setq vfactor (/ (float (- root-height size)) root-height)))))
;;      (condition-case er ; to restore window state if error occur
          (destructuring-bind (master-win popup-win)
              (popwin:create-popup-window-1 root-win size position)
            ;; Mark popup-win being a popup window.
            (with-selected-window popup-win
              (popwin:switch-to-buffer (popwin:dummy-buffer) t))
     ;;       (condition-case er ; to restore window state if error occur
                (let ( (win-map (popwin:replicate-window-config master-win root hfactor vfactor)) )
                  (list master-win popup-win win-map))
      ;;        (error (message "|%s|%S|%S|%S|" er master-win popup-win win-map))
      ;;        ); condition-case
            ); destructuring-bind
;;        (error (message "%s" er ))
        ))
  ) ; popwin:create-popup-window

(defun popwin:replicate-window-config (window node hfactor vfactor)
  "@dev"
  (if (boundp 'recurs) (incf recurs)
    ;;(if (intern-soft recurs) (incf recurs)
    (defvar recurs 1))
  ;;00 (condition-case er ; to restore window state if error occur
  ;;00      (message "[%s]|%s|%s|%s|%s|" recurs window node hfactor vfactor)
  (if (eq (car node) 'window)
     ;; (condition-case er ; to restore window state if error occur
;;          (destructuring-bind (old-win buffer point start edges selected dedicated) node
      (let* (
             (cdnode (cdr node))
             (old-win (nth 0 cdnode))
             (buffer (nth 1 cdnode))
             (point (nth 2 cdnode))
             (start (nth 3 cdnode))
             (edges (nth 4 cdnode))
             (selected (nth 5 cdnode))
             (dedicated (nth 6 cdnode))
             )
            (set-window-dedicated-p window nil)
            (popwin:adjust-window-edges window edges hfactor vfactor)
            (with-selected-window window
              (popwin:switch-to-buffer buffer t))
            (when selected
              (select-window window))
            (set-window-point window point)
            (set-window-start window start)
            (when dedicated
              (set-window-dedicated-p window t))
            `((,old-win . ,window)))
      ;;  (debug )); condition-case
    ;; 
    ;;(condition-case er ; to restore window state if error occur
        ;;      (destructuring-bind (dir edges . windows) node
        (let* (; use let* instead of destructuring-bind
               (dir (nth 0 node) )
               (edges (nth 1 node) )
               (windows (cdr node) )
               )
          (loop while windows
                for sub-node = (pop windows)
                for win = window then next-win
                for next-win = (and windows (split-window win nil (not dir)))
                append (popwin:replicate-window-config win sub-node hfactor vfactor)))
     ;; (debug )); condition-case
    );if
  ;;00    (wrong-number-of-arguments (message "!![%s]|%s|%s|%s|%s|" recurs window node hfactor vfactor))
  ;;00    (debug )
  ;;00    (error 
  ;;00     (message "%s\n [%s]|%s|%s|%s|%s|" er recurs window node hfactor vfactor)
  ;;00     (popwin:close-popup-window))
  ;;00    ); condition-case
  ); popwin:replicate-window-config

;; (setq popwin:popup-buffer nil
;;       popwin:popup-window nil
;;       popwin:focus-window nil
;;       popwin:window-outline nil)
;;00;; switch-to-buffer, pop-to-buffer is adviced by l.353 evil-core.el
(provide 'my_popwin)
;;; my_popwin.el ends here
