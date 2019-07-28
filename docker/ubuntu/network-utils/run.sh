#!/bin/bash

# common variables
CURRENT_DIR=`pwd`
SCRIPT_DIR=`dirname $0`

# script variables
HOST_IP=`hostname -I | awk '{print $1}'`
DOCKER_DAEMON_IP=`ip -4 -o a | grep docker0 | awk '{print $4}'`
ORG='edowson'
IMAGE='ubuntu-network-utils'
IMAGE_FEATURE=${2:-""}
REPOSITORY="$ORG/$IMAGE"
BUILD_VERSION=${1:-"bionic"}
CODE_NAME="$BUILD_VERSION"
TAG="$BUILD_VERSION"
OPTION=${3:-""}

# run container
xhost +local:root
docker run -it \
  --runtime=nvidia \
  -e DISPLAY=":1" \
  -v /etc/localtime:/etc/localtime:ro \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  --rm \
  --name ${IMAGE}-${TAG} \
  ${REPOSITORY}:${TAG} bash

xhost -local:root
