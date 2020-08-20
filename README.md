# Overpass request examples

```
curl $'http://z.overpass-api.de/api/interpreter?data=\[out:json\]\[timeout:25\]\[bbox:48.87668685653574,2.3570704561315097,48.87788473295913,2.3592253914053742\];(way\[%22indoor%22\]\[%22indoor%22\u0021=%22yes%22\];relation\[%22indoor%22\]\[%22indoor%22\u0021=%22yes%22\];way\[%22buildingpart%22~%22room|verticalpassage|corridor%22\];relation\[%22buildingpart%22~%22room|verticalpassage|corridor%22\];node\[~%22amenity|shop|railway|highway|door|entrance%22~%22.%22\];way\[~%22amenity|shop|railway|highway|building:levels%22~%22.%22\];relation\[~%22amenity|shop|railway|highway|building:levels%22~%22.%22\];);out%20body;%3E;out%20skel%20qt;' \
  -H 'Connection: keep-alive' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.105 Safari/537.36' \
  -H 'Accept: */*' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Referer: http://localhost/' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  --compressed

    https://lz4.overpass-api.de/api/interpreter
https://z.overpass-api.de/api/interpreter
http://overpass.openstreetmap.fr/api/interpreter
http://overpass.osm.ch/api/interpreter
https://overpass.kumi.systems/api/interpreter
https://overpass.nchc.org.tw/api/interpreter
http://www.overpass-api.de/api/interpreter
```

curl $'http://localhost/overpass/api/interpreter?data=\[out:json\]\[timeout:25\]\[bbox:48.87668685653574,2.3570704561315097,48.87788473295913,2.3592253914053742\];(way\[%22indoor%22\]\[%22indoor%22\u0021=%22yes%22\];relation\[%22indoor%22\]\[%22indoor%22\u0021=%22yes%22\];way\[%22buildingpart%22~%22room|verticalpassage|corridor%22\];relation\[%22buildingpart%22~%22room|verticalpassage|corridor%22\];node\[~%22amenity|shop|railway|highway|door|entrance%22~%22.%22\];way\[~%22amenity|shop|railway|highway|building:levels%22~%22.%22\];relation\[~%22amenity|shop|railway|highway|building:levels%22~%22.%22\];);out%20body;%3E;out%20skel%20qt;' \
  -H 'Connection: keep-alive' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.105 Safari/537.36' \
  -H 'Accept: */*' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Referer: http://localhost/' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  --compressed

0.0.0.0:80 {

    log {
        level DEBUG
    }
    
    encode gzip
    templates

    file_server browse {
        root /openindoor
    }

    header / Access-Control-Allow-Origin  *

    reverse_proxy /overpasscache/api/interpreter varnishCache:80/api/interpreter {
    }

    reverse_proxy /overpass/api/interpreter {
        to lz4.overpass-api.de:443/api/interpreter
        to z.overpass-api.de:443/api/interpreter
        to overpass.openstreetmap.fr:443/api/interpreter
        to overpass.osm.ch:443/api/interpreter
        to overpass.kumi.systems:443/api/interpreter
        to overpass.nchc.org.tw:443/api/interpreter
        to www.overpass-api.de:443/api/interpreter
    }

}

            to https://z.overpass-api.de:443
            to https://lz4.overpass-api.de:443
            to http://www.overpass-api.de:80

# Own instance documentation

https://dev.overpass-api.de/no_frills.html


curl $'https://z.overpass-api.de/api/interpreter?data=\[out:json\]\[timeout:25\]\[bbox:48.87668685653574,2.3570704561315097,48.87788473295913,2.3592253914053742\];(way\[%22indoor%22\]\[%22indoor%22\u0021=%22yes%22\];relation\[%22indoor%22\]\[%22indoor%22\u0021=%22yes%22\];way\[%22buildingpart%22~%22room|verticalpassage|corridor%22\];relation\[%22buildingpart%22~%22room|verticalpassage|corridor%22\];node\[~%22amenity|shop|railway|highway|door|entrance%22~%22.%22\];way\[~%22amenity|shop|railway|highway|building:levels%22~%22.%22\];relation\[~%22amenity|shop|railway|highway|building:levels%22~%22.%22\];);out%20body;%3E;out%20skel%20qt;' \
  -H 'Connection: keep-alive' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.105 Safari/537.36' \
  -H 'Accept: */*' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Referer: http://localhost/' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  --compressed

ogr2ogr -f MBTILES EastStation.mbtiles EastStation.xml -dsco MAXZOOM=22

    tls {
        ca https://acme-staging-v02.api.letsencrypt.org/directory
    }
