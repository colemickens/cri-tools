#!/usr/bin/env bash

set -x
set -euo pipefail

RUNTIME="io.containerd.kata.v2"
RUNTIME="io.containerd.runc.v1"

NAME="redis-ctr"
image="docker.io/library/redis:alpine"

function cleanup() {
  sudo crictl stopp $(crictl pods -q)
  sudo crictl rmp $(crictl pods -q)
}
trap cleanup EXIT
cleanup

sudo ctr --debug task kill -s 9 ${NAME} || true # TODO: why is -s9 needed? crictl isn't so aggressive?
sudo ctr --debug task delete ${NAME} || true
sudo ctr --debug container delete ${NAME} || true
sudo ctr --debug images pull "${image}"
sudo ctr --debug run --tty --runtime "${RUNTIME}" "${image}" ${NAME} /bin/ash

