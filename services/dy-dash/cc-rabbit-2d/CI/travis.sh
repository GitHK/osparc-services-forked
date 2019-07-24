#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

before_install() {
    bash ops/travis/helpers/install_docker_compose;
    bash ops/travis/helpers/show_system_versions;
    env
}

install() {
    bash ops/travis/helpers/ensure_python_pip
    pip3 install -r services/dy-dash/cc-rabbit-2d/tests/requirements.txt
}

before_script() {
    cd services/dy-dash/cc-rabbit-2d
    make pull || true
}

script() {
    cd services/dy-dash/cc-rabbit-2d
    make build
    make unit-test
    make integration-test
}

after_success() {
    echo "build succeeded"
}

after_failure() {
    echo "build failed"
    env
    docker images
}

deploy() {
    # show current images on system
    docker images
    # these variable must be available securely from travis
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
    # push the local images
    cd services/dy-dash/cc-rabbit-2d
    make push
}

# Check if the function exists (bash specific)
if declare -f "$1" > /dev/null
then
  # call arguments verbatim
  "$@"
else
  # Show a helpful error
  echo "'$1' is not a known function name" >&2
  exit 1
fi