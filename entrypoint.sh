#!/bin/sh

echo "------------------------------------------------------------------------"
echo "Installing ..."
docker-php-ext-configure imap --with-kerberos --with-imap-ssl
docker-php-ext-install imap

if [ -n "${DOCKER_GID}" ]; then
    groupmod -g "${DOCKER_GID}" docker
fi

echo "------------------------------------------------------------------------"
echo "Starting runner ..."
gitlab-runner run
