#!/bin/bash

: "${BASH_LIB:?BASH_LIB must be set. Please source bash-lib/init.sh before other scripts from bash-lib.}"

function die(){
    echo "${@}"
    exit 1
}

#safe pushd
function spushd(){
    pushd "${1}" >/dev/null || die "pushd ${1} failed :("
}

#safe popd
function spopd(){
    popd >/dev/null || die "popd failed :("
}