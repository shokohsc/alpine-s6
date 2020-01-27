ARG FROM_TAG='latest'
FROM alpine:${FROM_TAG:-latest}

# set version for s6 overlay
ARG OVERLAY_VERSION="v1.22.1.0"
ARG OVERLAY_ARCH=${BUILDARCH:-amd64}

# environment variables
ENV PS1="$(whoami)@$(hostname):$(pwd)$ " \
HOME="/root" \
TERM="xterm"

RUN \
  echo "**** install build packages ****" && \
  apk update && \
  apk add --no-cache --virtual=build-dependencies \
    tar \
    openssl \
    gnupg \
    bash \
    curl \
    vim \
    ca-certificates \
    coreutils \
    shadow \
    tzdata && \
  echo "**** create bash aliases ****" && \
  echo "alias ll='ls -laGH --color=auto'" > /root/.bashrc && \
  echo "**** add s6 overlay ****" && \
  curl https://keybase.io/justcontainers/key.asc | gpg --import && \
  cd /tmp && \
  { curl -L --remote-name-all \
    "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz{,.sig}" ; ls -lah ; cd -; } && \
  echo "**** verify s6-overlay release download ****" && \
  gpg --verify "/tmp/s6-overlay-${OVERLAY_ARCH}.tar.gz.sig" "/tmp/s6-overlay-${OVERLAY_ARCH}.tar.gz" && \
  tar xzf "/tmp/s6-overlay-${OVERLAY_ARCH}.tar.gz" -C / && \
  echo "**** create app user and make our folders ****" && \
  groupmod -g 1000 users && \
  useradd -u 911 -U -d /config -s /bin/false app && \
  usermod -G users app && \
  mkdir -p \
    /var/www \
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
