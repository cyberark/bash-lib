. "${BASH_LIB_DIR}/test-utils/bats-support/load.bash"
. "${BASH_LIB_DIR}/test-utils/bats-assert-1/load.bash"

. "${BASH_LIB_DIR}/init"

# run before every test
setup(){
    local -r temp_dir="${BATS_TMPDIR}/testtemp"
    local -r repo_dir="${temp_dir/}/repo"
    rm -rf "${temp_dir}"
    mkdir -p "${repo_dir}"
    pushd ${repo_dir}

    git init
    git config user.email "ci@cyberark.com"
    git config user.name "Jenkins"
    git commit --allow-empty -m "initial"
    echo "some content" > a_file
    git add a_file
    git commit -a -m "some operations fail on empty repos"
}

teardown(){
    local -r temp_dir="${BATS_TMPDIR}/testtemp"
    rm -rf "${temp_dir}"
}

@test "bl_repo_root returns root of current repo" {
    pushd ${BASH_LIB_DIR}
    run bl_repo_root
    assert_output $PWD
    assert_success
}

@test "bl_repo_root fails when not run from a git repo" {
    pushd /tmp
    run bl_repo_root
    assert_failure
}

@test "bl_all_files_in_repo lists all git tracked files" {
    # untracked file shouldn't be listed in output
    date > b
    run bl_all_files_in_repo
    assert_output "a_file"
    assert_success
}

@test "bl_remote_latest_tag gets latest tag from a remote" {
    # For this test the "remote" will be local,
    # because It hard to guarantee an actual remote
    # won't gain new tags over time.

    date > a
    git add a
    git commit -m v1
    git tag -a -m v1 v1

    date > b
    git add b
    git commit -m v2
    git tag -a -m v2 v2

    run bl_remote_latest_tag .
    assert_output v2
    assert_success
}

@test "bl_remote_latest_tagged_commit returns sha of last tagged commit, not sha of the tag" {
    date > a
    git add a
    git commit -m v1
    git tag -a -m v1 v1

    date > b
    git add b
    git commit -m v2

    run bl_remote_latest_tagged_commit .
    assert_output "$(git rev-parse v1^{})"
    assert_success
}

@test "bl_remote_sha_for_ref looks up a sha for a given ref" {
    git checkout -b testbranch
    run bl_remote_sha_for_ref . testbranch
    assert_output "$(git rev-parse HEAD)"
    assert_success
}

@test "bl_remote_tag_for_sha looks up a tag for a given sha" {
    git tag -a -m v1 v1
    date > a
    git add a
    git commit -m v2
    git tag -a -m v2 v2

    run bl_remote_tag_for_sha . "$(git rev-parse v1^{})"
    assert_output v1
    assert_success
}

@test "bl_gittrees_present succeeds when .gittrees file is present" {
    touch .gittrees
    run bl_gittrees_present
    assert_success
    assert_output ""
}

@test "bl_gittrees_present fails when .gittrees file is not present" {
    run bl_gittrees_present
    assert_failure
    assert_output ""
}

@test "bl_cat_gittrees dies when gittrees doesn't exist" {
    run bl_cat_gittrees
    assert_failure
    assert_output --partial "should contain"
}

@test "bl_cat_gitrees skips comments" {
    cat >.gittrees <<EOF
# comment 1
# comment 2
a b c
EOF
    run bl_cat_gittrees
    assert_output "a b c"
    refute_output --partial "comment 1"
    refute_output --partial "comment 2"
    assert_success
}

@test "bl_tracked_files_excluding_subtrees excludes files in subtrees" {
    # use add_subtree when available
    run git subtree add --squash --prefix bats "https://github.com/bats-core/bats" v1.0.0
    assert_success

    echo "bats https://github.com/bats-core/bats bats" >.gittrees

    assert [ -e bats/README.md ]

    date > untracked_file

    run bl_tracked_files_excluding_subtrees
    refute_output --partial bats
    refute_output --partial untracked_file
    assert_output --partial a_file
    assert_success
    assert_output --partial a_file
    assert_success
}
