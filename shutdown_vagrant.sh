#!/bin/bash

vagrant_dir=~/Vagrant/

for VM in `ls ${vagrant_dir}`
do
  echo "Do you want to shutdown ${VM}？　Please input \"y\" or \"n\""
  read yn

  if [ $yn = y ]; then
    cd ${vagrant_dir}${VM}/
    vagrant status | grep poweroff > /dev/null
    VMSTATE=$?

    case ${VMSTATE} in
      0)
        echo "THE VM ${VM} is stopped."
        ;;
      1)
        vagrant halt && echo "Shutdown of the VM ${VM} is completed."
        ;;
    esac

  elif [ $yn = n ]; then
    echo "Cancel VM ${VM} shutdown."
  else
    echo "Please input \"y\" or \"n\""
  fi
done

echo "Display VM's state."
vagrant global-status
