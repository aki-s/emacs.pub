#-------------------------------------
# defun
#-------------------------------------
confirm () {
    printf "Your answer [y/n] : "
    read yesno
    if [ "x$yesno" = "xy" -o "x$yesno" = "xY"  ];then
        echo
    else
        echo "Abort.. "
        exit 1
    fi
}

check () {
    local badconfig=0

    echo "
COMMIT_COMMENT IS : ${COMMIT_COMMENT}
Does remote "
    echo $REPOS|tr '[:space:]' '\n' 
    echo " already exists? "
    confirm

    echo "Executing $0"

    OS=`uname`
    if [ "x$OS" = "xLinux" -o "x$OS" = "xDarwin" ];then
        CPOPT=${CPOPT:='-a'} # no more need '-v' option
    else
        echo "[ERROR] OS other than Linux and Darwin is TBD..."
        exit 1 
    fi
}
