#!/bin/bash

: "${BASH_LIB:?BASH_LIB must be set. Please source bash-lib/init.sh before other scripts from bash-lib.}"
. "${BASH_LIB}/helpers/lib.sh"

# Sets additional required environment variables that aren't available in the
# secrets.yml file, and performs other preparatory steps
function build_gke_image() {
  local image="gke-utils:latest"
  local rc=0
  docker rmi ${image} ||:
  spushd "${BASH_LIB}/k8s"
    # Prepare Docker images
    docker build --tag "${image}"\
      --file Dockerfile \
      --build-arg KUBECTL_CLI_URL="${KUBECTL_CLI_URL}" \
      . > /dev/null
    rc=${?}
  spopd
  return ${rc}
}

# Delete an image from GCR, unless it is has multiple tags pointing to it
# This means another parallel build is using the image and we should
# just untag it to be deleted by the later job
function delete_gke_image() {
  local image_and_tag="${1}"

  run_docker_gke_command "
    gcloud container images delete --force-delete-tags -q ${image_and_tag}
  "
}

function run_docker_gke_command() {
  docker run --rm \
    -i \
    -e DOCKER_REGISTRY_URL \
    -e DOCKER_REGISTRY_PATH \
    -e GCLOUD_SERVICE_KEY="/tmp${GCLOUD_SERVICE_KEY}" \
    -e GCLOUD_CLUSTER_NAME \
    -e GCLOUD_ZONE \
    -e SECRETLESS_IMAGE \
    -e KUBECTL_CLI_URL \
    -e GCLOUD_PROJECT_NAME \
    -v "${GCLOUD_SERVICE_KEY}:/tmp${GCLOUD_SERVICE_KEY}" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ~/.config:/root/.config \
    -v "${PWD}:/src" \
    -w /src \
    "gke-utils:latest" \
    bash -c "
      /scripts/platform_login.sh
      ${1}
    "
}