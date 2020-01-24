. "${BASH_LIB_DIR}/test-utils/bats-support/load.bash"
. "${BASH_LIB_DIR}/test-utils/bats-assert-1/load.bash"
. "${BASH_LIB_DIR}/init"

teardown() {
    # reset to default log level
    export BASH_LIB_LOG_LEVEL=info
    echo teardown
}

@test "bl_announce prints all arguments" {
    run bl_announce one two one two
    assert_output --partial "one two one two"
    assert_success
}

@test "bl_check_log_level succeeds with valid level" {
    run bl_check_log_level error
    assert_success
}

@test "bl_check_log_level fails with invalid level" {
    run BASH_LIB_LOG_LEVEL="foo" bl_check_log_level
    assert_failure
}

@test "bl_log outputs message" {
    run bl_log info test
    assert_success
    assert_output --partial test
}

@test "bl_log outputs mesage when stderr is selected. Note: bats combines stdout and stderr" {
    run bl_log info test stderr
    assert_success
    assert_output --partial "test"
}

@test "bl_debug doesn't output anything using the default info level" {
    run bl_debug foo
    assert_success
    refute_output foo
}

@test "bl_debug outputs its inputs while using the debug level" {
    export BASH_LIB_LOG_LEVEL="debug"
    run bl_debug foo
    assert_success
    assert_output --partial foo
}

@test "bl_info outputs its inputs while using the info level" {
    export BASH_LIB_LOG_LEVEL="info"
    run bl_info foo
    assert_success
    assert_output --partial foo
}

@test "bl_warn uses the correct colour" {
    run bl_warn warning
    assert_success
    assert_output --partial $(echo -e "\e[0;33;40m")
    assert_output --partial warning
}

@test "bl_error resets colour at the end of output" {
    run bl_error error
    assert_success
    assert_output --partial $(echo -e "\e[0m")
    assert_output --partial error
}

@test "bl_fatal outputs its input" {
    run bl_fatal reallybad
    assert_success
    assert_output --partial reallybad
}