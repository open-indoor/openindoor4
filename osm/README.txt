```
VERSION=1.0.13
docker build --label osm -t openindoor/osm .
docker tag                  openindoor/osm openindoor/osm:$VERSION
docker push                                openindoor/osm:$VERSION
```
