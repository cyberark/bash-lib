. "${BASH_LIB_DIR}/test-utils/bats-support/load.bash"
. "${BASH_LIB_DIR}/test-utils/bats-assert-1/load.bash"
. "${BASH_LIB_DIR}/init"

docker_safe_tmp(){
    # neither mktemp -d not $BATS_TMPDIR
    # produce dirs that docker can mount from
    # in macos.
    local -r tmp_dir="/tmp/${RANDOM}/spgs"
    (
        rm -rf "${tmp_dir}"
        mkdir -p "${tmp_dir}"
    ) 1>&2
    echo "${tmp_dir}"
}

@test "shellcheck notices compile error" {
    tmp_dir="$(docker_safe_tmp)"
    spushd "${tmp_dir}"

    echo "'" > bad_script
    run shellcheck_script bad_script
    assert_failure
    assert_output --partial "syntax error"

    spopd
    rm -rf "/tmp/${tmp_dir#/tmp/}"
}

@test "shellcheck passes good script" {
    tmp_dir="$(docker_safe_tmp)"
    spushd "${tmp_dir}"

    echo -e "#!/bin/bash\n:" > good_script
    run shellcheck_script good_script
    rm -rf "${tmp_dir}"
    assert_output --partial "Checking good_script"
    assert_success

    spopd
    rm -rf "/tmp/${tmp_dir#/tmp/}"
}

@test "find_scripts finds git tracked files containing bash shebang" {
    tmp_dir="${BATS_TMPDIR}/ffgtfwse"
    rm -rf "${tmp_dir}"
    mkdir -p "${tmp_dir}"
    pushd ${tmp_dir}
        git init
        git config user.email "ci@ci.ci"
        git config user.name "Jenkins"

        echo '#!/bin/bash' > a
        echo '#!/bin/bash' > b
        date > c
        date > d

        git add a c
        git commit -a -m "initial"

        run find_scripts
        assert_output "a"
        assert_success
    popd
}

@test "tap2junit correctly converts test file" {
    rc=0
    fdir="${BASH_LIB_DIR}/tests-for-this-repo/fixtures/test-utils"
    # Can't use run / assert_output here
    # because assert_output uses $output
    # which is a combination of stdout and stderr
    # and we are only interested in stdout.
    stdout=$(tap2junit < "${fdir}/tap2junit.in")
    rc=${?}
    assert_equal "${stdout}" "$(cat ${fdir}/tap2junit.out)"
    assert_equal "${rc}" "0"
}
