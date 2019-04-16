#!/bin/bash

: "${BASH_LIB:?BASH_LIB must be set. Please source bash-lib/init.sh before other scripts from bash-lib.}"
. "${BASH_LIB}/helpers/lib.sh"

#https://stackoverflow.com/a/23002317
function abs_path() {
    # generate absolute path from relative path
    # $1     : relative filename
    # return : absolute path
    if [ -d "$1" ]; then
        # dir
        (spushd "$1"; pwd)
    elif [ -f "$1" ]; then
        # file
        if [[ $1 = /* ]]; then
            echo "$1"
        elif [[ $1 == */* ]]; then
            echo "$(spushd "${1%/*}"; pwd)/${1##*/}"
        else
            echo "$(pwd)/$1"
        fi
    fi
}