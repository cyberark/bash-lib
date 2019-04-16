. "${BASH_LIB}/test-utils/bats-support/load.bash"
. "${BASH_LIB}/test-utils/bats-assert-1/load.bash"

. "${BASH_LIB}/helpers/lib.sh"
. "${BASH_LIB}/test-utils/lib.sh"

docker_safe_tmp(){
    # neither mktemp -d not $BATS_TMPDIR
    # produce dirs that docker can mount from
    # in macos.
    local -r d="/tmp/${$}-${RANDOM}/spgs"
    (
        # whatever the value of d, ensure the rm is scoped to /tmp
        rm -rf "/tmp/${d#/tmp/}"
        mkdir -p "${d}"
    ) 1>&2
    echo "${d}"
}

@test "shellcheck notices compile error" {
    d="$(docker_safe_tmp)"
    spushd "${d}"

    echo "'" > bad_script.sh
    run shellcheck_script bad_script.sh
    assert_failure
    assert_output --partial "syntax error"

    spopd
    rm -rf "/tmp/${d#/tmp/}"
}

@test "shellcheck passes good script" {
    d="$(docker_safe_tmp)"
    spushd "${d}"

    echo -e "#!/bin/bash\n:" > good_script.sh
    run shellcheck_script good_script.sh
    rm -rf "${d}"
    assert_output --partial "Checking good_script.sh"
    assert_success

    spopd
    rm -rf "/tmp/${d#/tmp/}"
}

@test "find_scripts finds git tracked files with .sh extension" {
    d="${BATS_TMPDIR}/ffgtfwse"
    rm -rf "${d}"
    mkdir -p "${d}"
    pushd ${d}
    git init
    git config user.email "ci@ci.ci"
    git config user.name "Jenkins"
    touch a.sh b.sh c.sh d e
    git add a.sh b.sh d
    git commit -a -m "initial"
    run find_scripts
    assert_output "a.sh
b.sh"
    assert_success
}

@test "tap2junit correctly converts test file" {
    rc=0
    fdir="${BASH_LIB}/tests-for-this-repo/fixtures/test-utils"
    # Can't use run / assert_output here
    # because assert_output uses $output
    # which is a combination of stdout and stderr
    # and we are only interested in stdout.
    stdout=$(tap2junit < "${fdir}/tap2junit.in")
    rc=${?}
    assert_equal "${stdout}" "$(cat ${fdir}/tap2junit.out)"
    assert_equal "${rc}" "0"
}