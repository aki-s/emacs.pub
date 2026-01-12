## About this repository
This branch is my emacs configuration (.emacs.d ) extracted from private .emacs.d .

- Pushing to this repository is almostly automated with `util/push-emacs.sh` (auto commit by destroying all history).
  - I have recommitted to this git repository to clear private or secret information from source code, so no actual history would be visible.
- Just clone and placing `.emacs.d` is not sufficient because of the following reasons.

1. Error handling in config file for missing `shell environmental variable` is not done (I use my private .bashrc).
1. Some config file enforce you have already installed binary commands
such as [git-crypt](https://github.com/AGWA/git-crypt) (I also privately manage this setup).
1. This repository is extracted from my private repository.
   Some files like as under share/dict/ is omitted from the view point of license.

__Main files of this branch is__

- [nil.el called from init.el](https://github.com/aki-s/emacs.pub/tree/master/nil.el)
- [Lists of configured elisp libraries for my emacs](https://github.com/aki-s/emacs.pub/tree/master/nillib/myconf)
- [Cask](https://github.com/aki-s/emacs.pub/tree/master/Cask)

-----------

## How to check out and try this repository as $HOME/.emacs.d

#### __Prerequisite__

    - Unix liked system (sh,sed,etc...)
    - Emacs version 30
    - Git    ; To install emacs
    - Python ; To install emacs package manager called 'cask'
    - cURL   ; To install emacs package manager called 'cask'

#### __Setup__

    $ git clone https://github.com/aki-s/emacs.pub.git $HOME/.emacs.d

then

    # Automated setup.
    $ $HOME/.emacs.d/util/setup-emacs.pub.sh

or

    # Manual setup
    $ cd $HOME/.emacs.d
    $ #OPTIONAL: brew install git-lfs age
    $ #OPTIONAL: git lfs pull
    $ git submodule update --init
    $ git submodule foreach --recursive git submodule update --init
    $ $HOME/.cask/bin/cask # or `$ brew install cask`

-----------

## __The reason for making this repository public.__

#### _To help somebody who may google for what he/she want to improve about his/her emacs._

> [!WARNING]
> My SHAMES of customizing Emacs (terrible codes) is intentionally exposed only for this reason.

> [!NOTE]
> The conventional manner of writing ELisp is NOT intentionally followed just only for my tastes.
> Some files recently added are not yet tidy up, because this repo is just a snapshot and it could be a draft version.

> [!IMPORTANT]
> My main editor is IntelliJ (sometimes VSCode) since around 2014 actually. I only use Emacs as a simple notepad now...
>
>  I recommend niewbies to use [Spacemacs](https://github.com/syl20bnr/spacemacs) or Aquamacs at least, although I dont' recommend using Emacs.
>  This editor is too old fashioned...
>  But I sometimes tries new features of Emacs or tidy up past configurations by whim as my hobbie...

-----------
