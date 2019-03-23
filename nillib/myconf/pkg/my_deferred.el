(require 'deferred)
(defun my_deferred-type-of ()
  "function type-of is sufficient"
  arrayp
  atom
  bool-vector-p
  booleanp
  bufferp
  byte-code-function-p
  case-table-p
  char-or-string-p
  char-table-p
  commandp
  consp
  custom-variable-p
  display-table-p
  floatp
  fontp
  frame-configuration-p
  frame-live-p
  framep
  functionp
  hash-table-p
  integer-or-marker-p
  integerp
  keymapp
  keywordp
  listp
  markerp
  nlistp
  number-or-marker-p
  numberp
  overlayp
  processp
  sequencep
  string-or-null-p
  stringp
  subrp
  symbolp
  syntax-table-p
  vectorp
  wholenump
  window-configuration-p
  window-live-p
  windowpp
  )

;; timer.el
;; timer-idle-list
(defun my_deferred:mon ()
  (interactive)
  (make-frame)
  (get-buffer-create "my_deferred:mon")
  (message "%S" deferred:queue)
)
