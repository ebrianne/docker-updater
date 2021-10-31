# Docker container to update compose file from a git repo

![Build/Push (master)](https://github.com/ebrianne/docker-updater/workflows/Build/Push%20(master)/badge.svg?branch=master)
[![Docker Pulls](https://img.shields.io/docker/pulls/ebrianne/docker-updater.svg)](https://hub.docker.com/r/ebrianne/docker-updater/)

## Quick Start

This container will run a script on a cron schedule to update the image tags of compose file from a git repository.
Currently only github is supported.

```
$ docker run  -v /$HOME:/git \
              -v /var/run/docker.sock:/var/run/docker.sock:ro \
              -e CRON_SCHEDULE="*/10 * * * *" \
              -e PLATFORM=github \
              -e GIT_REPO=<your repo> \
              -e BRANCH=<your branch> \
              -e SUB_PATH=<sub path from the root> \
              -e CLEAN_AFTER_UPDATE=1 \
              -e DEBUG=0
              ebrianne/docker-updater
```

## Docker Compose
```
version: '3'

services:
  updater:
    container_name: updater
    image: ebrianne/docker-updater:v1.0
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    volumes:
      - $HOME:/git
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - CRON_SCHEDULE="*/10 * * * *"
      - PLATFORM=github
      - GIT_REPO=<your repo>
      - BRANCH=master
      - SUB_PATH=<your sub path>
      - CLEAN_AFTER_UPDATE=1
      - DEBUG=0
```