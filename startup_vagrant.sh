#!/bin/bash

## environment variable
VAGRANT_DIR=~/Vagrant/

## all VMs startup
read -p "Do you want to start all VMs? input \"y\" or \"n\"" yn

if [ ${yn} = y ]; then
  for VM in `ls ${VAGRANT_DIR}`;
  do
    cd ${VAGRANT_DIR}${VM}/
    VM_STATUS=`vagrant status | grep default | awk '{ print $2 }'`
    if [ ${VM_STATUS} = "poweroff" ]; then
      vagrant up > /dev/null && echo "##### VM \"${VM}\" is started. #####" 
    elif [ ${VM_STATUS} = "running" ]; then
      echo "##### VM \"${VM}\" is already running. #####"
    elif [ ${VM_STATUS} = "saved" ]; then
      vagrant resume > /dev/null && echo "##### VM \"${VM}\" resumed from suspend. #####"
    else
      vagrant up > /dev/null && echo "##### VM \"${VM}\" is started from aborted. #####" 
    fi
  done
elif [ ${yn} = n ]; then
  echo "select VM to be activated."
  for VM in `ls ${VAGRANT_DIR}`;
  do
    read -p "Do you want to startup VM \"${VM}\"? input \"y\" or \"n\"" yn
    if [ ${yn} = y ]; then
      cd ${VAGRANT_DIR}${VM}/
      VM_STATUS=`vagrant status | grep default | awk '{ print $2 }'`
      if [ ${VM_STATUS} = "poweroff" ]; then
        vagrant up > /dev/null && echo "##### VM \"${VM}\" is started. #####" 
      elif [ ${VM_STATUS} = "running" ]; then
        echo "##### VM \"${VM}\" is already running. #####"
      elif [ ${VM_STATUS} = "saved" ]; then
        vagrant resume > /dev/null && echo "##### VM \"${VM}\" resumed from suspend. #####"
      else
        echo "##### UNKNOWN STATUS #####"
      fi
    elif [ ${yn} = n ]; then
      echo "##### Starting VM \"${VM}\" was canceled. #####"
    else
      echo "input \"y\" or \"n\""
    fi
  done
else
    echo "input \"y\" or \"n\""
fi

## Processing after startup
echo "##### Display VM's state. #####"
vagrant global-status
