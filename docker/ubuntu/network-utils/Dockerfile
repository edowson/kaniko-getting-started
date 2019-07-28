# edowson/ubuntu-network-utils:$BUILD_VERSION

ARG REPOSITORY
ARG TAG
FROM ${REPOSITORY}:${TAG}
LABEL maintainer "Elvis Dowson <elvis.dowson@gmail.com>"

# setup environment variables
ENV container docker

# set the locale
ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8

# install packages
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive TERM=linux apt-get install -q -y \
    inetutils-ping \
    inetutils-traceroute \
    net-tools \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# args
ARG BUILD_VERSION

# labels
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="edowson/ubuntu-network-utils:$BUILD_VERSION"
LABEL org.label-schema.description="Ubuntu Network Utilities - $BUILD_VERSION."
LABEL org.label-schema.vcs-url="https://github.com/edowson/kaniko-getting-started"
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.docker.cmd="xhost +local:root \
docker run -it \
  --runtime=nvidia \
  -e DISPLAY=":1" \
  -v /etc/localtime:/etc/localtime:ro \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  --rm \
  --name ubuntu-network-utils-$BUILD_VERSION \
  edowson/ubuntu-network-utils:$BUILD_VERSION \
xhost -local:root"

CMD ["bash"]
