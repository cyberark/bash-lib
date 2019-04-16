#!/bin/bash

: "${BASH_LIB:?BASH_LIB must be set. Please source bash-lib/init.sh before other scripts from bash-lib.}"

# Get the top level of a git repo
function repo_root(){
    git rev-parse --show-toplevel
}

# List files tracked by git
function all_files_in_repo(){
    git ls-tree -r HEAD --name-only
}