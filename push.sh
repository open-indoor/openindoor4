#!/bin/bash

set -x
set -e

SERVICE=$1
IMAGE=openindoor/${SERVICE}
VERSION=${2:-1.0.0}
docker build --label ${IMAGE} -t \
           ${IMAGE} ${SERVICE}
docker tag ${IMAGE} ${IMAGE}:$VERSION
docker push         ${IMAGE}:$VERSION
