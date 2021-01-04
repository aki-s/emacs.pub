;;; package --- my_font

;;; Commentary:

;;; useful funcs to get font related propertiies.
;; anyting-select-xfont
;; describe-fontset
;; (describe-font)
;; (insert (prin1-to-string (charset-list)))
;; (message "%s" (font-family-list))
;; (font-xlfd-name)
;; (message "%s" (frame-parameters))
;; (list-fontset)
;; (list-character-sets)
;; (new-fontset "NAME" FONTLIST)
;; (mule-diag)
;;  what-cursor-position,  C-u C-x =
;;;; useful vars to get font related properties.
;; charset-script-alist
;;;; useful link
;; http://www.emacswiki.org/emacs/fontSets
;;; shell
;; xfontsel -pattern -jis-fixed-medium-r-normal--16-150-75-75-c-160-jisx0208.1983-0
;; xlsfonts -fn "*-*-*-*-*-*-*-*-*-*-*-m-*-*-*"
;; fc-list :lang=ja
;; XLFD ( X Logical Font Description)
;; foundry-family-weight-slant-setWidth-addStyle-pixelSize-pointSize-resx-resy-spacing-avgWidth-charRegistry-charEncoding
;;http://e-arrows.sakura.ne.jp/2010/02/vim-to-emacs.html
;; -fndry-fmly-wght-slant-sWdth-adstyl-pxlsz-ptSz-resx-resy-spc-avgWdth-rgstry-encdng
;; -1       -2      -3      -4      -5         -6        -7       -8     -9      -10   -11  -12        -13       -14

;;; Code:
(eval-when-compile (require 'cl))

;;------------------------------------------------------------------------------
;; defun for main
;;------------------------------------------------------------------------------
(defun font-candidate (&rest fonts)
  (interactive)
  "Return existing font which first match."
  (find-if (lambda (f) (find-font (font-spec :name f))) fonts))

(defun my_font-set-default-font ()
  "@dev
Has bad effect to scaling feature for font on Linux."
  (interactive)
  (set-face-attribute
    ;;This function overrides the face attributes specified by FACE's
    ;;face spec.  It is mostly intended for internal use only.
    'default nil
    :family 'monospace
    ;;$conflict with monospace$;; :width 'condensed
    :font
    (or
      (font-candidate "-unknown-Liberation Mono-bold-normal-normal-*-10-*-*-*-m-0-iso10646-1") ;; exists on 'darwin.
      (font-candidate "-sony-fixed-medium-r-normal--16-120-100-100-c-80-iso8859-1") ;; exists on 'gnu/linux
      (font-candidate "-b&h-luxi mono-*-*-*--*-*-*-*-*-*-iso10646-1") ;; exists on 'gnu/linux and 'darwin.
      'unspecified
      )
    :weight 'semi-bold
    :height 80
    ;;:height def-zoom-ht
    ;; :foreground
    ;; :background
    )
  )

(defun my_font--increase-by-screen-resolution()
  "Set default font size based on screen resolution."
  ;; x-display-pixel-width doesn't support a character-only terminal.
  (unless (eq window-system nil)
    (let (fsize)
      (setq fsize
        (pcase `(,(x-display-pixel-width) ,(x-display-pixel-height))
          (`(3840 2160) ; XPS-15
            32)
          (`(1680 1050) ; OSX-15-inch
            18)
          (_ 32)))
      (set-frame-font (font-spec :family "Monospace" :size fsize) nil t)
      ;;(set-frame-font "mono" nil t)
      ))
  )

(defun my_font-setup_for_darwin()
  (cond  ;window-system
    ( (eq window-system 'ns)
      (create-fontset-from-ascii-font
        "-apple-monaco-medium-normal-normal-*-12-*" nil "hirakaku12")

      (set-frame-font "fontset-hirakaku12")
      (add-to-list 'default-frame-alist '(font . "fontset-hirakaku12"))

      (set-fontset-font
        "fontset-hirakaku12"
        'japanese-jisx0208
        "-apple-hiragino_kaku_gothic_pro-medium-normal-normal-*-14-*-iso10646-1")

      (set-fontset-font
        "fontset-hirakaku12"
        'jisx0201
        "-apple-hiragino_kaku_gothic_pro-medium-normal-normal-*-14-*-iso10646-1")

      (set-fontset-font
        "fontset-hirakaku12"
        'japanese-jisx0212
        "-apple-hiragino_kaku_gothic_pro-medium-normal-normal-*-14-*-iso10646-1")

      (set-fontset-font
        "fontset-hirakaku12"
        'katakana-jisx0201
        "-apple-hiragino_kaku_gothic_pro-medium-normal-normal-*-14-*-iso10646-1")
      ) ; window-system 'ns
    ((eq window-system 'x)
      ); window-system 'x
    )
  )

(defun my_font-setup_for_linux()
  (make-face 'JAxEN)
  (cond
    ( (member "helvetica" (font-family-list))
      (set-face-attribute 'JAxEN  nil
        :family 'helvetica))
    ( (member "luxi mono" (font-family-list))
      (set-face-attribute 'JAxEN  nil
        :family '"luxi mono"))
    )
  (defvar jaxen-font00 "-me-fixed-normal-normal-normal-*-12-*-*-*-*-*-fontset-*" "Custom font spec" )

  ;;err_if_no_font   (create-fontset-from-fontset-spec
  ;;err_if_no_font    (concat
  ;;err_if_no_font     jaxen-font00 ","
  ;;err_if_no_font     "ascii:-b&h-luxi mono-medium-o-normal--0-0-0-0-m-0-iso10646-1" ;; ascii
  ;;err_if_no_font     ))
  ;;err_if_no_font
  ;;err_if_no_font   (set-fontset-font
  ;;err_if_no_font    jaxen-font00 nil
  ;;err_if_no_font    ;; "-adobe-courier-medium-r-normal--8-80-75-75-m-50-iso10646-1"
  ;;err_if_no_font    "-adobe-courier-medium-o-normal--10-100-75-75-m-60-iso10646-1"
  ;;err_if_no_font    nil 'prepend
  ;;err_if_no_font    )
  ;;err_if_no_font   (set-fontset-font
  ;;err_if_no_font    jaxen-font00 nil
  ;;err_if_no_font    "-adobe-courier-medium-o-normal--8-80-75-75-m-50-iso8859-1"
  ;;err_if_no_font    nil 'prepend
  ;;err_if_no_font    )

  ;;err_if_no_font   (set-frame-font jaxen-font00) ;; set default font
  ;;err_if_no_font   ;;;; Unicode ~ ISO/IEC 10646
  ;;err_if_no_font   (set-face-font 'JAxEN jaxen-font00)
  ;;err_if_no_font   ;;(set-fontset-font
  ;;err_if_no_font      ;;   (setcdr (assoc 'font default-frame-alist) "fontset-default")
  ;;err_if_no_font      (setq-default buffer-face-mode-face "JAxEN")
  (defun JAxEN-mixed-hook ()
    "fixed font for ja and en  mixed language env"
    (interactive)
    ;;(set-face-attribute 'default nil '(:font . "-urw-Nimbus Mono L-normal-normal-normal-*-12-*-*-*-m-0-fontset-*"))
    ;;(set-frame-font  "-urw-Nimbus Mono L-normal-normal-normal-*-12-*-*-*-m-0-fontset-*")
     ;;;; Make selected fontset buffer local
    ;; (buffer-face-set  "-urw-Nimbus Mono L-normal-normal-normal-*-12-*-*-*-m-0-iso10646-1-*")
    (buffer-face-set  jaxen-font00)
    (message "JAxEN-mixed-hook called")
    )

  ;;(set-frame-font "-unknown-IPAGothic-mono-normal-normal-*-8-*-*-*-d-0-iso10646-1")
  ;;(set-frame-font "-unknown-Liberation Mono-bold-normal-normal-*-12-*-*-*-m-0-iso10646-1" t)
  ;;(set-frame-font  "-urw-Nimbus Mono L-normal-normal-normal-*-*-*-*-*-m-0-iso10646-1")

  ;;   (add-hook 'input-method-activate-hook 'JAxEN-mixed-hook nil t)
  ;;   (add-hook 'dired-load-hook 'JAxEN-mixed-hook) ;; not working well
  ;;   (add-hook 'Buffer-menu-mode-hook 'JAxEN-mixed-hook)
  (setq face-font-rescale-alist
    ;; ref. faceremap.el
    ;; text got from fc-list
    '(
       (".*IPAMincho.*" . 1)
       (".*IPAPMincho.*" . 1)
       ;;(".*IPAGothic.*" . 0.9)
       (".*VL PGothic.*" . 1)
       (".*UnDotum.*" . 0.8)
       ))
  ); gnu/linux

(defun my_font-message-current-font()
  (message "Current font is `%s`." (frame-parameter nil 'font))
  )
;;------------------------------------------------------------------------------
(my_font-message-current-font)
(set-face-attribute 'default nil
  :family "Ricty"
  :height 140)
(setq scalable-fonts-allowed t)

(cond ; system-type
  ((eq system-type 'darwin)
    (my_font-setup_for_darwin)
    (add-hook 'emacs-startup-hook 'my_font-set-default-font) ;; set my custom font size forcibly.
    ) ; system-name 'darwin

  ((and (eq system-type 'gnu/linux) (eq window-system 'x ))
    (my_font-setup_for_linux)
    )
  )
(my_font--increase-by-screen-resolution)

;;------------------------------------------------------------------------------
;; defun utils
;;------------------------------------------------------------------------------
(defun my_font-list-available-fonts ()
  (interactive)
  (mapcar (lambda(x) (message x "\n")) (x-list-fonts "*"))
  )

;;;
(provide 'my_font)
;;; my_font.el ends here
