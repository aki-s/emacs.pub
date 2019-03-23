(setq auto-mode-alist
      (cons (cons "\\.pde$" 'c-mode) auto-mode-alist))
;; ;; C mode に入った時点でmy_processing を読み込む
;; (eval-after-load "cc-mode"
;;   '(progn
;;      (load-library "my_processing")))

;; (if (equal (file-name-extension (buffer-file-name (current-buffer)) ) "pde")
;;    (load-library "my_processing"))

;;-------------------------------------------------------------------------

;;;; http://d.hatena.ne.jp/hiboma/20070603/1180830768
;;; 現在のバッファで編集しているファイルをopenコマンドで開く          

(defun open-current-buffer-file ()
  "description about this function(omittable)"
  (shell-command (format "open %s" (buffer-file-name (current-buffer)))))

;;; applescriptを走らせる                                                                                                                                                                                 
(defun run-apple-script ()
  (shell-command-to-string (format "/usr/bin/osascript -e '%s' &" apple-script-code)))

;;; processingの起動、実行                                                                                                                                                                                
(defvar apple-script-code "                                                                                                                                                                               
tell application \"Processing\"                                                                                                                                                                           
  activate                                                                                                                                                                                                
end tell                                                                                                                                                                                                  
                                                                                                                                                                                                          
tell application \"System Events\"                                                                                                                                                                        
  if UI elements enabled then                                                                                                                                                                             
    key down command                                                                                                                                                                                      
    keystroke \"r\"                                                                                                                                                                                       
    key up command                                                                                                                                                                                        
  end if                                                                                                                                                                                                  
end tell                                                                                                                                                                                                  
")

;;; セーブしたら最読み込み/実行                                                                                                                                                                           
(add-hook 'after-save-hook '(lambda ()
                              (open-current-buffer-file)
                              (run-apple-script)))
