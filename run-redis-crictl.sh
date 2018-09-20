#!/usr/bin/env bash

set -x
set -euo pipefail

# FOLLOW: https://github.com/kubernetes-sigs/cri-tools/blob/master/docs/crictl.md
# requires patch: https://github.com/kubernetes-sigs/cri-tools/pull/383

RUNTIME="kata"

crictl stopp $(crictl pods -q)
crictl rmp $(crictl pods -q)

image="docker.io/library/redis:alpine"

cat<<EOF >"/tmp/pod-config.json"
{
  "metadata": {
    "name": "redis0",
    "namespace": "default",
    "attempt": 1,
    "uid": "redis0"
  },
  "logDirectory": "/tmp",
  "linux": {}
}
EOF
cat<<EOF >"/tmp/container-config.json"
{
  "metadata": {
    "name": "redis0",
    "attempt": 2
  },
  "image":{
    "image": "docker.io/library/redis:alpine"
  },
  "log_path": "redis.log",
  "linux": {}
}
EOF
# TODO: why does the relative log_path not work?

# TODO: at this layer does it default to running the iamges command, or is the higher level expected to parse and do it?
 # - yes, it will default to the image command, as we see here ( iremoed the command frm the linked guide, just to see)

crictl pull "${image}"

podid="$(crictl --debug runp --runtime="${RUNTIME}" "/tmp/pod-config.json")"

# TODO: why is pod-config repeated, and passed by id???
containerid="$(crictl --debug create ${podid} /tmp/container-config.json /tmp/pod-config.json)"

crictl start "${containerid}"
sleep 1
crictl exec -i -t "${containerid}" top

