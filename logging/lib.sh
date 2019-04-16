#!/bin/bash

: "${BASH_LIB:?BASH_LIB must be set. Please source bash-lib/init.sh before other scripts from bash-lib.}"

# Add logging functions here

function announce() {
  echo "++++++++++++++++++++++++++++++++++++++"
  echo " "
  echo "$@"
  echo " "
  echo "++++++++++++++++++++++++++++++++++++++"
}