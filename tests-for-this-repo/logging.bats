. "${BASH_LIB}/test-utils/bats-support/load.bash"
. "${BASH_LIB}/test-utils/bats-assert-1/load.bash"

. "${BASH_LIB}/logging/lib.sh"

@test "announce prints all arguments" {
    run announce one two one two
    assert_output --partial "one two one two"
    assert_success
}