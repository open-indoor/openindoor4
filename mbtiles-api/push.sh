#!/bin/bash

set -x
set -e

SERVICE=mbtiles-api
IMAGE=openindoor/${SERVICE}
VERSION=${1:-1.0.0}
docker build --label ${IMAGE} -t \
           ${IMAGE} .
docker tag ${IMAGE} ${IMAGE}:$VERSION
docker push         ${IMAGE}:$VERSION
