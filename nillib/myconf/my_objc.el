;; cite. http://sakito.jp/emacs/emacsobjectivec.html#emacs-objective-c
(require 'flymake)
(defvar xcode:gccver "4.0")
(defvar xcode:sdkver "3.1.2")
(defvar xcode:sdkpath "/Developer/Platforms/iPhoneSimulator.platform/Developer")
(defvar xcode:sdk (concat xcode:sdkpath "/SDKs/iPhoneSimulator" xcode:sdkver ".sdk"))
(defvar flymake-objc-compiler (concat xcode:sdkpath "/usr/bin/gcc-" xcode:gccver))
(defvar flymake-objc-compile-default-options (list "-Wall" "-Wextra" "-fsyntax-only" "-ObjC" "-std=c99" "-isysroot" xcode:sdk))
(defvar flymake-last-position nil)
(defvar flymake-objc-compile-options '("-I."))
(defun flymake-objc-init ()
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
                    'flymake-create-temp-inplace))
         (local-file (file-relative-name
                     temp-file                     (file-name-directory buffer-file-name))))
    (list flymake-objc-compiler (append flymake-objc-compile-default-options flymake-objc-compile-options (list local-file)))))


;;
(add-hook 'objc-mode-hook
         (lambda ()
           ;; 拡張子 m と h に対して flymake を有効にする設定 flymake-mode 1 の前に書く必要があります
           (push '("\\.m$" flymake-objc-init) flymake-allowed-file-name-masks)
           (push '("\\.h$" flymake-objc-init) flymake-allowed-file-name-masks)
           ;; 存在するファイルかつ書き込み可能ファイル時のみ flymake-mode を有効にします
           (if (and (not (null buffer-file-name)) (file-writable-p buffer-file-name))
               (flymake-mode 1))
         ))


;;=============================================================================
;; http://idita.blog11.fc2.com/blog-entry-810.html

(add-to-list 'ac-modes 'objc-mode)

;; objcインデント適用
(add-hook 'c-mode-common-hook
         '(lambda()
             (c-set-style "cc-mode")))

;; .m と .h で対応するファイルを C-c o で開く
(setq ff-other-file-alist
     '(("\\.mm?$" (".h"))
       ("\\.cc$"  (".hh" ".h"))
       ("\\.hh$"  (".cc" ".C"))

       ("\\.c$"   (".h"))
       ("\\.h$"   (".c" ".cc" ".C" ".CC" ".cxx" ".cpp" ".m" ".mm"))

       ("\\.C$"   (".H"  ".hh" ".h"))
       ("\\.H$"   (".C"  ".CC"))

       ("\\.CC$"  (".HH" ".H"  ".hh" ".h"))
       ("\\.HH$"  (".CC"))

       ("\\.cxx$" (".hh" ".h"))
       ("\\.cpp$" (".hpp" ".hh" ".h"))

       ("\\.hpp$" (".cpp" ".c"))))
(add-hook 'objc-mode-hook
         (lambda ()
           (define-key c-mode-base-map (kbd "C-c o") 'ff-find-other-file)
         ))

;; flymake
(require 'flymake)

(defvar flymake-compiler "gcc")
(defvar flymake-compile-options nil)
(defvar flymake-compile-default-options (list "-Wall" "-Wextra" "-fsyntax-only"))

(defun flymake-objc-init ()
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
         (local-file  (file-relative-name
                       temp-file
                       (file-name-directory buffer-file-name)))
	  (options flymake-compile-default-options))
    (list flymake-compiler (append options (list local-file)))))

(push '("\\.m$" flymake-objc-init) flymake-allowed-file-name-masks)
(push '("\\.h$" flymake-objc-init) flymake-allowed-file-name-masks)

(add-hook 'objc-mode-hook
          '(lambda ()
	          (flymake-mode 1)))

(provide 'flymake-objc)

;; smartchr.el
(defun smartchr-custom-keybindings-objc ()
  (local-set-key (kbd "@") (smartchr '("@\"`!!'\"" "@")))
  )

(add-hook 'objc-mode-hook 'smartchr-custom-keybindings-objc)
