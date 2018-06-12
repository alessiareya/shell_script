#!/bin/bash

TARGET_DIR="/home/data/"

if [ $# -ne 1 ]; then
  echo "ARGUMENT ERROR"
  exit
fi

for i in `cat $1`
do

done
  USERNAME=(`cut -d "," -f 1 $1`)
  OLD_UID=`cut -d "," -f 2 $1`
  NEW_UID=`cut -d "," -f 3 $1`
  echo ${USERNAME[*]}

if [ ! -d "newid" ]; then
  for i in ${USERNAME}
  do
    mkdir -p newuid/$i
  done
fi

read -p "CHANGE UID? input y or n " yn
if [ $yn = y ]; then
  find -P ${TARGET_DIR} -uid ${OLD_UID} -exec chown -h ${NEW_UID} {} \; | tee newid/${USERNAME}_newuid.list
elif [ $yn = n ]; then
  echo "NO CHANGE UID."
else
  echo "input y or n"
fi

#echo "CHANGE GID? input y or n"
#read yn
#if [ yn = y ]; then
#  find -P ${TARGET_DIR} -type f -uid ${OLD_GID } -exec chgrp -h ${ NEW_GUID } {} \; | tee ${USERNAME}/${USERNAME}_newgid.list
#elif [ yn = n ]; then
#  echo "NO CHANGE UID."
#else
#  echo "input y or n"
#fi
