;;; my_sql.el --- 

;; Copyright (C) 2014  

;; Author:  <@>
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



;;;; man  
;; http://d.hatena.ne.jp/kiwanami/20120305/1330939440
;; https://github.com/kiwanami/emacs-edbi/tree/master
(require 'edbi) ; Usage: M-x edbi:open-db-viewer
(autoload 'e2wm:dp-edbi "e2wm-edbi" nil t)

(require 'e2wm)
(global-set-key (kbd "M-+") 'e2wm:start-management)
(global-set-key (kbd "s-d") 'e2wm:dp-edbi); Activate keybind Super-d
(autoload 'edbi:open-db-viewer "edbi")

(provide 'my_sql)
;;; my_sql.el ends here
