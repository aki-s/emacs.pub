;;; my_js.el ---

;; Copyright (C) 2014

;; Author:  Syunsuke Aki
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

(setq-default js-indent-level 2)
(require 'js2-mode) ;; js2-mode require prog-mode.el of emacs24
(unless (executable-find "ag")
  (message "[config-error] xref-js2 requires `ag (a.k.a. silversearcher-ag)`'")
  )
;; Suppress warning: "Undeclared variable or function 'module'"
(setq js2-include-node-externs t) ; Support NodeJs

(require 'xref-js2)
(setq xref-js2-ignored-dirs '("bower_components" "build" "lib"))

(require 'my_simple)
(require 'mode-local)

(define-mode-local-override my_imenu-jump js2-mode (target) "Overridden `my_imenu-jump'"
  (interactive)
  ;; Save Markers of both before and after position if jump changed position.
    (or
      (with-demoted-errors "js2-jump-to-definition failed: %S" (js2-jump-to-definition))
      (with-demoted-errors "%S"
        (let ((my_tern:ask-if-auto-setup nil))
          (if target (call-interactively 'xref-find-definitions)
           (helm-imenu)))))
    )

(require 'my_import-js)
(require 'my_eslint)

(message "my_js loaded")
(provide 'my_js)

;;;; Alternative to Tern (Tern doesn't support es6.)
;; npm install -g eslint
;; npm install -g eslint-plugin-react
;; ~/.eslintrc

;;; my_js.el ends here
