;;; my_swoop.el: --- ""
;;; Commentary:
;;; Code:

(require 'swoop)

;;
; swoop-last-query-plain; length
; exit-minibuffer ; restore default minibuffer size. Don't know why minibuffer contents is $results
;; should set minbuffer-hight
;;
;; swoop
(defadvice swoop (before swoop-trim-region activate )
  "Usually I don't search text having more than 2 lines."
  (when (> (length swoop-minibuf-last-content) 300)
    (message "swoop %s, trimmed " (length swoop-minibuf-last-content) )
    (sit-for 2)
    (setq swoop-minibuf-last-content nil)
    (message "swoop-minibuf-last-content is trimmed."); debug
    )
  )

(global-set-key (kbd "C-S-s") 'swoop) ; fail to search chars like  ', [ ,
;; (global-set-key (kbd "C-s") 'isearch-forward)

;; (defun swoop-pre-input (&optional $resume)
;;   "Pre input function. Utilize region and at point symbol"
;;   (let ($results)
;;     (if $resume
;;         (setq $results swoop-last-query-plain)
;;       (setq $results (cond (mark-active
;;                             (buffer-substring-no-properties
;;                              (region-beginning) (region-end)))
;;                            ((funcall swoop-pre-input-point-at-function:))
;;                            (t nil)))
;;       (deactivate-mark)
;;       (when $results
;;         (setq $results (replace-regexp-in-string "\*" "\\\\*" $results))
;;         (setq $results (replace-regexp-in-string "\+" "\\\\+" $results))))
;;     $results))
;;
;; ;; swoop-edit
;; (defun swoop-edit-sync ($beg $end $length)
;;   (save-excursion
;;     (goto-char $beg)
;;     (let* (($line-beg (point-at-bol))
;;            ($marker (get-text-property $line-beg 'swm))
;;            ($buf (marker-buffer $marker))
;;            $col)
;;       (when (and (get-text-property $line-beg 'swp)
;;                  (not (get-text-property $end 'swp)))
;;         (when (= $length 0)
;;           (put-text-property $beg $end 'swm $marker)
;;           (save-excursion
;;             (and (re-search-forward "\n" $end t)
;;                  (delete-region (1- (point)) $end))))
;;         (let* (($line (- (line-number-at-pos)
;;                         (line-number-at-pos (window-start))))
;;                ($readonly (with-current-buffer $buf buffer-read-only))
;;                ($win (or (get-buffer-window $buf)
;;                         (display-buffer $buf
;;                                         '(nil (inhibit-same-window . t)
;;                                               (inhibit-switch-frame . t)))))
;;                ($line-end (point-at-eol))
;;                ($text (save-excursion
;;                        (goto-char (next-single-property-change
;;                                    $line-beg 'swp nil
;;                                    $line-end))
;;                        (setq $col (- (point) $line-beg))
;;                        (buffer-substring-no-properties (point) $line-end))))
;;           (with-selected-window $win
;;             (goto-char $marker)
;;             ;; Unveil invisible block
;;             (swoop-mapc $ov
;;                 (overlays-in (point-at-bol)
;;                              (point-at-eol))
;;               (let (($type (overlay-get $ov 'invisible)))
;;                 (when $type
;;                   (overlay-put $ov 'invisible nil))))
;;             (recenter $line)
;;             (if $readonly
;;                 (message "Buffer `%s' is read only." $buf)
;;               (delete-region (point-at-bol) (point-at-eol))
;;               (insert $text))
;;             (move-to-column $col)))))))
;;
(provide 'my_swoop)
;;; my_swoop.el ends here
