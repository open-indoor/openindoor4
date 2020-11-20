#!/usr/bin/python3

# set -x
# set -e
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

addr = os.environ['PATH_INFO'].split('/')
apiDomainName = os.environ['API_DOMAIN_NAME']
action = addr[0]
country = addr[1]
place = addr[2].replace('.geojson', '')

myUuid = uuid.uuid1()

def getChecksum(country, place):
    with open(osmFile, 'wb') as file:
        url = 'http://osm-api' + '/osm/' + country + '/' + myId + '.cksum'
        crl = pycurl.Curl()
        crl.setopt(crl.URL, url)
        crl.setopt(crl.WRITEDATA, file)
        crl.perform()
        if (crl.getinfo(pycurl.HTTP_CODE) >= 400):
            print('HTTP/1.1 404 Not Found')
            print('Content-type: application/json')
            print('')
            print('{"country": "' + country + '", "id": "' + place + '", "checksum": 0}')
            exit(0)
        crl.close()

def getBounds(country, place):
    
# get checksum (if mandatory) => function
# get place in geojson (if mandatory) => function

geojsonFile = '/tmp/geojson/' + country + '/' + place + '_' + cksum + '.geojson'
geojsonFilePipe = '/tmp/geojsonPipe/' + country + '/' + place + '.geojson'
if (action == 'status'):
    # {"id":"FranceParisGareDeLEst", "status": "not found"}
    # Check if file exists locally
    status = 'not found'
    if os.path.isfile(geojsonFile):
        status = 'ready'
    elif os.path.isfile(geojsonFilePipe)
        status = 'in progress'
    else
        status = 'not found'
    print('Content-type: application/json')
    print('')
    print('{"id":"' + place + '", "status": "' + status + '"}')
    exit(0)
elif (action == 'trigger'):


myId = addr[2].replace('.geojson', '')



geojsonFileTmp = '/tmp/' + country + '_' + \
    myId + '_' + str(myUuid) + '.geojson'
placeFile = '/tmp/' + country + '_' + myId + \
    '_' + str(myUuid) + '_bounds.geojson'

osmFile = '/tmp/' + myId + '_' + str(myUuid) + '.osm'


if act
with open(osmFile, 'wb') as file:
    url = osmApiUrl + '/' + country + '/' + myId + '.osm'
    # print('url: ' + url)
    crl = pycurl.Curl()
    crl.setopt(crl.URL, url)
    crl.setopt(crl.WRITEDATA, file)
    crl.perform()
    if (crl.getinfo(pycurl.HTTP_CODE) >= 400):
        print('HTTP/1.1 404 Not Found')
        print('Content-type: application/json')
        print('')
        exit(0)
    crl.close()

# http://api-local.openindoor.io/places/data/france/FranceParisGareDeLEst
with open(placeFile, 'wb') as file:
    url = placesApiUrl + '/data/' + country + '/' + myId
    # print('url: ' + url)
    crl = pycurl.Curl()
    crl.setopt(crl.URL, url)
    crl.setopt(crl.WRITEDATA, file)
    crl.perform()
    if (crl.getinfo(pycurl.HTTP_CODE) >= 400):
        print('HTTP/1.1 404 Not Found')
        print('Content-type: application/json')
        print('')
        exit(0)
    crl.close()

print('Content-type: application/json')
print('')

# osmtogeojson -m "${osmFile}" > "${geojsonFileTmp}"
os.system('osmtogeojson -m ' + osmFile + ' > ' + geojsonFileTmp)

with open(geojsonFileTmp) as json_file:
    geojson = json.load(json_file)
    regMulti = re.compile(r'^(-?\d+\.?\d*).*;(-?\d+\.?\d*)$')
    regMinus = re.compile(r'^(-?\d+\.?\d*)-(-?\d+\.?\d*)$')
    for feature in geojson['features']:
        if (('properties' in feature) and ('level' in feature['properties'])):
            level = feature['properties']['level']
            level = regMulti.sub(r'\1;\2', level)
            level = regMinus.sub(r'\1;\2', level)
            if (regMulti.match(level)):
                num1 = float(regMulti.sub(r'\1', level))
                num2 = float(regMulti.sub(r'\2', level))
                if (num1 > num2):
                    level = regMulti.sub(r'\2;\1', level)
            feature['properties']['level'] = level


    # print(json.dumps(geojson))


    geojsonIo = io.StringIO(json.dumps(geojson))
    place = geopandas.read_file(geojsonIo)
    # file = open(placeFile)
    # bounds = geopandas.read_file(file)

    # selection = geopandas.clip(place, bounds, True)
    # print(selection.to_json(na='drop'))
    print(place.to_json(na='drop'))

exit (0)
