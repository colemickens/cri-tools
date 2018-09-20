#!/usr/bin/env bash

RUNTIME="io.containerd.runtime.kata.v2" # fails with: ctr: no such file or directory: not found
#RUNTIME="io.containerd.runtime.v1.linux" # works

image="docker.io/library/redis:alpine"

ctr container delete redis0
ctr images pull "${image}"
trace ctr run \
  --runtime "${RUNTIME}" \
  "${image}" redis0 /bin/ash

