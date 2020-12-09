#!/usr/bin/python3

import os
import uuid
import pycurl
import codecs
import re
import json
import geopandas
import io

myUuid = str(uuid.uuid1())

def getChecksum(country, place):
    buffer = io.BytesIO()
    url = 'http://osm-api/osm/' + country + '/' + place + '.cksum'
    print('downloading: ' + url)
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
    print('downloaded: ' + url)
    result = body.decode('utf-8').rstrip('\n')
    print('cksum: |-' + result + '-|')
    return result

def getOsm(country, place, myUuid):
    osmFileTmp = '/tmp/osm/' + country + '/' + place + '_' + myUuid + '.osm'
    os.makedirs(os.path.dirname(osmFileTmp), exist_ok=True)
    with open(osmFileTmp, 'wb') as file:
        url = 'http://osm-api/osm/' + country + '/' + place + '.osm'
        print('downloading: ' + url)
        crl = pycurl.Curl()
        crl.setopt(crl.URL, url)
        crl.setopt(crl.WRITEDATA, file)
        crl.perform()
        if (crl.getinfo(pycurl.HTTP_CODE) >= 400):
            print('HTTP/1.1 404 Not Found')
            print('Content-type: application/json')
            print('')
            print('{"country": "' + country + '", "id": "' + place + '", "message": "file unavailable"}')
            exit(0)
        crl.close()
        print('downloaded: ' + url)
    osmFile = '/tmp/osm/' + country + '/' + place + '_' + getChecksum(country, place) + '.osm'
    os.makedirs(os.path.dirname(osmFile), exist_ok=True)
    print('osmFileTmp: ' + osmFileTmp)
    os.rename(osmFileTmp, osmFile)
    print('osmFile: ' + osmFile)
    return osmFile

def osmToGeojson(osmFile, geojsonFile):
    cmd = ('osmtogeojson -m ' + osmFile + ' > ' + geojsonFile)
    print('start cmd: ' + cmd)
    os.system(cmd)
    print('cmd done.')
    print('alter geojson: ' + geojsonFile)
    with open(geojsonFile) as json_file:
        geojson = json.load(json_file)
        regMulti = re.compile(r'^(-?\d+\.?\d*).*;(-?\d+\.?\d*)$')
        regMinus = re.compile(r'^(-?\d+\.?\d*)-(-?\d+\.?\d*)$')
        for feature in geojson['features']:
            # del feature['id']
            if ((not 'id' in feature) or (not feature['id'])):
                feature['id'] = str(uuid.uuid1())
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
    with open(geojsonFile, 'w') as outfile:
        json.dump(geojson, outfile)

    # print(json.dumps(geojson))
    # geojsonIo = io.StringIO(json.dumps(geojson))
    # print('geopandasize...')
    # place = geopandas.read_file(geojsonIo)
    # print('geopandasizes !')
    # file = open(placeFile)
    # bounds = geopandas.read_file(file)
    # selection = geopandas.clip(place, bounds, True)
    # print(selection.to_json(na='drop'))
    # print(place.to_json(na='drop'))

pipeDir = '/tmp/geojsonPipe'
os.makedirs(pipeDir, exist_ok=True)
for country in os.listdir(pipeDir):
    print('country: ' + country)
    for boundsFile in os.listdir('/tmp/geojsonPipe/' + country):
        print('boundsFile: ' + boundsFile)
        if not boundsFile.endswith("_bounds.geojson"):
            continue
        # Get bounds
        place = re.sub('_bounds\.geojson$', '', boundsFile)
        print('place: ' + place)
        cksum = getChecksum(country, place)
        print('cksum: ' + cksum)
        geojsonFile = '/tmp/geojson/' + country + '/' + place + '_' + cksum + '.geojson'
        if os.path.isfile(geojsonFile):
            continue
        # Create geojson
        osmFile = getOsm(country, place, myUuid)

        print('osmFile: ' + osmFile)
        geojsonFileTmp = '/tmp/geojson/' + country + '/' + place + '_' + myUuid + '.geojson'
        print('geojsonFileTmp: ' + geojsonFileTmp)
        # mkdir basename geojsonFile
        os.makedirs(os.path.dirname(geojsonFile), exist_ok=True)
        osmToGeojson(osmFile, geojsonFileTmp)
        os.rename(geojsonFileTmp, geojsonFile)
        print('geojsonFile: ' + geojsonFile)
        dst = '/tmp/geojson/' + country + '/' + place + '.geojson'
        dst2 = '/tmp/geojson/' + country + '/' + place
        os.symlink(geojsonFile, dst)
        os.symlink(geojsonFile, dst2)
        print('dst: ' + dst)
        print('dst2: ' + dst2)
