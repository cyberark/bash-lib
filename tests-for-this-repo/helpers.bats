. "${BASH_LIB_DIR}/test-utils/bats-support/load.bash"
. "${BASH_LIB_DIR}/test-utils/bats-assert-1/load.bash"

. "${BASH_LIB_DIR}/init"


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
