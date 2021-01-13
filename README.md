# OpenIndoor solution 4

This exposes some info about OpenIndoor under the hood.

This project is kubernetes (k8s) oriented.
All kube files are stored in kube folder

## Views

### Buildings

### Floors

### Indoor

## Developer side

### Local development

To build a single service locally

Example with openindoor-app:

```$ docker-compose build openindoor-app```

To make in run locally (work in progress...):

```$ docker-compose up openindoor-app```

To build altogether:

```$ docker-compose build```

To make run altogether:

```$ docker-compose up```

To run all after building:

```$ docker-compose up --build```

To clean, build and run altogether:

```$ docker-compose up --build --no-cache```

## Deployment

### To fix service version

Example with fonts-app:

```
$ cd fonts-app
# branch name may be any:
$ git tag 2.0.5
$ git push origin 2.0.5
```
fonts-app:2.0.5 docker image will be built and uploaded to the Docker Registry

To remove test tags you can use the command:
```
git tag --delete test
git push origin --delete test
```
Please note - it won't remote docker image from registry

Deployment to sandbox environment of fonts-app component with version 2.0.5 will be performer automatically.

### Deployment the whole stack to Validation environment

```
cd openindoor4
```
```
vim kube/base/kustomization.yml
```

Define the required versions.

All versions that we get in the previous section might be used here.

```
git commit -am "Update versions"
git push origin master:master
```

If you don't need to change the version but just to start the deployment you have to:

1. Go to "Actions" section by link:
````
https://github.com/open-indoor/openindoor4/actions
````
2. Open "Deploy to Validation environment" workflow
3. Click on "Run workflow" button.

## Services

### Back-end

Available at:

* https://app-sandbox.openindoor.io (sandbox)
* https://app-gke.openindoor.io (validation)
* https://app.openindoor.io (production)

Services are splitted as is:

* **front-api** serves all back-end services
* **places-api** manage bounds of building monitorized
* **osm-api** load data from OSM, relying on bound defined on places-api service
* **geosjon-api** get data from osm-api and convert xml .osm data tot geojson
* **mbtiles-api** convert geojson data to mbtiles to preapre Mapbox Vector Tiles service
* **mbtiles-country-api** merge data from mbtiles-api service for a given country
* **tileserver-api** serves data from mbtiles to Mapbox Vector Tiles

### Front-end

Available at:
* https://app-sandbox.openindoor.io (sandbox)
* https://app-gke.openindoor.io (validation)
* https://app.openindoor.io (production)

Services are splitted as is:

* **front-app** serves all front-end services
* **map-app** is the main web project
* **sprite-app** prepares all icons rendered in indoor views
* **style-app** manages all mapbox style rendering definitions
* **fonts-app** manages text policies
* **rastertiles-app** is a cache for OSM raster tiles
