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

@test "bl_die exits and prints message" {
    run bash -c ". ${BASH_LIB_DIR}/init; bl_die msg"
    assert_output --partial msg
    assert_failure
}

@test "bl_spushd is quiet on stdout" {
    run bl_spushd /tmp
    assert_output ""
    assert_success
}

@test "bl_spopd is quiet on stdout" {
    pushd .
    run bl_spopd
    assert_output ""
    assert_success
}

@test "bl_spushd dies on failure" {
    run bash -c ". ${BASH_LIB_DIR}/init; bl_spushd /this-doesnt-exist"
    assert_output --partial "No such file or directory"
    assert_failure
}

@test "bl_spopd dies on failure" {
    run bash -c ". ${BASH_LIB_DIR}/init; bl_spopd"
    assert_output --partial "stack empty"
    assert_failure
}

@test "bl_is_num fails with no arguments" {
    run bl_is_num
    assert_output ""
    assert_failure
}

@test "bl_is_num fails with alphabetical input" {
    run bl_is_num foo
    assert_output ""
    assert_failure
}

@test "bl_is_num suceeds with integer" {
    run bl_is_num 123
    assert_output ""
    assert_success
}

@test "bl_is_num suceeds with negative integer" {
    run bl_is_num -123
    assert_output ""
    assert_success
}

@test "bl_is_num suceeds with float" {
    run bl_is_num 123.4
    assert_output ""
    assert_success
}

@test "bl_is_num suceeds with negative float" {
    run bl_is_num -123.4
    assert_output ""
    assert_success
}

@test "bl_retry runs command only once if it succeeds the first time" {
    retryme(){
        date >> ${afile}
    }
    run bl_retry 3 retryme
    assert_success
    assert_equal $(wc -l <${afile}) 1
}

@test "bl_retry doesn't introduce delay when the command succeeds first time" {
    retryme(){
        date >> ${afile}
    }
    start=$(date +%s)
    run bl_retry 3 retryme
    end=$(date +%s)
    assert [ "$(( start + 1 ))" -ge "${end}" ]
    assert_success
}

@test "bl_retry runs n times on consecutive failure and waits between attempts" {
    retryme(){
        date >> ${afile}
        false
    }
    start=$(date +%s)
    run bl_retry 2 retryme
    end=$(date +%s)
    # introduces at least a two second delay between attempts
    assert [ "$(( start + 2 ))" -le "${end}" ]
    assert_failure
    assert_equal $(wc -l <${afile}) 2
}

@test "bl_retry returns after first success" {
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
    run bl_retry 3 retryme
    assert_success
    assert_equal $(wc -l <${afile}) 2
}

@test "bl_retry fails with less than two arguments" {
    run bl_retry 3
    assert_failure
    assert_output --partial usage
    assert [ ! -e "${temp_dir}/appendfile" ]
}

@test "bl_retry fails with non-integer retry count" {
    run bl_retry "this" date
    assert_failure
    assert_output --partial number
    assert [ ! -e "${temp_dir}/appendfile" ]
}

@test "bl_retry succeeds with compound statements" {
    run bl_retry 3 "true && date >> ${afile}"
    assert_success
    assert_equal $(wc -l <${afile}) 1
}




# ***************


@test "bl_retry_constant runs command only once if it succeeds the first time" {
    retry_me(){
        date >> ${afile}
    }
    run bl_retry_constant 3 1 retry_me
    assert_success
    assert_equal $(wc -l <${afile}) 1
}

@test "bl_retry_constant doesn't introduce delay when the command succeeds first time" {
    retry_me(){
        date >> ${afile}
    }
    start=$(date +%s)
    run bl_retry_constant 3 10 retry_me
    end=$(date +%s)
    assert [ "$(( start + 1 ))" -ge "${end}" ]
    assert_success
}

@test "bl_retry_constant runs n times on consecutive failure and waits between attempts" {
    retry_me(){
        date >> ${afile}
        false
    }
    start=$(date +%s)
    run bl_retry_constant 2 2 retry_me
    end=$(date +%s)
    # introduces at least a two second delay between attempts
    assert [ "$(( start + 2 ))" -le "${end}" ]
    assert_failure
    assert_equal $(wc -l <${afile}) 2
}

@test "bl_retry_constant returns after first success" {
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
    run bl_retry_constant 3 1 retry_me
    assert_success
    assert_equal $(wc -l <${afile}) 2
}

@test "bl_retry_constant fails with less than three arguments" {
    run bl_retry_constant 3 1
    assert_failure
    assert_output --partial usage
    assert [ ! -e "${temp_dir}/appendfile" ]
}

@test "bl_retry_constant fails with non-integer retry count" {
    run bl_retry_constant "this" 1 date
    assert_failure
    assert_output --partial number
    assert [ ! -e "${temp_dir}/appendfile" ]
}

@test "bl_retry_constant fails with non-integer interval" {
    run bl_retry_constant 2 "this" date
    assert_failure
    assert_output --partial interval
    assert [ ! -e "${temp_dir}/appendfile" ]
}

@test "bl_retry_constant succeeds with compound statements" {
    run bl_retry_constant 3 1 "true && date >> ${afile}"
    assert_success
    assert_equal $(wc -l <${afile}) 1
}