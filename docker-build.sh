#!/bin/sh

if [ -z "${DRONE_BUILD_NUMBER}" ]; then
  echo "Building locally"
  export LOCAL=true
fi

if [[ ! ${LOCAL} == 'true' ]]; then
  echo "Setting docker repo..."
  docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
fi

echo "Setting up build variables..."
GIT_COMMIT=$(git rev-list -1 HEAD)

echo "Setting up buildx..."
docker buildx version
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx create --name multiarch --use

echo "Building..."
if [[ ${LOCAL} == 'true' ]]
then
  docker buildx build --platform linux/amd64,linux/arm64 --build-arg GIT_COMMIT=${GIT_COMMIT} -f Dockerfile .
else
  docker buildx build --platform linux/amd64,linux/arm64 -t supporttools/k3s-janitor:${DRONE_BUILD_NUMBER} -t supporttools/k3s-janitor:latest --cache-from supporttools/k3s-janitor:latest --build-arg GIT_COMMIT=${GIT_COMMIT} --push -f Dockerfile .
fi