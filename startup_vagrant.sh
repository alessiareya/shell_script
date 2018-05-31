#!/bin/bash

## environment variable
VAGRANT_DIR=~/Vagrant/

## all VMs startup
echo "Do you want to start all VMs? input \"y\" or \"n\""
read yn

if [ ${yn} = y ]; then
  for VM in `ls ${VAGRANT_DIR}`;
  do
    cd ${VAGRANT_DIR}${VM}/
    vagrant status | grep poweroff > /dev/null
    VM_STATE=$?
    case ${VM_STATE} in
      0)
        vagrant up && echo "VM \"${i}\" is started." ;;
      1)
        echo "VM \"${VM}\" is already running." ;;
    esac
  done
elif [ ${yn} = n ]; then
  echo "select VM to be activated."
  for VM in `ls ${VAGRANT_DIR}`;
  do
    echo "Do you want to startup VM \"${VM}\"? input \"y\" or \"n\""
    read yn
    if [ ${yn} = y ]; then
      cd ${VAGRANT_DIR}${VM}/
      vagrant status | grep poweroff > /dev/null
      VMSTATE=$?
      case ${VMSTATE} in
        0)
          vagrant up && echo "VM \"${VM}\" is started." ;;
        1)
          echo "VM \"${VM}\" is already running." ;;
      esac
    elif [ ${yn} = n ]; then
      echo "Starting VM \"${VM}\" was canceled."
    else
      echo "input \"y\" or \"n\""
    fi
  done
else
    echo "input \"y\" or \"n\""
fi

## Processing after startup
echo "Display VM's state."
vagrant global-status
