;;;; https://github.com/nicferrier/elnode
;; usage: (elnode-init)
(require 'elnode)

;; (setq elnode-config-directory "")
;; (setq elnode-webserver-docroot "~/wiki/")
;; (setq elnode-wikiserver-wikiroot
;; (setq elnode-init-port 8000)
;; (setq elnode-init-host "localhost"
;; (setq elnode-log-files-directory nil
;; (setq elnode-error-log-to-messages t
;; (setq elnode-log-access-default-formatter-function
;; (setq elnode-log-access-alist nil
;; (setq elnode-default-response-table
;; (setq elnode-hostpath-default-table
;; (setq elnode-log-worker-elisp nil
;; (setq elnode-log-worker-responses nil
;; (setq elnode-send-file-program "/bin/cat"
;; (setq elnode-webserver-visit-file (eq system-type 'windows-nt)
;; (setq elnode-webserver-docroot
;; (setq elnode-webserver-extra-mimetypes
;; (setq elnode-webserver-index '("index.html" "index.htm")
;; (setq elnode-webserver-index-page-template "<html>
;; (setq elnode-webserver-index-file-template "<a href='%s'>%s</a><br/>\r\n"
;; (setq elnode-auth-db-spec
;; (setq elnode-auth-login-page "<html>
;; (setq elnode-do-init nil

(defun my-test-handler (httpcon)
  "Demonstration function"
  (elnode-http-start httpcon 200 '("Content-type" . "text/html"))
  (elnode-http-return httpcon "<html><b>HELLO! from my-test-handler</b></html>"))

;;(elnode-start 'my-test-handler :port 8010 :host "localhost")

;; elnode-http-pathinfo
;; elnode-wikiserver-wikiroot default-wiki-index.creole
