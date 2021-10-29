FROM docker/compose:1.29.2

ARG TARGETARCH
ENV OVERLAY_VERSION="v2.2.0.3" \
    TZ=Europe/Berlin \
    PLATFORM="github" \
    BRANCH="master" \
    CRON_SCHEDULE="*/10 * * * *" \
    CLEAN_AFTER_UPDATE=0 \
    HOME=/git

RUN apk update \
    && apk upgrade \
    && apk add --no-cache wget bash \
    && apk add --no-cache yq --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
    && mkdir /app /git

# Apply the s6-overlay
RUN apk add curl \
    && case ${TARGETARCH} in arm|arm/v7) ARCH="armhf" ;; arm/v6) ARCH="arm" ;; arm64|arm/v8) ARCH="aarch64" ;; 386) ARCH="x86" ;; amd64) ARCH="amd64" ;; esac \
    && curl -SL -o /tmp/s6-overlay-${ARCH}-installer "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${ARCH}-installer" \
    && chmod +x /tmp/s6-overlay-${ARCH}-installer \
    && /tmp/s6-overlay-${ARCH}-installer / \
    && rm /tmp/s6-overlay-${ARCH}-installer 

# Cleanup
RUN apk del curl \
    && rm -rf /tmp/* /var/lib/apt/lists/*
    
COPY root /
COPY updater.sh /app

WORKDIR /git

ENTRYPOINT [ "/init" ]