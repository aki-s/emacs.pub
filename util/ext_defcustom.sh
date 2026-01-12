#;; TODO
#;  multi line support
if [ $# -lt 1 ];then
 echo "$0 .el-files"
 exit
fi

echo "(set-custom-variables"

# /home/bi912101/.emacs.d/share/evil/evil-vars.el:(defcustom evil-intercept-maps
 #egrep defcustom $@ | sed -r  -e '/[:space:]*;/d' -e "s:\(defcustom (.*): '\(\1\):" -e "s/(.*):(.*)/\2 ;; \1/p"
#egrep '^[[:space:]]*\([[:space:]]*defcustom' $@ | sed -nr  -e '/^[:space:]*;/d' -e "s:\(defcustom (.*): '\(\1\):" -e 's/(.*):(.*)/\2 ;; \1/' -e "s:$HOME:\~:p"
egrep '^[[:space:]]*\([[:space:]]*defcustom' $@ | sed -nr  -e '/^[:space:]*;/d' -e "{ s:\(defcustom (.*): '\(\1\): ;  s/(.*):(.*)/\2 ;; \1/ ; s:$HOME:\~: ; p}"

echo ")"
