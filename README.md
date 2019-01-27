## About this repository (Main artifacts are not html but elisp files.)
This branch is my emacs configuration (.emacs.d ) extracted from private .emacs.d !
(There are Bunch of HTML files because I have locally manages documentations for programming languages...)

- Pushing to this repository is almostly automated with `util/push-emacs.sh` (Incremental auto commit).
- Just clone and placing `.emacs.d` is not sufficient because of the following reasons.

1. Error handling in config file for missing `shell environmental variable`
is not done (I use my private .bashrc).
1. Some config file enforce you have already installed binary commands
such as [git-crypt](https://github.com/AGWA/git-crypt) (I also privately manage this setup).

__Main files of this branch is__

- [nil.el called from init.el](https://github.com/aki-s/emacs.pub/tree/master/nil.el)
- [Lists of configured elisp libraries for my emacs](https://github.com/aki-s/emacs.pub/tree/master/nillib/myconf)
- [Cask](https://github.com/aki-s/emacs.pub/tree/master/Cask)

-----------

## How to check out and try this repository as $HOME/.emacs.d

#### __Prerequisite__

    - Unix liked system (sh,sed,etc...)
    - Emacs version 25
    - Git    ; To install emacs
    - Python ; To install emacs package manager called 'cask'
    - cURL   ; To install emacs package manager called 'cask'

#### __Setup__

    $ git clone https://akis@git.codebreak.com/akis/emacs.pub.git $HOME/.emacs.d # You may need 160M of disk space

then

    # Automated setup.
    $ $HOME/.emacs.d/util/setup-emacs.pub.sh

or

    # Manual setup
    $ cd $HOME/.emacs.d
    $ git submodule foreach --recursive git checkout master
    $ git submodule update --init
    $ git submodule foreach --recursive git submodule update --init
    $ $HOME/.cask/bin/cask

-----------

## __The reason for making this repository public.__

#### _To help somebody who may google for what he/she want to improve about his/her emacs._

    - This repository is extracted from my private repository.
      Some files like as under share/dict/ is omitted from the view point of license.

    - This repository would work on the mixture of cygwin/LINUX/MacOSX and various version of emacs.

    - I have recently started to use
      - 'cask' to maintain repository instead of git for some libraries. (under migration)
      - 'evil-mode' (vim like keybinding) to be free from emacs keybinding.

    - I have recommitted to this git repository to clear private or secret information from source codes, so no history would be visible.

-----------
