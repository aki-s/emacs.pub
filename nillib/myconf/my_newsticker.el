;;;; http://dev.ariel-networks.com/wp/documents/aritcles/emacs/part11
(setq newsticker-url-list
      '(
        ("Slashdot" "http://rss.slashdot.org/Slashdot/slashdot")
        ("TechCrunch" "http://feeds.feedburner.com/TechCrunch")
        ))
(autoload ‘w3m-region “w3m” nil t)
(setq newsticker-html-renderer ‘w3m-region)

(newsticker-show-news); init
(provide 'my_newsticker)
