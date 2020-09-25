. "${BASH_LIB_DIR}/test-utils/bats-support/load.bash"
. "${BASH_LIB_DIR}/test-utils/bats-assert-1/load.bash"

# run before every test
setup(){
    . "${BASH_LIB_DIR}/init"
    local -r temp_dir="${BATS_TMPDIR}/testtemp"
    local -r repo_dir="${temp_dir/}/repo"
    rm -rf "${temp_dir}"
    mkdir -p "${repo_dir}"
    pushd ${repo_dir}

    git init
    git config user.email "conj_ops_ci@cyberark.com"
    git config user.name "Jenkins"
    SKIP_GITLEAKS=YES git commit --allow-empty -m "initial"
    echo "some content" > a_file
    git add a_file
    git commit -a -m "some operations fail on empty repos"
    git remote add origin git@github.com:owner/repo
}

teardown(){
    local -r temp_dir="${BATS_TMPDIR}/testtemp"
    rm -rf "${temp_dir}"
    unset GITHUB_TOKEN
    unset GITHUB_USER
    unset hub
}

@test "bl_hub_available fails when hub isn't available" {
    REAL_PATH="${PATH}"
    PATH="${PWD}"
    run bl_hub_available
    PATH="${REAL_PATH}"
    assert_output --partial "github cli"
    assert_failure
}

@test "bl_hub_available succeeds when hub is available" {
    hub(){ :; }
    run bl_hub_available
    assert_success
}

@test "bl_hub_check fails when not in a git repo" {
    rm -rf .git
    run bl_hub_check
    assert_failure
    assert_output --partial "not within a git repo"
}

@test "bl_hub_check fails when hub not availble" {
    bl_in_git_repo(){ :; }
    REAL_PATH="${PATH}"
    PATH="${PWD}"
    run bl_hub_check
    PATH="${REAL_PATH}"
    assert_output --partial "github cli"
    assert_failure
}

@test "bl_hub_creds_available fails when creds are not available" {
    export HUB_CONFIG="./hub_config"
    run bl_hub_creds_available
    assert_failure
    assert_output --partial "No credentials found"
}

@test "bl_hub_creds_available succeeds when env vars are set" {
    export GITHUB_USER=user
    export GITHUB_TOKEN=token
    export HUB_CONFIG="./hub_config"
    run bl_hub_creds_available
    unset GITHUB_USER
    unset GITHUB_TOKEN
    assert_success
    assert_output ""
}

@test "bl_hub_creds_available succeeds when hub config file is present" {
    unset GITHUB_USER
    unset GITHUB_TOKEN
    export HUB_CONFIG="./hub_config"
    touch hub_config
    run bl_hub_creds_available
    assert_success
    assert_output ""
}

@test "bl_hub_check succeeds when in a git repo, hub is available and creds supplied" {
    touch hub_config
    hub(){ :; }
    run bl_hub_check ./hub_config
}

@test "bl_hub_download_latest downloads hub binary to specified location, with the correct arch" {
    run bl_hub_download_latest "${PWD}"
    assert_success
    assert test -e hub

    run ./hub --version
    assert_success
    assert_output --partial "hub version"
}

@test "bl_hub_issue_number_for_title returns only the issue number" {
    bl_hub_check(){ :; }
    hub(){
        [[ "${1}" == "issue" ]] || bl_die "issue subcommand not specified"
        cat <<EOF
     #19  Add code coverage to bash-lib   kind/quality
     #11  Generated Documentation
      #7  Clean up
EOF
    }

    run bl_hub_issue_number_for_title "Clean up"
    assert_success
    assert_output "7"
}

@test "bl_hub_issue_number_for_title returns a single issue number" {
    bl_hub_check(){ :; }
    hub(){
        [[ "${1}" == "issue" ]] || bl_die "issue subcommand not specified"
        cat <<EOF
     #19  Add code coverage to bash-lib   kind/quality
     #11  Generated Documentation
     #12  Duplicate
     #13  Duplicate
      #7  Clean up
EOF
    }

    run bl_hub_issue_number_for_title "Duplicate"
    assert_success
    assert_output "12"
}

@test "bl_hub_add_issue_comment uses the correct URL" {
    bl_hub_check(){ :; }
    hub(){
        if [[ "${1}" == "api" ]]; then
            [[ "${3}" != "repos/owner/repo/issues/6" ]] || bl_die "Incorrect api url: ${3}"
        fi
    }

    run bl_hub_add_issue_comment 6 "A comment"
    assert_success
    assert_output ""
}

@test "bl_hub_add_issue_comment fails when an invalid issue number is supplied" {
    bl_hub_check(){ :; }
    hub(){
        if [[ "${1}" == "issue" ]]; then
           return 1
        fi
    }

    run bl_hub_add_issue_comment 6 "A comment"
    assert_failure
    assert_output --partial "isn't valid"
    assert_output --partial "6"
}

@test "bl_hub_add_issue_comment fails when adding a comment fails" {
    bl_hub_check(){ :; }
    hub(){
        if [[ "${1}" == "api" ]]; then
           return 1
        fi
    }

    run bl_hub_add_issue_comment 6 "A comment"
    assert_failure
    assert_output --partial "Failed to add comment"
    assert_output --partial "A comment"
    assert_output --partial "owner/repo#6"
}

@test "bl_hub_comment_or_create_issue creates issue when it doesnt exist" {
    bl_hub_check(){ :; }
    bl_hub_issue_number_for_title(){ :; }
    bl_github_owner_repo(){ echo "owner/repo"; }
    hub(){
        if [[ "${2:-}" == "create" ]]; then
            [[ "${3}" == "-m" ]] || bl_die "unexpected argument to hub \"${3}\" expected \"-m\" """
            [[ "${4}" == "$(echo -e "title\n\nmessage")" ]] \
                || bl_die "unexpected argument to hub \"${4}\""
        fi
        echo "https://github.com/owner/repo/issues/1"
    }
    run bl_hub_comment_or_create_issue title message
    assert_success
    assert_output --partial "https://github.com/owner/repo/issues/1"
    assert_output --partial "create"
}

@test "bl_hub_comment_or_create_issue adds comment when issue already exists" {
    bl_hub_check(){ :; }
    hub(){ :; }
    bl_hub_issue_number_for_title(){ echo 1; }
    bl_github_owner_repo(){ echo "owner/repo"; }
    bl_hub_add_issue_comment(){
        [[ "${1}" == 1 ]] || bl_die "Expected issue number to be: 1"
        [[ "${2}" == "message" ]] || bl_die "Expected message to be: message"
        bl_info "Added comment: \"message\" to https://github.com/owner/repo/issues/1"
    }
    run bl_hub_comment_or_create_issue title message
    assert_success
    assert_output --partial "comment"
    assert_output --partial "https://github.com/owner/repo/issues/1"
}

@test "bl_hub_comment_or_create_issue passes label to hub" {
    bl_hub_check(){ :; }
    bl_hub_issue_number_for_title(){ :; }
    bl_github_owner_repo(){ echo "owner/repo"; }
    hub(){
        [[ "${5}" == "-l" ]] || bl_die "expected -l for specifying a label"
        [[ "${6}" == "label" ]] || bl_die "expected 'label' as label name"
        echo "https://github.com/owner/repo/issues/1"
    }
    run bl_hub_comment_or_create_issue title message label
    assert_success
    assert_output --partial "https://github.com/owner/repo/issues/1"
    assert_output --partial "create"
}
