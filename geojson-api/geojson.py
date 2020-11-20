#!/usr/bin/python3

# set -x
# set -e
# PATH_INFO="status/germany/GermanyKarlsruheEngesser" /geojson/geojson
# PATH_INFO="trigger/germany/GermanyKarlsruheEngesser" /geojson/geojson
# PATH_INFO="data/france/FranceParisGareDeLEst" /geojson/geojson
# PATH_INFO="data/france/FranceRennesCampusDeVillejean" /geojson/geojson
# PATH_INFO="data/costa_rica/CostaRicaSanJoseStarbucks" /geojson/geojson
# PATH_INFO="data/united_states/UnitedStatesLosAngelesUnionStation" /geojson/geojson
# PATH_INFO="data/germany/GermanyKarlsruheEngesser" /geojson/geojson

import os
import uuid
import pycurl
import codecs
# import osm2geojson
import re
import json
import geopandas
import io
import pathlib

addr = os.environ['PATH_INFO'].split('/')
apiDomainName = os.environ['API_DOMAIN_NAME']
action = addr[0]
country = addr[1]
place = addr[2].replace('.geojson', '')

myUuid = uuid.uuid1()

def geojsonFilePipe(country, place):
    return '/tmp/geojsonPipe/' + country + '/' + place + '_bounds.geojson'

def getChecksum(country, place):
    buffer = io.BytesIO()
    url = 'http://osm-api/osm/' + country + '/' + place + '.cksum'
    crl = pycurl.Curl()
    crl.setopt(crl.URL, url)
    crl.setopt(crl.WRITEDATA, buffer)
    crl.perform()
    if (crl.getinfo(pycurl.HTTP_CODE) >= 400):
        print('HTTP/1.1 404 Not Found')
        print('Content-type: application/json')
        print('')
        print('{"country": "' + country + '", "id": "' + place + '", "message": "checksum unavailable"}')
        exit(0)
    crl.close()
    body = buffer.getvalue()
    return body.decode('utf-8')

def queue(country, place):
    jsonPipe = geojsonFilePipe(country, place)
    print('jsonPipe:' + jsonPipe)
    print('os.path.dirname(jsonPipe):' + os.path.basename(jsonPipe))
    pathlib.Path(os.path.dirname(jsonPipe)).mkdir(parents=True, exist_ok=True)
    with open(jsonPipe, 'wb') as file:
        # https://api-gke.openindoor.io/places/data/france/FranceParisGareDeLEst
        url = 'http://places-api/places/data/' + country + '/' + place
        crl = pycurl.Curl()
        crl.setopt(crl.URL, url)
        crl.setopt(crl.WRITEDATA, file)
        crl.perform()
        if (crl.getinfo(pycurl.HTTP_CODE) >= 400):
            print('HTTP/1.1 404 Not Found')
            print('Content-type: application/json')
            print('')
            print('{"country": "' + country + '", "id": "' + place + '", "message": "checksum unavailable"}')
            exit(0)
        crl.close()

cksum = getChecksum(country, place)
geojsonFile = '/tmp/geojson/' + country + '/' + place + '_' + cksum + '.geojson'

if (action == 'status'):
    status = 'not found'
    if os.path.isfile(geojsonFile):
        status = 'ready'
    elif os.path.isfile(geojsonFilePipe(country, place)):
        status = 'in progress'
    print('Content-type: application/json')
    print('')
    print('{"id":"' + place + '", "format": "geojson", "status": "' + status + '"}')
    exit(0)
elif (action == 'trigger'):
    queue(country, place)
    print('Content-type: application/json')
    print('')
    print('{"id":"' + place + '", "status": "in progress"}')
    exit(0)
elif (action == 'data'):
    if os.path.isfile(geojsonFile):
        print('Content-type: application/json')
        print('')
        with open(geojsonFile) as json_file:
            print(json_file)
        exit(0)
