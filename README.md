# OpenIndoor solution 4

This exposes some info about OpenIndoor under the hood.

This project is kubernetes (k8s) oriented.
All kube files are stored in kube folder

## Views

### Buildings

### Floors

### Indoor

## Developer side

To make in run locally (work in progress...):

```$ docker-compose up```

To build a service locally and push it to docker.io:

```$ ./push $SERVICE $ VERSION```

e.g.:

```$ ./push places-api 1.0.0```

To deploy in Google Kubernetes Env:

```$ kubectl apply -k kube/gke```

To deploy in OVH k8s env:

```$ kubectl apply -k kube/ovh5```

### Back-end

Services are splitted as is:

* **front-api** serves all back-end services
* **places-api** manage bounds of building monitorized
* **osm-api** load data from OSM, relying on bound defined on places-api service
* **geosjon-api** get data from osm-api and convert xml .osm data tot geojson
* **mbtiles-api** convert geojson data to mbtiles to preapre Mapbox Vector Tiles service
* **mbtiles-country-api** merge data from mbtiles-api service for a given country
* **tileserver-api** serves data from mbtiles to Mapbox Vector Tiles

### Front-end

* **front-app** serves all front-end services
* **map-app** is the main web project
* **sprite-app** prepares all icons rendered in indoor views
* **style-app** manages all mapbox style rendering definitions
* **fonts-app** manages text policies
* **rastertiles-app** is a cache for OSM raster tiles
