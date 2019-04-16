. "${BASH_LIB}/test-utils/bats-support/load.bash"
. "${BASH_LIB}/test-utils/bats-assert-1/load.bash"

. "${BASH_LIB}/git/lib.sh"

@test "repo_root returns root of current repo" {
    pushd ${BASH_LIB}
    run repo_root
    assert_output $PWD
    assert_success
}

@test "repo_root fails when not run from a git repo" {
    pushd /tmp
    run repo_root
    assert_failure
}

@test "all_files_in_repo lists all git tracked files" {
    local -r d="${BATS_TMPDIR}/afir"
    rm -rf "${d}"
    mkdir -p "${d}"
    pushd ${d}
    git init
    git config user.email "ci@ci.ci"
    git config user.name "Jenkins"
    touch a b c
    git add a b
    git commit -a -m "initial"
    run all_files_in_repo
    assert_output "a
b"
    assert_success
}