GIT=git
EMACSDIR=$HOME/.emacs.d

#;
UPDATE_CMD='update --init  --depth 1'

checkoutExternal () {
local msg="Setup git submodule...."
echo $msg
    cd ${EMACSDIR}
    ${GIT} submodule foreach --recursive ${GIT} checkout master
    ${GIT} submodule ${UPDATE_CMD} # This process should be concurrent
    ${GIT} submodule foreach --recursive ${GIT} submodule ${UPDATE_CMD} # This process should be concurrent
echo $msg done
}

checkoutExternal

#;

sh ${EMACSDIR}/util/setup-cask.sh
