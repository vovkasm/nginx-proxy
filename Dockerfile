FROM nginx:alpine
MAINTAINER Vladimir Timofeev vovkasm@gmail.com

COPY rootfs /

RUN apk add --no-cache ca-certificates curl s6 \
    && mkdir -p /etc/nginx/conf.d

ENV DOCKER_GEN_VERSION 0.7.0
RUN curl -sSL https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz | tar -C /usr/local/bin -xzf -

ENV DOCKER_HOST unix:///tmp/docker.sock

EXPOSE 80 443

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["s6-svscan","/etc/s6"]
