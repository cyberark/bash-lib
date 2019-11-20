. "${BASH_LIB_DIR}/test-utils/bats-support/load.bash"
. "${BASH_LIB_DIR}/test-utils/bats-assert-1/load.bash"

. "${BASH_LIB_DIR}/init"

# run before every test
setup(){
    temp_dir="${BATS_TMPDIR}/testtemp"
    mkdir "${temp_dir}"
    afile="${temp_dir}/appendfile"
}

teardown(){
    temp_dir="${BATS_TMPDIR}/testtemp"
    rm -rf "${temp_dir}"
}

@test "die exits and prints message" {
    run bash -c ". ${BASH_LIB_DIR}/init; die msg"
    assert_output msg
    assert_failure
}

@test "spushd is quiet on stdout" {
    run spushd /tmp
    assert_output ""
    assert_success
}

@test "spopd is quiet on stdout" {
    pushd .
    run spopd
    assert_output ""
    assert_success
}

@test "spushd dies on failure" {
    run bash -c ". ${BASH_LIB_DIR}/init; spushd /this-doesnt-exist"
    assert_output --partial "No such file or directory"
    assert_failure
}

@test "spopd dies on failure" {
    run bash -c ". ${BASH_LIB_DIR}/init; spopd"
    assert_output --partial "stack empty"
    assert_failure
}

@test "is_num fails with no arguments" {
    run is_num
    assert_output ""
    assert_failure
}

@test "is_num fails with alphabetical input" {
    run is_num foo
    assert_output ""
    assert_failure
}

@test "is_num suceeds with integer" {
    run is_num foo
    assert_output 123
    assert_success
}

@test "is_num suceeds with negative integer" {
    run is_num foo
    assert_output -123
    assert_success
}

@test "is_num suceeds with float" {
    run is_num foo
    assert_output 123.4
    assert_success
}

@test "is_num suceeds with negative float" {
    run is_num foo
    assert_output -123.4
    assert_success
}

@test "retry runs command only once if it succeeds the first time" {
    retryme(){
        date >> ${afile}
    }
    run retry 3 retryme
    assert_success
    assert_equal $(wc -l <${afile}) 1
}

@test "retry doesn't introduce delay when the command succeeds first time" {
    retryme(){
        date >> ${afile}
    }
    start=$(date +%s)
    run retry 3 retryme
    end=$(date +%s)
    assert [ "$(( start + 1 ))" -ge "${end}" ]
    assert_success
}

@test "retry runs n times on consecutive failure and waits between attempts" {
    retryme(){
        date >> ${afile}
        false
    }
    start=$(date +%s)
    run retry 2 retryme
    end=$(date +%s)
    # introduces at least a two second delay between attempts
    assert [ "$(( start + 2 ))" -le "${end}" ]
    assert_failure
    assert_equal $(wc -l <${afile}) 2
}

@test "retry returns after first success" {
    retryme(){
        date >> "${afile}"
        case $(wc -l < ${afile}) in
            *1)
                return 1
            ;;
            *)
                return 0
            ;;
        esac
    }
    run retry 3 retryme
    assert_success
    assert_equal $(wc -l <${afile}) 2
}

@test "retry fails with less than two arguments" {
    run retry 3
    assert_failure
    assert_output --partial usage
    assert [ ! -e "${temp_dir}/appendfile" ]
}

@test "retry fails with non-integer retry count" {
    run retry "this" date
    assert_failure
    assert_output --partial number
    assert [ ! -e "${temp_dir}/appendfile" ]
}

@test "retry succeeds with compound statements" {
    run retry 3 "true && date >> ${afile}"
    assert_success
    assert_equal $(wc -l <${afile}) 1
}




# ***************


@test "retry_constant runs command only once if it succeeds the first time" {
    retry_me(){
        date >> ${afile}
    }
    run retry_constant 3 1 retry_me
    assert_success
    assert_equal $(wc -l <${afile}) 1
}

@test "retry_constant doesn't introduce delay when the command succeeds first time" {
    retry_me(){
        date >> ${afile}
    }
    start=$(date +%s)
    run retry_constant 3 10 retry_me
    end=$(date +%s)
    assert [ "$(( start + 1 ))" -ge "${end}" ]
    assert_success
}

@test "retry_constant runs n times on consecutive failure and waits between attempts" {
    retry_me(){
        date >> ${afile}
        false
    }
    start=$(date +%s)
    run retry_constant 2 1 retry_me
    end=$(date +%s)
    # introduces at least a two second delay between attempts
    assert [ "$(( start + 2 ))" -le "${end}" ]
    assert_failure
    assert_equal $(wc -l <${afile}) 2
}

@test "retry_constant returns after first success" {
    retry_me(){
        date >> "${afile}"
        case $(wc -l < ${afile}) in
            *1)
                return 1
            ;;
            *)
                return 0
            ;;
        esac
    }
    run retry_constant 3 1 retry_me
    assert_success
    assert_equal $(wc -l <${afile}) 2
}

@test "retry_constant fails with less than three arguments" {
    run retry_constant 3 1
    assert_failure
    assert_output --partial usage
    assert [ ! -e "${temp_dir}/appendfile" ]
}

@test "retry_constant fails with non-integer retry count" {
    run retry_constant "this" 1 date
    assert_failure
    assert_output --partial number
    assert [ ! -e "${temp_dir}/appendfile" ]
}

@test "retry_constant fails with non-integer interval" {
    run retry_constant 2 "this" date
    assert_failure
    assert_output --partial interval
    assert [ ! -e "${temp_dir}/appendfile" ]
}

@test "retry_constant succeeds with compound statements" {
    run retry_constant 3 1 "true && date >> ${afile}"
    assert_success
    assert_equal $(wc -l <${afile}) 1
}