#!/usr/bin/env bash

set -x
set -euo pipefail

RUNTIME="${RUNTIME:-"io.containerd.kata.v2"}"
#RUNTIME="io.containerd.runc.v1"

image="docker.io/library/redis:alpine"

sudo ctr --debug container delete redisctr0
sudo ctr --debug images pull "${image}"
sudo ctr --debug run \
  --runtime "${RUNTIME}" \
  "${image}" redisctr0 /bin/ash

