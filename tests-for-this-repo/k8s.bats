. "${BASH_LIB_DIR}/test-utils/bats-support/load.bash"
. "${BASH_LIB_DIR}/test-utils/bats-assert-1/load.bash"

. "${BASH_LIB_DIR}/init"

@test "gke-utils image builds" {
    run bl_build_gke_image
    assert_success
}

@test "Kubernetes Cluster Is Available" {
        : ${KUBECTL_CLI_URL:?Required Var, did you run tests via summon?}
        run bl_run_docker_gke_command "kubectl cluster-info"
        assert_output --regexp "Kubernetes master.* is running at .*https://"
        assert_success
}

@test "Can delete gke image" {
    local -r image="${DOCKER_REGISTRY_PATH}/alpine-test-${RANDOM}"
    bl_run_docker_gke_command "
        docker pull alpine
        docker tag alpine ${image}
        docker push ${image}
    "
    run bl_delete_gke_image "${image}"
    assert_success
}
