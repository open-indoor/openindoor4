Persistent volume:

```
kubectl apply -f ./pv-volume.yaml
kubectl get pv task-pv-volume
```

Persistent volume claim:

```
kubectl apply -f pv-claim.yaml
kubectl get pv task-pv-volume
```

Pod using the volume:

```
kubectl apply -f pv-pod.yaml
kubectl get pod task-pv-pod
```

Docker registry:

```
docker build --label osm -t openindoor/osm .
docker tag openindoor/osm openindoor/osm:1.0.0
docker push               openindoor/osm:1.0.0
sudo apt-get install gpg pass
echo "docker_A1" | docker login -u openindoor --password-stdin
kubectl apply -f osm.yaml
kubectl logs osm-pod
kubectl exec -it osm-pod -- /bin/bash
```

