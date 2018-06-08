#!/bin/bash

# ENVIRONMENT VARIABLE
SRC_DIR="/home/hatano/rsync/"
DEST_USER="root"
DEST_HOST="192.168.10.151"
DEST_DIR="/home/hatano/rsync/"
LOG_FILE="log_`date "+%Y%m%d_%H%M%S.log"`"
MAIL_ADDRESS="root@localhost"

# RSYNC PRE TEST
ssh ${DEST_USER}@${DEST_HOST} 'exit'> /dev/null 2>&1
SSH_STATUS=$?

case ${SSH_STATUS} in
  0) echo "ssh is OK."
     echo "Do you want to run rsync? input y or n"
     read yn ;;
  *) echo "ssh is NG."
     exit 0 ;;
esac

# RUN RSYNC
case ${yn} in
  "y") echo "rsync will be started."
       rsync -az --delete --log-file=${LOG_FILE} ${SRC_DIR} ${DEST_USER}@${DEST_HOST}:${DEST_DIR}
       RSYNC_STATUS=$? ;;
  "n") echo "rsync was canceled."
       exit 0 ;;
esac

if [ ! ${RSYNC_STATUS} = 0 ]; then
  while [ ${RSYNC_STATUS} = 0 ]; do
    echo " ##### rsync retry #####"
    rsync -az --delete --log-file=${LOG_FILE} ${SRC_DIR} ${DEST_USER}@${DEST_HOST}:${DEST_DIR}
    RSYNC_STATUS=$?
  done
else
  echo "rsync was successful."
fi
