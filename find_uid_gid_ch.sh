#!/bin/bash

TARGET_DIR="/data/"

if [ $# -ne 1 ]; then
  echo "ARGUMENT ERROR"
  exit
fi

read -p "CHANGE UID? input y or n " yn
if [ $yn = y ]; then
  for i in `cat $1`
  do
    USERNAME=`echo $i | cut -d "," -f 1`
    OLD_UID=`echo $i | cut -d "," -f 2`
    NEW_UID=`echo $i | cut -d "," -f 3`
    mkdir -p changeid/${USERNAME}
    find -P ${TARGET_DIR} -uid ${OLD_UID} -exec chown -h ${NEW_UID} {} \; | tee changeid/${USERNAME}/changeid.list
  done
elif [ $yn = n ]; then
  echo "NO CHANGE UID."
else
  echo "input y or n"
fi

read -p "CHANGE GID? input y or n " yn
if [ $yn = y ]; then
  for i in `cat $1`
  do
    USERNAME=`echo $i | cut -d "," -f 1`
    OLD_GID=`echo $i | cut -d "," -f 2`
    NEW_GID=`echo $i | cut -d "," -f 3`
