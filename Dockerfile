FROM alpine:3.3
MAINTAINER Vladimir Timofeev vovkasm@gmail.com

ENV DOCKER_GEN_VERSION=0.7.0 S6_OVERLAY_VERSION=v1.17.2.0 DOCKER_HOST=unix:///tmp/docker.sock

RUN apk add --no-cache ca-certificates curl nginx \
    && curl -sSL https://github.com/just-containers/s6-overlay/releases/download/$S6_OVERLAY_VERSION/s6-overlay-amd64.tar.gz | tar -C / -xzf - \
    && curl -sSL https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz | tar -C /usr/local/bin -xzf -

COPY rootfs /

ENTRYPOINT ["/init"]
