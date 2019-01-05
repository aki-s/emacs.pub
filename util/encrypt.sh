#!/bin/sh
#@dev

ENC=`which openssl`
ENCOPT='rsautl -encrypt -inkey ~/.ssh/id_rsa' 
KEYFILE=$HOME/.ssh/id_rsa

target=`cat src/encrypt.lst|grep -v '#'|tr '\n' ' ' `

for i in $target;do
 mv $i $i.org
 $ENC $ENCOPT -in $i.org >$i
 rm $i.org
done

