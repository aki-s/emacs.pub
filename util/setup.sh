#!/bin/sh
OS=`uname -s`
EMACSDIR=$HOME/.emacs.d
LOCAL=$HOME/local
DIRNAME=`dirname $0`
SETUPLOG=/tmp/setup.sh.log


#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
isCommandExist() {
    local command=$1
    if [ ! `which ${command}` ];then
        echo "No ${command} installed"
        exit 1
    fi
}

isHomeBrew() {
  [ -x /usr/local/bin/brew ]
}

isMacPorts() {
  [ -x /opt/local/bin/port ]
}

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
echo setup is to be stored in ${SETUPLOG}

#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mkdir -p $HOME/bin
mkdir -p ${LOCAL}


####; Emacs
cd ${DIRNAME}
echo setup emacs
./_setup-emacs.priv.sh 2>&1 >>${SETUPLOG}
cd - >/dev/null

if [ ! -x $HOME/bin/mvn ];then
 ln -s $HOME/.emacs.d/share/maven/bin/mvn $HOME/bin/mvn
fi


##; REDHAT
# yum install cpan

##; permission
# cpan > o conf make_install_make_command 'sudo make'
# cpan > o conf commit

##; performace
# CPAN::SQLite
##; security
# Module::Signature

##; migemo
#;; require nkf
echo build cmigemo
isCommandExist nkf
if [ ! `which cmigemo` ]; then
  cd ${EMACSDIR}/share/cmigemo/
  ./configure --prefix=$HOME/local 2>&1 >> ${SETUPLOG}
  if [ x${OS} = "xDarwin" ];then
      MIGEMO_OPT=osx
  elif [ x${OS} = "xLinux" ];then
      MIGEMO_OPT=gcc
      #; cmigemo is provided on Ubuntu14 at least.
      # sudo apt -y install cmigemo
  fi
  make ${MIGEMO_OPT}-all
  make ${MIGEMO_OPT}-install
fi

##; python.jedi
if [ x${OS} = "xDarwin" ];then
    isMacPorts && sudo port install virtualenv_select py-virtualenv
    isHomeBrew && brew install python && pip install virtualenv
elif [ x${OS} = "xLinux" ];then
    ##; ??
    #; sudo pip3 install virtualenv_select py-virtualenv
    ##; On ubuntu:
    if [ `lsb_release -is` = "Ubuntu" ];then
        sudo apt install -y python3-pip python-virtualenv
    fi
fi

##; clang-complete-async
isCommandExist clang

if [ x${OS} = "xDarwin" ];then
    #;  sudo port install llvm-select
    #;  sudo port select --set llvm mp-llvm-3.6
    #; Macports don't provide header clang-c/Index.h, so it is unable to compile.
    #; -L/Library/Developer/CommandLineTools/usr/lib
    echo "Macports don't provide header clang-c/Index.h, so it is unable to compile."

   #;;;; Homebrew
   #; brew install llvm #; install llvm-config
        prefix=${LOCAL} make && prefix=${LOCAL} make install # this line didn't work on MacOSX
    #;Makefile: LLVM_CONFIG     := /usr/local/Cellar/llvm/3.8.1/bin/llvm-config
    #;makefile.mk: prefix = ${HOME}/local
    #;makefile.mk: bindir = ${exec_prefix}/bin/
else
    isCommandExist llvm-config
    if [ -d ${EMACSDIR}/share/clang-complete-async ];then
        prefix=${LOCAL} make && prefix=${LOCAL} make install
    else
        echo "${EMACSDIR}/share/clang-complete-async doesn't exist."
        exit 1
    fi
fi

##; Ruby
echo Setup Ruby
# gem install pry-doc pry
if [ x${OS} = "xLinux" ];then
    ##; On ubuntu:
    sudo apt install -y pry
else
    sudo gem install pry pry-doc
fi

###; less-css-mode
isCommandExist npm

##; Node.js
if [ `which npm` -a ! `which lessc` ];then
   npm install -g less
fi

###;
npm install -g tern
npm install -g acorn
