#!/bin/bash

vagrant_dir=~/Vagrant/

for VM in `ls ${vagrant_dir}`
do
  echo "Do you want to startup ${VM}？　Please input \"y\" or \"n\""
  read yn

  if [ $yn = y ]; then
    cd ${vagrant_dir}${VM}/
    vagrant status | grep poweroff > /dev/null
    VMSTATE=$?

    case ${VMSTATE} in
      0)
        vagrant up && echo "VM ${VM} is started."
        ;;
      1)
        echo "VM ${VM} is running."
        ;;
    esac

  elif [ $yn = n ]; then
    echo "Starting VM ${VM} was canceled."
  else
    echo "Please input \"y\" or \"n\""
  fi
done

echo "Display VM's state."
vagrant global-status
