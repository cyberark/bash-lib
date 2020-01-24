. "${BASH_LIB_DIR}/test-utils/bats-support/load.bash"
. "${BASH_LIB_DIR}/test-utils/bats-assert-1/load.bash"

. "${BASH_LIB_DIR}/init"

@test "bl_abs_path returns absolute path for PWD" {
    run bl_abs_path .
    assert_output $PWD
    assert_success
}

@test "bl_abs_path returns PWD when no arg specified" {
    run bl_abs_path
    assert_output $PWD
    assert_success
}

@test "bl_abs_path returns same path when already absolute" {
    run bl_abs_path /tmp
    assert_output /tmp
    assert_success
}
