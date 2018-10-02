#!/usr/bin/env bash

set -x
set -euo pipefail

[[ "${1:-}" == "kata" ]] && RUNTIME2="kata"
[[ "${1:-}" == "runc" ]] && RUNTIME2="runc"

[[ "${RUNTIME2:-}" == "" ]] && echo "first arg is runtime (kata|runc)" && exit -1

NAME="redis-crictl-${RUNTIME2}"
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

podid="$(crictl --debug runp --runtime="${RUNTIME2}" "/tmp/pod-config.json")"

# TODO: why is pod-config repeated, and passed by id???
# TODO: is it just PUT semantics?
containerid="$(crictl --debug create ${podid} /tmp/container-config.json /tmp/pod-config.json)"

# option 1 - run ash inside the container rootfs
# todo

# option 2 - run the default container command
sudo crictl start "${containerid}"

# option 3 - run a command inside where redis is running
#sleep 1
#sudo crictl exec -i -t "${containerid}" top


# TODO: note that we should doc that ctr goes in fg, crictl puts it in bg when running default cmd

