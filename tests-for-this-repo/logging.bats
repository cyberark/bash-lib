. "${BASH_LIB_DIR}/test-utils/bats-support/load.bash"
. "${BASH_LIB_DIR}/test-utils/bats-assert-1/load.bash"
. "${BASH_LIB_DIR}/init"

@test "announce prints all arguments" {
    run announce one two one two
    assert_output --partial "one two one two"
    assert_success
}

@test "check_log_level succeeds with valid level" {
    run check_log_level
    assert_success
}

@test "check_log_level fails with invalid level" {
    run BASH_LIB_LOG_LEVEL="foo" check_log_level
    assert_failure
}

@test "debug doesn't output anything using the default info level" {
    run debug foo
    assert_success
    assert_output ""
}

@test "debug outputs its inputs while using the debug level" {
    run BASH_LIB_LOG_LEVEL="debug" debug foo
    assert_success
    assert_output "foo"
}