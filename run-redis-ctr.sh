#!/usr/bin/env bash

set -x
set -euo pipefail

RUNTIME="${RUNTIME:-"io.containerd.kata.v2"}"
#RUNTIME="io.containerd.runc.v1"

image="docker.io/library/redis:alpine"

sudo ctr --debug task kill -s 9 redisctr0 || true # TODO: why is -s9 needed? crictl isn't so aggressive?
sudo ctr --debug task delete redisctr0 || true
sudo ctr --debug container delete redisctr0 || true
sudo ctr --debug images pull "${image}"
sudo ctr --debug run \
  --tty \
  --runtime "${RUNTIME}" \
  "${image}" redisctr0 /bin/ash

