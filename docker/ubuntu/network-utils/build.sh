#!/bin/sh

BUILD_DATE=$(date -u +'%Y-%m-%d-%H:%M:%S')
ORG='edowson'
IMAGE='ubuntu-network-utils'
IMAGE_FEATURE=${2:-""}
REPOSITORY="$ORG/$IMAGE"
BUILD_VERSION=${1:-"bionic"}
CODE_NAME="$BUILD_VERSION"
TAG="$BUILD_VERSION"
OPTION=${3:-""}

# map os code name to os version
if [ $CODE_NAME = "xenial" ]; then
  OS_VERSION='16.04';
elif [ $CODE_NAME = "bionic" ]; then
  OS_VERSION='18.04';
fi

# use tar to dereference the symbolic links from the current directory,
# and then pipe them all to the docker build - command
tar -czh . | docker build - \
  --pull=false \
  --file Dockerfile \
  --build-arg REPOSITORY="ubuntu" \
  --build-arg TAG="$OS_VERSION" \
  --build-arg BUILD_VERSION=$BUILD_VERSION \
  --tag=${REPOSITORY}:${TAG}
