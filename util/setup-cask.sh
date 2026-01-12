curl -fsSkL https://raw.github.com/cask/cask/master/go | python

if [ `which cask` ];then
 cd $HOME/.emacs.d/
 cask
fi
