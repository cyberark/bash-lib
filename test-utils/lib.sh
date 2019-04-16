#!/bin/bash

: "${BASH_LIB:?BASH_LIB must be set. Please source bash-lib/init.sh before other scripts from bash-lib.}"
. "${BASH_LIB}/git/lib.sh"
. "${BASH_LIB}/helpers/lib.sh"

readonly SHELLCHECK_IMAGE="${SHELLCHECK_IMAGE:-koalaman/shellcheck}"
readonly SHELLCHECK_TAG="${SHELLCHECK_TAG:-v0.6.0}"

# Check a single shell script for syntax
# and common errors.
function shellcheck_script(){
    # NOTE (HughSaunders): I tried using the checkstyle output of
    # _shellcheck along with a checkstyle2junit xslt stylesheet
    # from the shellcheck author. However Jenkins only reported
    # on error per file, as the style sheet created a test element
    # per file, with mulitple failure elements within.
    # Jenkins expects one failure element per test.

    local -r script="${1}"
    echo -e "\nChecking ${script}"

    # SC1091 - sourced scripts are not followed, ok because all scripts in the repo are found.
    # SC1090 - can't follow non-constant source, ok for because all scripts are checked.
    local -r ignores="-e SC1091 -e SC1090"
    # shellcheck disable=SC2086
    bash -n "${script}" && \
        docker run -v "${PWD}:/mnt" ${SHELLCHECK_IMAGE}:${SHELLCHECK_TAG} ${ignores} ${script}
}

function find_scripts(){
    all_files_in_repo | grep '.sh$'
}

function tap2junit(){
    local -r suite="${1:-BATS}"

    spushd "${BASH_LIB}/test-utils/tap2junit"
        docker build . -t tap-junit 1>&2
    spopd

    # Run tap-junit docker image to convert BATS TAP output to Junit for consumption by jenkins
    # filters stdin to stdout
    docker run -i tap-junit -s "${suite}"
}
