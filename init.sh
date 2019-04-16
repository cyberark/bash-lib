#!/bin/bash

## Initialisation Functions for the
## Conjurinc Bash Library

# Shell Otions
set -euo pipefail

# This script should be sourced before any of
# the other scripts in this repo. Other scripts
# make use of ${BASH_LIB} to find each other.

# Get the relative path to the repo root
# shellcheck disable=SC2086
BASH_LIB_RELATIVE="$(dirname ${BASH_SOURCE[0]})"

# Must be set in order to load the filehandling
# module. Will be updated when abs_path is available.
BASH_LIB="${BASH_LIB_RELATIVE}"

# Load the filehandling module for the abspath
# function
. "${BASH_LIB_RELATIVE}/filehandling/lib.sh"

# Export the absolute path
# shellcheck disable=SC2086
BASH_LIB="$(abs_path ${BASH_LIB_RELATIVE})"
export BASH_LIB

. "${BASH_LIB}/helpers/lib.sh"

# Update Submodules
spushd "${BASH_LIB}"
    git submodule update --init --recursive
spopd

export BATS_CMD="${BASH_LIB}/test-utils/bats/bin/bats"