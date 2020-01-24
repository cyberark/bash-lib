
. "${BASH_LIB_DIR}/init"

setup() {
    bl_spushd ${BASH_LIB_DIR}
}

# Find and check shell scripts
@test "Syntax and Shellcheck" {
    FAILED=""
    echo "Starting Bash Lint checks"
    for script in $(bl_find_scripts); do
        bl_shellcheck_script "${script}"\
            || FAILED="${FAILED} ${script}"
    done

    [[ "${FAILED}" == "" ]]
}

@test "Bash scripts do not have .sh suffix" {
    rc=0
    for file in $(bl_find_scripts); do
        if [[ "${file}" =~ .sh$ ]]; then
            # script has .sh suffix
            echo "Script found with .sh suffix: ${file}, please rename"
            rc=1
        fi
    done
    return ${rc}
}

@test "All functions referenced in readme" {
    rc=0
    for file in $(bl_find_scripts | grep "/lib$"); do
        for func_name in $(grep 'function.*()\s*{\s*$' ${file} | awk '{print $2}'| tr -dc '[a-zA-Z0-9_-\n]'); do
            if ! grep -q "${func_name}" "${BASH_LIB_DIR}/README.md"; then
                echo "Function ${func_name} from libriary ${file} is not mentioned in the README.md, please add a description"
                rc=1
            fi
        done

        if ! grep -q "${file}" "${BASH_LIB_DIR}/README.md"; then
            echo "Library ${file} is not mentioned in the README.md, please add a description"
            rc=1
        fi
    done
    return ${rc}
}

@test "All functions tested" {
    local rc=0
    for file in $(bl_find_scripts | grep "/lib$"); do
        local lib_name="$(dirname ${file})"
        local bats_file="tests-for-this-repo/${lib_name}.bats"
        if [[ ! -e "${bats_file}" ]]; then
            echo "BATS test file ${bats_file} is missing for library ${file}"
            rc=1
        else
            for func_name in $(grep 'function.*()\s*{' "${file}" | awk '{print $2}'| tr -dc '[a-zA-Z0-9_\n]'); do
                if ! grep -q "${func_name}" "${bats_file}"; then
                    echo "Function ${func_name} from libriary ${file} is not tested in ${bats_file}, please add a test."
                    rc=1
                fi
            done
        fi
    done
    return ${rc}
}
