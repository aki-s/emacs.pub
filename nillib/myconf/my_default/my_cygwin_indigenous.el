;;; my_cygwin_indigenous.el --- Cygwin

;; Author: u
;; Keywords: 

;; Share emacs clipboard with Windows clipboard

;; | Mac     | cygwin  |gnu/linux|
;;--------------------	-------	
;; | pbcopy  | putclip |xclip |
;; | pbpaste | getclip |xclip |

(defun copy-from-win ()
       "Paste from clipboard"
        (interactive)
	(message "Paste from clipboard")
	(shell-command "echo $(getclip)" 1))

(global-set-key "\C-cy" 'copy-from-win)

;;(setq interprogram-paste-function 'copy-from-win)


(defun paste-to-win (text &optional push)
 (let ((process-connection-type nil))
     (let ((proc (start-process "putclip" "*Messages*" "putclip")))
       (process-send-string proc text) ;+bug: replace ^M with \C-x j.
       (process-send-eof proc))))

(setq interprogram-cut-function 'paste-to-win)
;;(global-set-key "\C-ck" 'paste-to-win)
;;(global-set-key "\C-ck" (setq interprogram-cut-function 'paste-to-win))
