#!/bin/bash

set -x
set -e

VERSION=${1:-1.0.0}
docker build --label osm -t openindoor/osm-caddy .
docker tag                  openindoor/osm-caddy  openindoor/osm-caddy:$VERSION
docker push                                       openindoor/osm-caddy:$VERSION

kubectl apply -f ../kube/osm-caddy.yaml
kubectl get pods
# kubectl exec -it osm-caddy-pod -- /bin/sh
