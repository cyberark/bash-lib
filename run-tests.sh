#!/bin/bash

# This script is an entry point, so init
# is not assumed to have been run
# shellcheck disable=SC2086
. "$(dirname ${BASH_SOURCE[0]})/init.sh"
. "${BASH_LIB}/helpers/lib.sh"

# Run BATS Tests
"${BASH_LIB}/tests-for-this-repo/run-bats-tests.sh"

# Run Python Lint
"${BASH_LIB}/tests-for-this-repo/python-lint.sh"
