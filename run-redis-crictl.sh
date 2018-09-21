#!/usr/bin/env bash

set -x
set -euo pipefail

# FOLLOW: https://github.com/kubernetes-sigs/cri-tools/blob/master/docs/crictl.md
# requires the kata-runtime/shimv2 pr to be merged

RUNTIME=""     # blank is containerd default
RUNTIME="runc" # i have a runc runtime explicitly configured as well
RUNTIME="kata" # kata-containers is "kata"

NAME="redis-crictl-${RUNTIME}"
image="docker.io/library/redis:alpine"

function cleanup() {
  sudo crictl stopp $(crictl pods -q)
  sudo crictl rmp $(crictl pods -q)
}
trap cleanup EXIT
cleanup

cat<<EOF >"/tmp/pod-config.json"
{
  "metadata": {
    "name": "${NAME}g",
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

sudo crictl start "${containerid}"
#sleep 1
#sudo crictl exec -i -t "${containerid}" top

