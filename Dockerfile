FROM alpine:3.8

# set version for s6 overlay
ARG OVERLAY_VERSION="v1.21.7.0"
ARG OVERLAY_ARCH="amd64"

# environment variables
ENV PS1="$(whoami)@$(hostname):$(pwd)$ " \
HOME="/root" \
TERM="xterm"

RUN \
 echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
	tar && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	bash \
    curl \
    vim \
	ca-certificates \
	coreutils \
	shadow \
	tzdata && \
 echo "**** create bash aliases ****" && \
 echo "alias ll='ls -laG --color=auto'" > /root/.bashrc && \
 echo "**** add s6 overlay ****" && \
 curl -o \
 /tmp/s6-overlay.tar.gz -L \
	"https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz" && \
    tar xzf /tmp/s6-overlay.tar.gz -C / && \
 echo "**** create app user and make our folders ****" && \
 groupmod -g 1000 users && \
 useradd -u 911 -U -d /config -s /bin/false app && \
 usermod -G users app && \
 mkdir -p \
	/app \
	/config \
	/defaults && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

# add local files
COPY root/ /

ENTRYPOINT ["/init"]
