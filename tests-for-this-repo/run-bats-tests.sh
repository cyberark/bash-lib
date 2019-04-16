#!/bin/bash

set -euo pipefail

# This script runs the self tests for the bash-lib repo.

# This script is an entry point, so init
# is not assumed to have been run
# shellcheck disable=SC2086,SC2046
. $(dirname ${BASH_SOURCE[0]})/../init.sh
. "${BASH_LIB}/test-utils/lib.sh"
. "${BASH_LIB}/helpers/lib.sh"


# Check vital tools are installed
command -v summon >/dev/null || die "Summon must be installed and configured in order to run tests"
command -v docker >/dev/null || die "Docker must be installed and configured in order to run tests"

# could be tap, junit or pretty
readonly BATS_OUTPUT_FORMAT="${BATS_OUTPUT_FORMAT:-pretty}"
readonly BATS_SUITE="${BATS_SUITE:-BATS}"
readonly TAP_FILE="${BASH_LIB}/bats.tap"

# return code
rc=0

if [[ ${#} == 0 ]]
then
    echo "No test scripts specified, running all."
    scripts="${BASH_LIB}/tests-for-this-repo/*.bats"
else
    scripts="${*}"
fi

readonly summon_cmd="summon -f ${BASH_LIB}/secrets.yml"

case $BATS_OUTPUT_FORMAT in
    pretty)
        # shellcheck disable=SC2086
        ${summon_cmd} ${BATS_CMD} ${scripts} || rc=1
    ;;
    tap|junit)
        # shellcheck disable=SC2086
        ${summon_cmd} ${BATS_CMD} ${scripts} >${TAP_FILE} || rc=1
        echo "TAP Output written to ${TAP_FILE}"
    ;;
    *)
        echo "Invalid BATS_OUTPUT_FORMAT: ${BATS_OUTPUT_FORMAT}, valid options: pretty, junit, tap."
        exit 1
    ;;
esac

#Convert TAP to Junit when required
if [[ "${BATS_OUTPUT_FORMAT}" == junit ]]
then
    # Run tap-junit docker image to convert BATS TAP output to Junit for consumption by jenkins
    readonly  JUNIT_FILE="${BASH_LIB}/${BATS_SUITE}-junit.xml"
    tap2junit < "${TAP_FILE}" > "${JUNIT_FILE}"
    echo "Junit output written to ${JUNIT_FILE}"
fi

exit ${rc}