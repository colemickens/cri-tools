#!/usr/bin/env bash

set -x
set -euo pipefail

NAME="redis-crictl-${1:-"default"}"
image="docker.io/library/redis:alpine"

RUNTIME="${1:-}"

function cleanup() {
  sudo crictl stopp $(crictl pods -q) || true
  sudo crictl rmp $(crictl pods -q) || true
}
trap cleanup EXIT
cleanup

cat<<EOF >"/tmp/pod-config.json"
{
  "metadata": {
    "name": "${NAME}",
    "namespace": "default",
    "attempt": 1,
    "uid": "${NAME}g"
  },
  "logDirectory": "/tmp",
  "linux": {}
}
EOF
cat<<EOF >"/tmp/container-config.json"
{
  "metadata": {
    "name": "${NAME}g",
    "attempt": 2
  },
  "image":{
    "image": "docker.io/library/redis:alpine"
  },
  "log_path": "${NAME}.log",
  "linux": {}
}
EOF
# TODO: why does the relative log_path not work?

# TODO: at this layer does it default to running the iamges command, or is the higher level expected to parse and do it?
 # - yes, it will default to the image command, as we see here ( iremoed the command frm the linked guide, just to see)

sudo crictl pull "${image}"

podid="$(crictl --debug runp --runtime="${RUNTIME}" "/tmp/pod-config.json")"

# TODO: why is pod-config repeated, and passed by id???
# TODO: is it just PUT semantics?
containerid="$(crictl --debug create ${podid} /tmp/container-config.json /tmp/pod-config.json)"

# option 1 - run ash inside the container rootfs
# todo

# option 2 - run the default container command
sudo crictl start "${containerid}"
sleep 10000

# option 3 - run a command inside where redis is running
#sleep 1
#sudo crictl exec -i -t "${containerid}" top


# TODO: note that we should doc that ctr goes in fg, crictl puts it in bg when running default cmd

