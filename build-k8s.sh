#!/bin/sh

echo "Building image on Kubernetes via Kaniko, not using Docker build. Not using Docker, using Containerd"

# Check if CI_COMMIT_BRANCH is empty and attempt to fetch branch name
if [ -z "$CI_COMMIT_BRANCH" ]; then
    echo "CI_COMMIT_BRANCH is empty, attempting to fetch branch name..."
    # Fetch all history for branches and tags
    git fetch --unshallow || git fetch --all
    # Attempt to find the branch name associated with the current commit
    CI_COMMIT_BRANCH=$(git branch -r --contains $CI_COMMIT_SHA | grep -v 'HEAD' | sed -E 's/^\s*origin\///' | head -n 1)
    if [ -n "$CI_COMMIT_BRANCH" ]; then
        echo "Found branch name: $CI_COMMIT_BRANCH"
    else
        echo "Failed to find branch name, using default 'main'"
        CI_COMMIT_BRANCH="main"
    fi
fi

export DESTINATION=${DESTINATION:-${CI_REGISTRY_IMAGE}/${CI_PROJECT_NAME}:${CI_COMMIT_SHORT_SHA}}
export DESTINATION_LATEST=${DESTINATION_LATEST:-${CI_REGISTRY_IMAGE}/${CI_PROJECT_NAME}:latest}
export CONTEXT=$(echo "$CI_REPOSITORY_URL#refs/heads/${CI_COMMIT_BRANCH}#${CI_COMMIT_SHA}" | sed 's|https://|git://|g')
export HASH=$(openssl rand -hex 4 | tr '[:upper:]' '[:lower:]')
export DOCKERCONFIGJSON=$(echo "{\"auths\":{\"$CI_REGISTRY\":{\"auth\":\"$(echo -n ${CI_REGISTRY_USER}:${CI_REGISTRY_PASSWORD} | base64)\"}}}" | base64 -w 0)

envsubst < /usr/local/bin/kaniko-secret.yml > kaniko-secret-${HASH}.yml
envsubst < /usr/local/bin/kaniko-pod.yml > kaniko-pod-${HASH}.yml

echo "Starting Kaniko job with variables: DESTINATION: ${DESTINATION}, DESTINATION_LATEST: ${DESTINATION_LATEST}, CONTEXT: ${CONTEXT}, CONTEXT_PATH: ${CONTEXT_PATH}, DOCKERFILE: ${DOCKERFILE}"

echo "Creating Kaniko Secret"
kubectl apply -f kaniko-secret-${HASH}.yml
sleep 3

echo "Creating Kaniko Pod"
kubectl apply -f kaniko-pod-${HASH}.yml
sleep 5

fetch_logs() {
    kubectl -n sys-gitlab logs kaniko-pod-${HASH}
}
check_pod_status() {
    kubectl get pods -n sys-gitlab kaniko-pod-${HASH} -o=jsonpath='{.status.phase}'
}

echo "Starting loop in which we wil lbe getting logs each 5 seconds"
while true; do
    fetch_logs
    sleep 5
    STATUS=$(check_pod_status)
    echo "STATUS: $STATUS"
    if [ "$STATUS" = "Error" ] || [ "$STATUS" = "Succeeded" ]; then
        echo "FINISHED"
        break
    fi
done

sleep 5
#kubectl delete -f kaniko-pod-${HASH}.yml
#kubectl delete -f kaniko-secret-${HASH}.yml