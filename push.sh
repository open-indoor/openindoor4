#!/bin/bash

set -x
set -e

SERVICE=$1
IMAGE=openindoor/${SERVICE}
VERSION=${2:-1.0.0}
docker build --label ${IMAGE} \
    -t    ${IMAGE} ${SERVICE}
# docker tag ${IMAGE} fofgjdxp.gra7.container-registry.ovh.net/${IMAGE}:$VERSION
docker tag ${IMAGE} ${IMAGE}:$VERSION
# docker login --username openindoor --password $DOCKER_PASS fofgjdxp.gra7.container-registry.ovh.net/openindoor
# docker push         fofgjdxp.gra7.container-registry.ovh.net/${IMAGE}:$VERSION
docker push         ${IMAGE}:$VERSION
