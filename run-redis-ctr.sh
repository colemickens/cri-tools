#!/usr/bin/env bash

set -x
set -euo pipefail

[[ "${1:-}" == "kata" ]] && RUNTIME2="io.containerd.kata.v2"
[[ "${1:-}" == "runc" ]] && RUNTIME2="io.containerd.runc.v1"

[[ "${RUNTIME2:-}" == "" ]] && echo "first arg is runtime (kata|runc)" && exit -1

NAME="redis-ctr"
image="docker.io/library/redis:alpine"

function cleanup() {
  sudo crictl stopp $(crictl pods -q) || true
  sudo crictl rmp $(crictl pods -q) || true
}
trap cleanup EXIT
cleanup

sudo ctr --debug task kill -s 9 ${NAME} || true # TODO: why is -s9 needed? crictl isn't so aggressive?
sudo ctr --debug task delete ${NAME} || true
sudo ctr --debug container delete ${NAME} || true
sudo ctr --debug images pull "${image}"

# option 1 - run ash inside the container rootfs
#sudo ctr --debug run --tty --runtime "${RUNTIME2}" "${image}" ${NAME} /bin/ash

# option 2 - run the default container command
sudo ctr --debug run --tty --runtime "${RUNTIME2}" "${image}" ${NAME}

