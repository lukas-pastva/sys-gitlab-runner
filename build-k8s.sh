#!/bin/sh

echo "Building image on Kubernetes via Kaniko, not using Docker build. Not using Docker, using Containerd"

export DESTINATION=${DESTINATION:-${CI_REGISTRY_IMAGE}/${CI_PROJECT_NAME}:${CI_COMMIT_SHORT_SHA}}
export DESTINATION_LATEST=${DESTINATION_LATEST:-${CI_REGISTRY_IMAGE}/${CI_PROJECT_NAME}:latest}
export CONTEXT=$(echo "$CI_REPOSITORY_URL#refs/heads/${CI_COMMIT_BRANCH}#${CI_COMMIT_SHA}" | sed 's|https://|git://|g')
export HASH=$(openssl rand -hex 4 | tr '[:upper:]' '[:lower:]')
export DOCKERCONFIGJSON=$(echo "{\"auths\":{\"$CI_REGISTRY\":{\"auth\":\"$(echo -n ${CI_REGISTRY_USER}:${CI_REGISTRY_PASSWORD} | base64)\"}}}" | base64 -w 0)

envsubst < /usr/local/bin/kaniko.yml > kaniko-${HASH}.yml

kubectl apply -f kaniko-${HASH}.yml
sleep 5

kubectl -n sys-runner-dind logs -f kaniko-${HASH}
sleep 5

kubectl delete -f kaniko-${HASH}.yml
