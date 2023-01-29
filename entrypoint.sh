#!/bin/sh

groupmod -g "${DOCKER_GID}" docker

/usr/bin/dumb-init
/entrypoint run --user=gitlab-runner --working-directory=/home/gitlab-runner