#!/usr/bin/env bash

set -x

RUNTIME="io.containerd.runtime.kata.v2" # fails with: ctr: no such file or directory: not found
#RUNTIME="io.containerd.runtime.v1.linux" # works

image="docker.io/library/redis:alpine"

sudo ctr container delete redis0
sudo ctr images pull "${image}"
sudo ctr run \
  --runtime "${RUNTIME}" \
  "${image}" redis0 /bin/ash

