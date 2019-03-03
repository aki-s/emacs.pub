;;; MY_EVIL.EL --- ELISP

;; COPYRIGHT (C) 2013

;; Author:
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

;;; ref. http://www.emacswiki.org/emacs/Evil#toc1
;;; ref. http://d.hatena.ne.jp/tarao/20130305/evil_ext#seeall
(eval-when-compile (require 'cl ))

(require 'evil) ; evil require undo-tree.el
(evil-mode 1)

;; (setq evil-mode-line-format (cons 'before "") )
;;;; evil-vars.el
(setq
 evil-search-wrap  nil
 evil-flash-delay  10
 evil-fold-level   1
 evil-esc-delay    0
 )
;; (setq (kbd M-.) find-tag
;; (setq (kbd C-r backward-search

;;$;; evil-vars
(setq
 evil-buffer-regexps ;   Its value is (("^ \\*load\\*"))
 '(
   ("^ \\*load\\*" . nil)
   ("\\*Backtrace*" . motion)
   ("\\*Completions*" . normal)
   ("\\*calculator" . nil)
   ("\\*CClookup*" . motion)
   ("\\*GTAGS*" . motion)
   ("\\*Occur*" . motion)
   ("\\*sdic*" . motion)
   ("\\*terminal*" . emacs)
   ("\\*vc-diff*" . emacs)
   ("\\*w3m*" . nil)
   ("\\.zip$" . motion)
   )
 )
(push 'edebug-mode evil-emacs-state-modes)

(define-key evil-normal-state-map (kbd "M-.") nil) ; Disable `evil-repeat-pop-next'.

;;(when (featurep 'auto-complete)
;;  (define-key evil-insert-state-map (keb "\C-p") ac-dwim)

;;;;$ Overwrite keymap
(define-key evil-insert-state-map (kbd "\C-S-p") 'ac-quick-help)
(define-key evil-insert-state-map (kbd "\C-e") 'move-end-of-line)
(define-key evil-insert-state-map (kbd "\C-d") 'delete-char)
(define-key evil-insert-state-map (kbd "\C-k") 'kill-line)
(define-key evil-emacs-state-map (kbd "<M-escape> <M-escape>") 'evil-exit-emacs-state)

;; evil-default-cursor overwrite default cursor-color
(setq evil-default-cursor nil)



(require 'evil-numbers)
(define-key evil-normal-state-map (kbd "C-c +") 'evil-numbers/inc-at-pt)
(define-key evil-normal-state-map (kbd "C-c -") 'evil-numbers/dec-at-pt)

(define-key evil-visual-state-map (kbd "C-c +") 'evil-numbers/inc-at-pt)
(define-key evil-visual-state-map (kbd "C-c -") 'evil-numbers/dec-at-pt)

;;;; Prioritize mode-local keybind.
;; emulation-mode-map-alists
;; evil-overriding-maps




(require 'evil-matchit)
(global-evil-matchit-mode 1)



(defun my_evil-unload-function ()
   ""
   (interactive)
   ;;(remove-hook)
)

(provide 'my_evil)
;;; my_evil.el ends here
