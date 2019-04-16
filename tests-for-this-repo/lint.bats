#!/bin/bash
. ${BASH_LIB}/git/lib.sh
. ${BASH_LIB}/test-utils/lib.sh
. ${BASH_LIB}/helpers/lib.sh

setup() {
    spushd ${BASH_LIB}
}

# Find and check shell scripts
@test "Syntax and Shellcheck" {
    FAILED=""
    echo "Starting Bash Lint checks"
    find_scripts > /tmp/find_scripts
    for script in $(find_scripts)
    do
        shellcheck_script "${script}"\
            || FAILED="${FAILED} ${script}"
    done
    if [[ "${FAILED}" == "" ]]
    then
        return 0
    else
        return 1
    fi
}

@test "Bash scripts have .sh suffix" {
    rc=0
    for f in $(all_files_in_repo|grep -v tests-for-this-repo)
    do
        if [[ ! "${f}" =~ .sh$ ]] && grep -q "bin/bash" "${f}"
        then
            # script found that doesn't have .sh suffix
            echo "Script found without .sh suffix: ${f}, please rename"
            rc=1
        fi
    done
    return ${rc}
}

@test "All functions referenced in readme" {
    rc=0
    for f in $(all_files_in_repo | grep "lib.sh$")
    do

        for func_name in $(grep 'function.*()\s*{\s*$' ${f} |awk '{print $2}'|tr -dc '[a-zA-Z0-9_-\n]')
        do
            if ! grep -q ${func_name} ${BASH_LIB}/README.md
            then
                echo "Function ${func_name} from libriary ${f} is not mentioned in the README.md, please add a description"
                rc=1
            fi
        done

        if ! grep -q ${f} ${BASH_LIB}/README.md
        then
            echo "Library ${f} is not mentioned in the README.md, please add a description"
            rc=1
        fi
    done
    return ${rc}
}

@test "All functions tested" {
    local rc=0
    for f in $(all_files_in_repo | grep "lib.sh$")
    do
        local lib_name="$(dirname ${f})"
        local bats_file="tests-for-this-repo/${lib_name}.bats"
        if [[ ! -e "${bats_file}" ]]
        then
            echo "BATS test file ${bats_file} is missing for library ${f}"
            rc=1
        else
            for func_name in $(grep 'function.*()\s*{' ${f} |awk '{print $2}'|tr -dc '[a-zA-Z0-9_\n]')
            do
                if ! grep -q ${func_name} ${bats_file}
                then
                    echo "Function ${func_name} from libriary ${f} is not tested in ${bats_file}, please add a test."
                    rc=1
                fi
            done
        fi
    done
    return ${rc}
}