#!/bin/sh

echo "Installing ..."
docker-php-ext-configure imap --with-kerberos --with-imap-ssl
docker-php-ext-install imap

if [ -n "${DOCKER_GID}" ]; then
    groupmod -g "${DOCKER_GID}" docker
fi

/entrypoint.sh run --user=gitlab-runner --working-directory=/home/gitlab-runner