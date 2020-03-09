. "${BASH_LIB_DIR}/test-utils/bats-support/load.bash"
. "${BASH_LIB_DIR}/test-utils/bats-assert-1/load.bash"

. "${BASH_LIB_DIR}/init"

teardown(){
    unset curl
}


@test "bl_jq_available succeeds when jq is available" {
    jq(){ :; }
    run bl_jq_available
    assert_success
}

@test "bl_jq_available fails when jq is not available" {
    real_path="${PATH}"
    PATH=""
    run bl_jq_available
    PATH="${real_path}"
    assert_failure
    assert_output --partial "jq not found"
}

@test "bl_curl_available succeeds when jq is available" {
    jq(){ :; }
    run bl_curl_available
    assert_success
}

@test "bl_curl_available fails when jq is not available" {
    real_path="${PATH}"
    PATH=""
    run bl_curl_available
    PATH="${real_path}"
    assert_failure
    assert_output --partial "curl not found"
}

@test "bl_gem_latest_version fails when no gem name is supplied" {
    run bl_gem_latest_version
    assert_failure
    assert_output --partial "usage"
}

@test "bl_gem_latest_version returns only the version number" {
    curl(){
        fixtures_dir="${BASH_LIB_DIR}/tests-for-this-repo/fixtures/ruby"
        cat ${fixtures_dir}/ruby_gems_api_response.json
    }

    run bl_gem_latest_version parse_a_changelog
    assert_success
    assert_output "1.0.1"
}
