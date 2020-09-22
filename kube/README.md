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

# Ingress with helm

```
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
helm install nginx-stable/nginx-ingress
kubectl get services -o wide -w openindoor-nginx-ingress
helm show values nginx-stable/nginx-ingress
helm upgrade -f ingress-chart.yml nginx-stable/nginx-ingress
helm install --values values.yaml stable/traefik
```

# Traefik 2.X with helm

```
helm repo add traefik https://containous.github.io/traefik-helm-chart
helm repo update
helm install traefik traefik/traefik
helm install --namespace=traefik-v2 \
    --set="additionalArguments={--log.level=DEBUG}" \
    traefik traefik/traefik
helm install --values values.yaml traefik/traefik
helm upgrade traefik --set ports.traefik.expose=true traefik/traefik
```

# traefik 1.7 with helm

```
helm install traefik stable/traefik
kubectl get svc traefik --namespace default -w
kubectl describe svc traefik --namespace default | grep Ingress | awk '{print $3}'
helm install traefik --values traefik-values.yml stable/traefik
```