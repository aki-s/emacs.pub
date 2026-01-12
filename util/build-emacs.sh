#;;;  Ubuntu
sudo apt install build-essential texinfo libx11-dev libxpm-dev libjpeg-dev libpng-dev libgif-dev libtiff-dev libgtk2.0-dev libncurses-dev auto-make
cd $HOME/.emacs.d/src/emacs
export LIBPATH=
export INCLUDE=

make distclean
autoreconf -i -I m4 && ./configure && make && make install
#; make bootstrap && ./configure && make && make install

#; Darwin
cd $HOME/.emacs.d/src/emacs
./autogen.sh
./configure  --prefix=$HOME/local --with-gif=no && make && make install

