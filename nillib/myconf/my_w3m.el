;;; my_w3m --- Summary
;;; == w3m ==
;;; Commentary:
;;--------------------------------------------------------
;;; Code:

(if (executable-find "w3m") ; 'w3m vomits error if w3m is not found
    (progn
      (eval-when-compile
    ;;;; macro must be eval'ed at compile time.
        (load-library "subr") ; declare-function
        (require 'cl)
        (require 'thingatpt);thing-at-point-url-path-regexp
        (declare-function thing-at-point-url-path-regexp "thingatpt")
        (require 'w3m-util nil t) ;; 'w3m-interactive-p is macro defined at w3m-util.
        )

      (require 'w3m) ; w3m-content-type-alist w3m-browse-url
      (declare-function w3m-browse-url "w3m.el")
      (require 'w3m-load); Main tree of emacs-w3m is emacs-w3m-1.4.4, fusion with CVS version.
      (require 'my_browse-url)

      ;;(setq w3m-command "/opt/local/bin/w3m")
      ;; (setq w3m-use-cookies t)
      ;; (setq w3-default-homepage "http:/")
      ;; (setq w3-default-stylesheet "~/.w3/defaults.css")

      ;; (global-set-key "\C-xm" 'browse-url-at-point)

      ;;--------------------------------------------------------
;;; http://redtower.plala.jp/2011/02/19/emacs-web-emacs-w3m.html

      (setq w3m-command "w3m")

      (defun choose-browser (url &rest args)
        (interactive "sURL: ")
        (if (y-or-n-p "Use external browser? ")
            (my-external-browser url)
          (w3m-browse-url url)))

      (defun my-external-browser (url &rest args)
        (cond
         ((eq system-type 'darwin) (browse-url-default-macosx-browser url))
         ((member system-type '(windows-nt cygwin))     (browse-url-generic url))
         ((eq system-type 'gnu/linux) (browse-url-generic url))
         (t (message "No matching system-type %s" system-type))
         ))

      (cond
       ((eq system-type 'darwin)
        (defvar my-browser "MultiBrowser")
        (defun browse-url-default-macosx-browser (url &optional new-window)
          (interactive (browse-url-interactive-arg "URL: "))
          (if (and new-window (>= emacs-major-version 23))
              (ns-do-applescript
               (format
                (concat "tell application " my-browser " to make document with properties {URL:\"%s\"}\n"
                        "tell application " my-browser " to activate") url))
            (start-process (concat "open " url) nil "open" url)))
        ))

      (defvar browse-url-dhtml-url-list ; Black list which cannot be browsed with emacs-w3m
        '("http://www.google.com/reader"
          "http://www.google.co.jp/reader"
          "http://maps.google.co.jp"
          "http://map.yahoo.co.jp"
          "http://map.labs.goo.ne.jp"
          "http://ww.php.net"
          ))

      (defvar my_w3m-browser-url-browser-function
            `((,(concat "^" (regexp-opt browse-url-dhtml-url-list)) . my-external-browser)
              ("file:" . w3m-browse-url) ; Open URL in buffer.
              ("." . choose-browser)
              ))
      (setq browse-url-browser-function ;; "Overwrite default func provided by browse-url.el
        my_w3m-browser-url-browser-function)

      (defun my_w3m-toggle-browe-url-browser-function ()
        "Select pre defined browsing method for w3m."
        (interactive)
        (let ((func (ido-completing-read "Select from list: "
                                         '(
                                           "my-external-browser"
                                           "choose-browser"
                                           "w3m-browse-url"
                                           ))))
          (setq-default browse-url-browser-function (intern func)) ; setq didn't work
          (message "browse-url-browser-function is set to '%s" browse-url-browser-function)
         )
        )

;;;; ttp で始まる URL を http として認識させる。
      ;; for browse-url-at-mouse
      (setq-default thing-at-point-url-regexp
                    (concat
                     "\\<\\(h?ttps?://\\|ftp://\\|gopher://\\|telnet://"
                     "\\|wais://\\|file:/\\|s?news:\\|mailto:\\)"
                     thing-at-point-url-path-regexp))
      (defadvice thing-at-point-url-at-point (after support-omitted-h activate)
        (when (and ad-return-value (string-match "\\`ttps?://" ad-return-value))
          (setq ad-return-value (concat "h" ad-return-value))))

      ;; for emacs-w3m
      (setq-default ffap-url-regexp
                    (concat
                     "\\`\\("
                     "news\\(post\\)?:\\|mailto:\\|file:"
                     "\\|"
                     "\\(ftp\\|h?ttps?\\|telnet\\|gopher\\|www\\|wais\\)://"
                     "\\)."))

      (defadvice ffap-url-at-point (after support-omitted-h activate)
        (when (and ad-return-value (string-match "\\`ttps?://" ad-return-value))
          (setq ad-return-value (concat "h" ad-return-value))))

;;;; for SEMI
      (setq-default mime-browse-url-regexp
                    (concat "\\(h?ttps?\\|ftp\\|file\\|gopher\\|news\\|telnet\\|wais\\|mailto\\):"
                            "\\(//[-a-zA-Z0-9_.]+:[0-9]*\\)?"
                            "[-a-zA-Z0-9_=?#$@~`%&*+|\\/.,]*[-a-zA-Z0-9_=#$@~`%&*+|\\/]"))

      (defadvice browse-url (before support-omitted-h (url &rest args) activate)
        (when (and url (string-match "\\`ttps?://" url))
          (setq url (concat "h" url))))

      (eval-after-load 'w3m-namazu "my_w3m-namazu")

      (setq-default w3m-coding-system  'utf-8
                    w3m-file-coding-system 'utf-8
                    w3m-file-name-coding-system 'utf-8
                    w3m-input-coding-system 'utf-8
                    w3m-output-coding-system 'utf-8
                    w3m-terminal-coding-system 'utf-8)

      (setq w3m-local-find-file-regexps
            (cons nil "\\(/Users\\|/home\\|file\\|.*www.cppreference.com.*\\|\\.\\(gif\\|html?\\|jp\\(?:e?g\\)\\|png\\|shtml?\\|txt\\|x\\(?:bm\\|html?\\|pm\\)\\)\\)")
            )

      ;; File name matched with right hand side of w3m-local-find-file-regexps
      (setq w3m-content-type-alist
            ;; '(nil "^file.*www.cppreference.com.*" browse-url "text/html") ;; for cclookup.el
            (append
             (list '("text/html" "^/\\(home|Users\\)" w3m-browse-url nil)) ;; for cclookup.el
             (list '("text/html" "^file.*www.cppreference.com.*" w3m-browse-url nil)) ;; for cclookup.el
             (list '("application/xhtml+xml" "^file.*www.cppreference.com.*" w3m-browse-url "text/html")) ;; for cclookup.el
             (list '("text/html" "^file://localhost/.*" w3m-browse-url nil)) ;; for cclookup.el
             w3m-content-type-alist)
            )
      ;;@TODO
      ;; w3m-create-page l.6403 (format "Input %s's content type (default Download): "

      ;; w3m-view-this-url
      ;; w3m-create-page (
      (defun toggle-w3m-verbose ()
        (interactive)
        (if w3m-verbose
            (message "w3m-verbose disabled")
          (message "w3m-verbose enabled"))
        (setq w3m-verbose (null w3m-verbose)))

      ;;useless+addedBug (defadvice w3m-view-this-url (around w3m-view-this-url-bugfix last activate)
      ;;useless+addedBug   ad-do-it
      ;;useless+addedBug   (w3m-buffer)
      ;;useless+addedBug   )
      ;;useless+addedBug (ad-deactivate 'w3m-view-this-url)

      ;;--------------------------------------------------------

      (defun w3m-goto-url (url &optional reload charset post-data referer handler
                               element no-popup)
        "Overwrite default by my_w3m.
Reason: Wrong number of arguments?
 "
        (interactive
         (list (if w3m-current-process
                   (error "%s"
                          (substitute-command-keys "Cannot run two w3m processes simultaneously \
\(Type `\\<w3m-mode-map>\\[w3m-process-stop]' to stop asynchronous process)"))
                 (w3m-input-url nil nil nil nil 'feeling-lucky))
               current-prefix-arg
               (w3m-static-if (fboundp 'universal-coding-system-argument)
                   coding-system-for-read)))
        (when (and (stringp url)
                   (not (w3m-interactive-p)))
          (setq url (w3m-canonicalize-url url)))
        (set-text-properties 0 (length url) nil url)
        (setq url (w3m-uri-replace url))
        (unless (or (w3m-url-local-p url)
                    (string-match "\\`about:" url))
          (w3m-string-match-url-components url)
          (setq url (concat (save-match-data
                              (w3m-url-transfer-encode-string
                               (substring url 0 (match-beginning 8))))
                            (if (match-beginning 8)
                                (concat "#" (match-string 9 url))
                              ""))))
        (cond
         ;; process mailto: protocol
         ((string-match "\\`mailto:" url)
          (w3m-goto-mailto-url url post-data))
         ;; process ftp: protocol
         ((and w3m-use-ange-ftp
               (string-match "\\`ftps?://" url)
               (not (string= "text/html" (w3m-local-content-type url))))
          (w3m-goto-ftp-url url))
         ;; find-file directly
         ((condition-case nil
              (and (w3m-url-local-p url)
                   w3m-local-find-file-function
                   (let ((base-url (w3m-url-strip-fragment url))
                         (match (car w3m-local-find-file-regexps))
                         nomatch file)
                     (and (or (not match)
                              (string-match match base-url))
                          (not (and (setq nomatch (cdr w3m-local-find-file-regexps))
                                    (string-match nomatch base-url)))
                          (setq file (w3m-url-to-file-name base-url))
                          (file-exists-p file)
                          (not (file-directory-p file))
                          (prog1
                              t
                            (funcall (if (functionp w3m-local-find-file-function)
                                         w3m-local-find-file-function
                                       (eval w3m-local-find-file-function))
                                     file)))))
            (error nil)))
         ;; process buffer-local url
         ((w3m-buffer-local-url-p url)
          (let (file-part fragment-part)
            (w3m-string-match-url-components url)
            (setq file-part (concat (match-string 4 url)
                                    (match-string 5 url))
                  fragment-part (match-string 9 url))
            (cond
             ((and (string= file-part "")
                   fragment-part)
              (w3m-search-name-anchor fragment-part))
             ((not (string= file-part ""))
              (w3m-goto-url (w3m-expand-url (substring url (match-beginning 4))
                                            (concat "file://" default-directory))
                            reload charset post-data referer handler element))
             (t (w3m-message "No URL at point")))))
         ((w3m-url-valid url)
          (w3m-buffer-setup)            ; Setup buffer.
          (w3m-arrived-setup)            ; Setup arrived database.
          (unless no-popup
            (w3m-popup-buffer (current-buffer)))
          (w3m-cancel-refresh-timer (current-buffer))
          (when w3m-current-process
            (error "%s"
                   (substitute-command-keys "
Cannot run two w3m processes simultaneously \
\(Type `\\<w3m-mode-map>\\[w3m-process-stop]' to stop asynchronous process)")))
          (w3m-process-stop (current-buffer))    ; Stop all processes retrieving images.
          (w3m-idle-images-show-unqueue (current-buffer))
          ;; Store the current position in the history structure if and only
          ;; if this command is called interactively.  The other user commands
          ;; that calls this function want to store the position by themselves.
          (when (w3m-interactive-p)
            (w3m-history-store-position))
          ;; Access url group
          (if (string-match "\\`group:" url)
              (let ((urls (mapcar 'w3m-url-decode-string
                                  (split-string (substring url (match-end 0)) "&")))
                    (w3m-async-exec (and w3m-async-exec-with-many-urls
                                         w3m-async-exec))
                    buffers)
                (w3m-process-do
                    (type (save-window-excursion
                            (prog1
                                (w3m-goto-url (pop urls))
                              (dotimes (i (length urls))
                                (push (w3m-copy-buffer nil nil nil 'empty) buffers))
                              (dolist (url (nreverse urls))
                                (with-current-buffer (pop buffers)
                                  (w3m-goto-url url))))))
                  type))
            ;; Retrieve the page.
            (lexical-let ((orig url)
                          (url (w3m-url-strip-authinfo url))
                          (reload (and (not (eq reload 'redisplay)) reload))
                          (redisplay (eq reload 'redisplay))
                          (charset charset)
                          (post-data post-data)
                          (referer referer)
                          (name)
                          (history-position (get-text-property (point)
                                                               'history-position))
                          (reuse-history w3m-history-reuse-history-elements))
              (when w3m-current-forms
                ;; Store the current forms in the history structure.
                (w3m-history-plist-put :forms w3m-current-forms))
              (let ((w3m-current-buffer (current-buffer)))
                (unless element
                  (setq element
                        (if (and (equal referer "about://history/")
                                 history-position)
                            (w3m-history-element history-position t)
                          (if w3m-history-reuse-history-elements
                              (w3m-history-assoc url)))))
                ;; Set current forms using the history structure.
                (when (setq w3m-current-forms
                            (when (and (not reload) ; If reloading, ignore history.
                                       (null post-data) ; If post, ignore history.
                                       (or (w3m-cache-available-p url)
                                           (w3m-url-local-p url)))
                              ;; Don't use `w3m-history-plist-get' here.
                              (plist-get (nthcdr 3 element) :forms)))
                  ;; Mark that the form is from history structure.
                  (setq w3m-current-forms (cons t w3m-current-forms)))
                (when (and post-data element)
                  ;; Remove processing url's forms from the history structure.
                  (w3m-history-set-plist (cadr element) :forms nil))
                ;; local directory URL check
                (when (and (w3m-url-local-p url)
                           (file-directory-p (w3m-url-to-file-name url))
                           (setq url (file-name-as-directory url))
                           (eq w3m-local-directory-view-method 'w3m-dtree)
                           (string-match "\\`file:///" url))
                  (setq url (replace-match "about://dtree/" nil nil url)
                        orig url))
                ;; Split body and fragments.
                (w3m-string-match-url-components url)
                (and (match-beginning 8)
                     (setq name (match-string 9 url)
                           url (substring url 0 (match-beginning 8))))
                (when (w3m-url-local-p url)
                  (unless (string-match "[^\000-\177]" url)
                    (setq url (w3m-url-decode-string url))))
                (w3m-process-do
                    (action
                     (if (and (not reload)
                              (not redisplay)
                              (stringp w3m-current-url)
                              (string= url w3m-current-url))
                         (progn
                           (w3m-refontify-anchor)
                           'cursor-moved)
                       (when w3m-name-anchor-from-hist
                         (w3m-history-plist-put
                          :name-anchor-hist
                          (append (list 1 nil)
                                  (and (integerp (car w3m-name-anchor-from-hist))
                                       (nthcdr (1+ (car w3m-name-anchor-from-hist))
                                               w3m-name-anchor-from-hist)))))
                       (setq w3m-name-anchor-from-hist
                             (plist-get (nthcdr 3 element) :name-anchor-hist))
                       (setq w3m-current-process
                             (w3m-retrieve-and-render orig reload charset
                                                      post-data referer handler))))
                  (with-current-buffer w3m-current-buffer
                    (setq w3m-current-process nil)
                    (if (not action)
                        (progn
                          (w3m-history-push w3m-current-url
                                            (list :title (or w3m-current-title
                                                             "<no-title>")))
                          (goto-char (point-min)))
                      (w3m-string-match-url-components w3m-current-url)
                      (and (match-beginning 8)
                           (setq name (match-string 9 w3m-current-url)))
                      (when (and name
                                 (progn
                                   ;; Redisplay to search an anchor sure.
                                   (sit-for 0)
                                   (w3m-search-name-anchor
                                    name nil (not (eq action 'cursor-moved)))))
                        ;;debug (setf (w3m-arrived-time (w3m-url-strip-authinfo orig)) (w3m-arrived-time url))
                        )
                      (unless (eq action 'cursor-moved)
                        (if (equal referer "about://history/")
                            ;; Don't sprout a new branch for the existing history
                            ;; element.
                            (let ((w3m-history-reuse-history-elements t))
                              (w3m-history-push w3m-current-url
                                                (list :title w3m-current-title))
                              ;; Fix the history position pointers.
                              (when history-position
                                (setcar w3m-history
                                        (w3m-history-regenerate-pointers
                                         history-position))))
                          (let ((w3m-history-reuse-history-elements reuse-history)
                                (position (when (eq 'reload reuse-history)
                                            (cadar w3m-history))))
                            (w3m-history-push w3m-current-url
                                              (list :title w3m-current-title))
                            (when position
                              (w3m-history-set-current position))))
                        (w3m-history-add-properties (list :referer referer
                                                          :post-data post-data))
                        (unless w3m-toggle-inline-images-permanently
                          (setq w3m-display-inline-images
                                w3m-default-display-inline-images))
                        (when (and w3m-use-form reload)
                          (w3m-form-textarea-files-remove))
                        (cond ((w3m-display-inline-images-p)
                               (and w3m-force-redisplay (sit-for 0))
                               (w3m-toggle-inline-images 'force reload))
                              ((and (w3m-display-graphic-p)
                                    (eq action 'image-page))
                               (and w3m-force-redisplay (sit-for 0))
                               (w3m-toggle-inline-image 'force reload)))))
                    (setq buffer-read-only t)
                    (set-buffer-modified-p nil)
                    (setq list-buffers-directory w3m-current-title)
                    ;; must be `w3m-current-url'
                    (setq default-directory (w3m-current-directory w3m-current-url))
                    (w3m-buffer-name-add-title)
                    (w3m-update-toolbar)
                    (w3m-select-buffer-update)
                    (let ((real-url (if (w3m-arrived-p url)
                                        (or (w3m-real-url url) url)
                                      url)))
                      (run-hook-with-args 'w3m-display-functions real-url)
                      (run-hook-with-args 'w3m-display-hook real-url))
                    (w3m-session-crash-recovery-save)
                    (when (and w3m-current-url
                               (stringp w3m-current-url)
                               (or (string-match
                                    "\\`about://\\(?:header\\|source\\)/"
                                    w3m-current-url)
                                   (equal (w3m-content-type w3m-current-url)
                                          "text/plain")))
                      (setq truncate-lines nil))
                    ;; restore position must call after hooks for localcgi.
                    (when (or reload redisplay)
                      (w3m-history-restore-position))
                    (w3m-set-buffer-unseen)
                    (w3m-refresh-at-time)))))))
         (t (w3m-message "Invalid URL: %s" url))))

      )
  (message "w3m not found")
  );if
(provide 'my_w3m)
;;; my_w3m.el ends here
