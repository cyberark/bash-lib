. "${BASH_LIB_DIR}/test-utils/bats-support/load.bash"
. "${BASH_LIB_DIR}/test-utils/bats-assert-1/load.bash"
. "${BASH_LIB_DIR}/init"

@test "announce prints all arguments" {
    run announce one two one two
    assert_output --partial "one two one two"
    assert_success
}
