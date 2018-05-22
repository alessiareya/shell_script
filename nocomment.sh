#!/bin/bash

if [ $# = 1 ]; then
  grep -v "^\s*#" $1 | grep -v "^\s*$"
else
  echo "ARGUMENT ERROR"
fi
