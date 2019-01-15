;;; package --- ""
;;; Commentary:
;;; Code:

(setq-default flyspell-auto-correct-binding   (kbd "C-c C-c")) ; Avoid being set "C-;" by `defcustom' in flyspell.el
(require 'flyspell)
(define-key flyspell-mode-map (kbd "C-;") nil) ; Reserve C-; for the other usage.

;;http://d.hatena.ne.jp/o0cocoron0o/20101006/1286354957
(defun flyspell-correct-word-popup-el ()
  "Pop up a menu of possible corrections for misspelled word before point."
  (interactive)
  (require 'popup) ; popup-menu*
  (declare-function popup-menu* "popup")
  ;; use the correct dictionary
  (flyspell-accept-buffer-local-defs)
  (let ((cursor-location (point))
        (word (flyspell-get-word nil)))
    (if (consp word)
        (let ((start (car (cdr word)))
              (end (car (cdr (cdr word))))
              (word (car word))
              poss ispell-filter)
          ;; now check spelling of word.
          (ispell-send-string "%\n");put in verbose mode
          (ispell-send-string (concat "^" word "\n"))
          ;; wait until ispell has processed word
          (while (progn
                   (accept-process-output ispell-process)
                   (not (string= "" (car ispell-filter)))))
          ;; Remove leading empty element
          (setq ispell-filter (cdr ispell-filter))
          ;; ispell process should return something after word is sent.
          ;; Tag word as valid (i.e., skip) otherwise
          (or ispell-filter
              (setq ispell-filter '(*)))
          (if (consp ispell-filter)
              (setq poss (ispell-parse-output (car ispell-filter))))
          (cond
           ((or (eq poss t) (stringp poss))
            ;; don't correct word
            t)
           ((null poss)
            ;; ispell error
            (error "Ispell: error in Ispell process"))
           (t
            ;; The word is incorrect, we have to propose a replacement.
            (flyspell-do-correct (popup-menu* (car (cddr poss)) :scroll-bar t :margin t)
                                 poss word cursor-location start end cursor-location)))
          (ispell-pdict-save t))))
  (if (called-interactively-p 'interactive) (message "flyspell-correct-word-popup-el can be called with %s" (mapconcat 'key-description (where-is-internal 'flyspell-correct-word-popup-el) ", ")
 ))
  )

(define-key flyspell-mode-map (kbd "C-c s") 'flyspell-correct-word-popup-el)
(define-key flyspell-mode-map (kbd "C-;") nil) ; Reserve for elscreen.

;; (defun flyspell-mode-hooks ()
;;   (flyspell-correct-word-popup-el)
;;   )
;; (add-hook 'flyspell-mode-hook 'flyspell-mode-hooks)

(defface flyspell-incorrect
  '((((supports :underline (:style wave)))
     :underline (:style wave :color "#0000FF"))
    (t
     :underline t :inherit error))
  "Flyspell face for misspelled words. Overwrote by my_flyspell"
  :version "24.4"
  :group 'flyspell)

(add-hook 'find-file-hook 'flyspell-prog-mode)

(provide 'my_flyspell)
;;; my_flyspell ends here
