#!/bin/bash

# ENVIRONMENT VARIABLE
SRC_DIR="/data/"
DEST_USER="root"
DEST_HOST="192.168.10.151"
DEST_DIR="/data/"
RSYNC_OPTION="-az --delete"
KEY=~/.ssh/id_rsa
LOG_FILE="log_`date "+%Y%m%d_%H%M%S.log"`"
MAIL_ADDRESS="root@localhost"

# RSYNC PRE TEST
ssh ${DEST_USER}@${DEST_HOST} -i ${KEY} 'exit' > /dev/null
SSH_STATUS=$?

case ${SSH_STATUS} in
  0) echo "ssh check is OK."
     echo "Do you want to run rsync? input \"y\" or \"n\""
     read yn ;;
  *) echo "ssh check is NG."
     exit 0 ;;
esac

# RUN RSYNC
case ${yn} in
  "y") echo "rsync will be started."
       rsync ${RSYNC_OPTION} --log-file=${LOG_FILE} ${SRC_DIR} ${DEST_USER}@${DEST_HOST}:${DEST_DIR} > /dev/null
       RSYNC_STATUS=$? ;;
  "n") echo "rsync was canceled."
       exit 0 ;;
esac

if [ ! ${RSYNC_STATUS} = 0 ]; then
  while [ ${RSYNC_STATUS} = 0 ]; do
    echo " ##### rsync retry #####"
    rsync ${RSYNC_OPTION} --log-file=${LOG_FILE} ${SRC_DIR} ${DEST_USER}@${DEST_HOST}:${DEST_DIR} > /dev/null
    RSYNC_STATUS=$?
  done
else
  echo "rsync was successful."
fi

# after rsync count checksum, files, file size
echo "Do you count the checksum, number of files, file size from destination directory? \"y\" or \"n\""
read yn

if [ ${yn} = y ]; then
  LOCAL_CHECK_SUM=`find ${DEST_DIR} -type f -exec md5sum {} \; | sort | md5sum`
  LOCAL_COUNT_FILES=`find ${DEST_DIR} -type f | wc -l`
  LOCAL_COUNT_FILE_SIZE=`find ${DEST_DIR} -type f -printf "%p %s\n" | awk 'BEGIN { sum = 0; } { sum += $2; } END { print sum; }'`

  REMOTE_CHECK_SUM=`ssh ${DEST_USER}@${DEST_HOST} -i ${KEY} "find ${DEST_DIR} -type f -exec md5sum {} \; | sort | md5sum"`
  REMOTE_COUNT_FILES=`ssh ${DEST_USER}@${DEST_HOST} -i ${KEY} "find ${DEST_DIR} -type f | wc -l"`
  REMOTE_COUNT_FILE_SIZE=`ssh ${DEST_USER}@${DEST_HOST} -i ${KEY} "find ${DEST_DIR} -type f -printf \"%p %s\n\"" | awk 'BEGIN { sum = 0; } { sum += $2; } END { print sum; }'`

  echo "########## LOCAL HOST RESURT ##########"
  echo "checksum is \"${LOCAL_CHECK_SUM}\""
  echo "total files is \"${LOCAL_COUNT_FILES}\""
  echo "file size total is \"${LOCAL_COUNT_FILE_SIZE}\"" && echo ""

  echo "########## REMOTE HOST RESULT ##########"
  echo "checksum is \"${REMOTE_CHECK_SUM}\""
  echo "total files is \"${REMOTE_COUNT_FILES}\""
  echo "file size total is \"${REMOTE_COUNT_FILE_SIZE}\""

elif [ ${yn} = n ]; then
  echo "Processing ends."
  exit 0
else
  echo "input \"y\" or \"n\""
fi
