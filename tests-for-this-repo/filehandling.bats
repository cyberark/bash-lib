. "${BASH_LIB}/test-utils/bats-support/load.bash"
. "${BASH_LIB}/test-utils/bats-assert-1/load.bash"

. "${BASH_LIB}/filehandling/lib.sh"

@test "abs_path returns absolute path for PWD" {
    run abs_path .
    assert_output $PWD
    assert_success
}

@test "abs_path returns same path when already absolute" {
    run abs_path /tmp
    assert_output /tmp
    assert_success
}