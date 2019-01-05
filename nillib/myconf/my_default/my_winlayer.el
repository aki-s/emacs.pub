;;;; ref.
;;; ~/.emacs.d/src/emacs-w3m/w3m-tabmenu.el
;;; ~/.emacs.d/src/ecb/ecb-buffertab.el
;;; https://github.com/5HT/emacs-config/blob/master/.emacs.d/windows/windows.el    by HIROSE Yuuji [yuuji@gentei.org]
;;; http://a-newcomer.com/56
;
;;; evil-commands.el::evil-window-rotate-upwards

(defgroup my_winlayer nil
 "Window layers to sort buffers.
Remember window layout.
Useful when multiple frame is not supported.
Alternate approach is using terminal multiplexer and emacsclient.
"
 :group 'emulations
 :prefix 'my_winlayer-
 )

(defcustom my_winlayer-exclude-regex-alist
  '(
    ("^ +")
    ("^ *\\*")
    )
  ""
  :group 'emulations
)
(defvar my_winlayer-layer-list
  '(
    'default ;; buffer related with layer goes here.
    'layer1
    'layer2
    ) 
  )

(defvar my_winlayer-layer-grouping-method
  '(
    'same-dir     ;; group files existing in the same dir.
    'buffer-name  ;; grop buffers having similar name. 
    ))

(defvar my_winlayer-register-alist nil)
(defvar my_winlayer-count 0)
(defvar my_winlayer-selected nil)
(defvar my_winlayer-selected-history nil)

;;;;###autoload

;; (defvar my_winlayer-always-immiscrible t)

(defun my_winlayer-push-layer ()
  ()
  )

(defun my_winlayer-create-layer ()
  (incf my_winlayer-count)
)

(defun my_winlayer-open-file-other-layer ())

(defun my_winlayer- ()
  (window-configuration-to-register 'w_register)
  (jump-to-register 'w_register)
  ;; register-alist
  ;; current-window-configuration
 ;; (redirect-frame-focus frame &optional focus-frame)
 ;; (list-registers)
  ;; (window-buffer
  ;; (window-num
)

(defun my_winlayer-merge-layer ())
(defun my_winlayer-move-to-layer ())

(defun my_winlayer-next-layer ())
(defun my_winlayer-prev-layer ())

(defun my_winlayer-list-layers ())
(defun my_winlayer-select-layer ());;a
(defun my_winlayer-go-to-layer ());;a

(defun my_winlayer-manager ());;a
;;(frame-title

;;;; popup, select window mechanism
;; display-buffer special-display-buffer-names special-display-function
;; same-window-buffer-names 
(provide 'my_winlayer)
