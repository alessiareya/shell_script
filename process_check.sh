#!/bin/bash

SERVICE="httpd.service"

while true; do
  HTTPD_CHECK=`ps aux | grep httpd | grep -v grep | wc -l`

  if [ ${HTTPD_CHECK} = 0 ]; then
    systemctl status httpd.service > /dev/null 2>&1
    HTTPD_STATUS=$?
    case ${HTTPD_STATUS} in
      "0")
        echo "${SERVICE} is alived."
        ;;
      *)
        /usr/sbin/httpd -t 2>&1 | grep -i "syntax error"
        CONFIG_STATUS=$?
        if [ ${CONFIG_STATUS} = 0 ]; then
          echo "Please Check httpd.conf"
          exit 0
        elif [ ${CONFIG_STATUS} = 1 ]; then
          systemctl start httpd.service > /dev/null 2>&1
          echo "${SERVICE} is started."
        else
          echo "Please Check error_log."
          exit 0
        fi
        ;;
    esac
  elif [ ${HTTPD_CHECK} > 0 ]; then
    echo "${SERVICE} is alived"
    sleep 5
  else
    :
  fi
done
