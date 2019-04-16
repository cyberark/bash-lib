#!/bin/bash

# This script is an entry point, so init
# is not assumed to have been run

# shellcheck disable=SC2086,SC2046
. $(dirname ${BASH_SOURCE[0]})/../init.sh
. "${BASH_LIB}/helpers/lib.sh"

rc=0

spushd ${BASH_LIB}/tests-for-this-repo/python-lint
    docker build . -t pytest-flake8
    docker run -v "${BASH_LIB}:/mnt" pytest-flake8 || rc=1
    mv "${BASH_LIB}/junit.xml" "${BASH_LIB}/python-lint-junit.xml"
spopd

exit ${rc}