#!/usr/bin/python3

# PATH_INFO="pins/world/html" /places/places
# PATH_INFO="countries/world/json" /places/places
# PATH_INFO="data/" /places/places
# PATH_INFO="data/world" /places/places
# PATH_INFO="data/france" /places/places
# PATH_INFO="pins/france/geojson" /places/places
# PATH_INFO="pins/france/html" /places/places
# PATH_INFO="checksum/france/text" /places/places

# places/checksum/world
# places/bboxes/world
# places/bboxes/world/html
# places/bboxes/france
# places/countries/world
# places/pins/world
# places/pins/france

import os
import uuid
import pycurl
from io import BytesIO
from pathlib import Path
import geojson
import json
import hashlib
from turfpy.measurement import centroid
import pycurl
import io

addr = os.environ['PATH_INFO'].split('/')
apiDomainName = os.environ['API_DOMAIN_NAME']
appUrl = os.environ['APP_URL'] if 'APP_URL' in os.environ else (
    'https://' + apiDomainName)

action = addr[0] if (len(addr) > 0) else ""
country = addr[1] if (len(addr) > 1) else ""
arg3 = addr[2] if (len(addr) > 2) else ""
myUuid = uuid.uuid1()

PLACES_DIR = '/data/places'

directory_in_str = ''
fileSearch = '**/*.geojson'
if ((country == "world") or (not country)):
    country = "world"
    directory_in_str = PLACES_DIR
else:
    directory_in_str = PLACES_DIR + '/' + country
    if action != "pins" and arg3:
        # arg3 as id
        fileSearch = '**/' + arg3 + '.geojson'

myPlaces = {
    "type": "FeatureCollection",
    "generator": "JOSM",
    "features": []
}
# loop on file, country oriented
pathlist = Path(directory_in_str).glob(fileSearch)
for path in pathlist:
    # because path is object not string
    path_to_file = str(path)
    # print('path: ' + path_to_file)
    with open(path_to_file) as f:
        gj = geojson.load(f)
    myPlaces['features'].append(gj['features'][0])
    # print(path_in_str)

m = hashlib.md5()
# print('str(myPlaces).encode(utf-8):')
# print(str(myPlaces).encode('utf-8'))
m.update(str(myPlaces).encode('utf-8'))
checksum = m.hexdigest()

if (action == 'checksum'):
    print('Content-type: text/plain')
    print('')
    print(checksum)
    exit(0)
elif (action == 'pins'):
    # pinsCache = '/tmp/places/' + country + \
    #     '_pins_' + str(checksum) + '.geojson'
    # if not Path(pinsCache).is_file():
    if True:
        pins = {
            "type": "FeatureCollection",
            "generator": "JOSM",
            "features": []
        }
        for feature in myPlaces['features']:
            # print(feature)
            centroid_ = centroid(feature)
            centroid_['properties'] = feature['properties']
            centroid_['properties']['title'] = feature['properties']['place']
            pins['features'].append(centroid_)
        # with open(pinsCache, 'w') as outfile:
        #     json.dump(pins, outfile)

    format = arg3
    if (format == 'html'):
        print('Content-type: text/html')
        print('')
        lastCountry = ''
        print('<!DOCTYPE html><html><body><table border=4><tr>')
        print('<td>map</td>')
        print('<td>checksum</td>')
        print('<td>osm</td>')
        print('<td>geojson</td>')
        print('<td colspan="3"; style="text-align: center; vertical-align: middle;">mbtiles</td>')
        for f in pins['features']:
            country = str(f['properties']['country']).lower().replace(' ', '_')
            myId = f['properties']['id']

            if country != lastCountry:
                lastCountry = country
                country_statusText = ''
                
                # buffer = BytesIO()
                # crl = pycurl.Curl()
                # url = 'http://mbtiles-country-api/mbtiles-country/status/' + country
                # crl.setopt(crl.URL, url)
                # crl.setopt(crl.WRITEDATA, buffer)
                # crl.perform()
                # if (crl.getinfo(pycurl.HTTP_CODE) >= 400):
                #     print('HTTP/1.1 404 Not Found')
                #     print('Content-type: application/json')
                #     print('')
                #     exit(0)
                # crl.close()
                # body = buffer.getvalue()
                # country_status = json.loads(body.decode('utf-8'))['status']
                # if country_status == "ready":
                #     color = "#00FF00"
                # elif country_status == "in progress":
                #     color = "#FF7F00"
                # else:
                #     color = "#FF0000"
                # country_statusText = '<b style="color:' + color + '";>' + country_status + '</b>'



                print('<tr><td colspan="4"; style="text-align: center; vertical-align: middle;">' + country + '</td>')
                print('<td><a href="/mbtiles/status/' + country + '">' + country_statusText + '</a></td>')
                print('<td><button onclick="fetch(\'/mbtiles-country/trigger/' + country + '\')">trigger</button></td>')
                # print('<td><a href="/mbtiles/data/' + country + '">download</a></td>')
                print('<td></td>')

                print('</tr>')

            # GET STATUS
            buffer = BytesIO()
            crl = pycurl.Curl()
            url = 'http://mbtiles-api/mbtiles/status/' + country + '/' + myId
            crl.setopt(crl.URL, url)
            crl.setopt(crl.WRITEDATA, buffer)
            crl.perform()
            if (crl.getinfo(pycurl.HTTP_CODE) >= 400):
                print('HTTP/1.1 404 Not Found')
                print('Content-type: application/json')
                print('')
                print('url: ' + url)
                exit(0)
            crl.close()
            body = buffer.getvalue()
            status = json.loads(body.decode('utf-8'))['status']
            if status == "ready":
                color = "#00FF00"
            elif status == "in progress":
                color = "#FF7F00"
            else:
                color = "#FF0000"
            statusText = '<b style="color:' + color + '";>' + status + '</b>'

            # GET CHECKSUM
            buffer = BytesIO()
            crl = pycurl.Curl()
            url = 'http://osm-api/osm/' + country + '/' + myId + '.cksum'
            crl.setopt(crl.URL, url)
            crl.setopt(crl.WRITEDATA, buffer)
            crl.perform()
            if (crl.getinfo(pycurl.HTTP_CODE) >= 400):
                print('HTTP/1.1 404 Not Found')
                print('Content-type: application/json')
                print('')
                print('url: ' + url)
                exit(0)
            crl.close()
            body = buffer.getvalue()
            cksum = body.decode('utf-8')

            print('<tr>')
            print('<td>')

            link = appUrl + '/index.html?country=' + \
                str(f['properties']['country']).lower().replace(' ', '_') + '#map=18/' + \
                str(f['geometry']['coordinates'][0]) + '/' + \
                str(f['geometry']['coordinates'][1]) + '/0/60/0'
            print('<a href="' + link + '">' +
                  f['properties']['country'] + ' - ' + f['properties']['id'] + '</a><br/>')
            print('</td>')
            print('<td>' + cksum + '</td>')
            print('<td>')
            print('<a href="/osm/' + country + '/' + myId + '.osm">download</a>')
            print('</td>')
            print('<td>')
            print('<a href="/geojson/data/' +
                  country + '/' + myId + '.geojson">geojson</a>')
            print('</td>')
            print('<td>')
            print('<a href="/mbtiles/status/' + country +
                  '/' + myId + '">' + statusText + '</a>')
            print('</td>')
            print('<td>')
            print('<button onclick="fetch(\'/mbtiles/trigger/' +
                  country + '/' + myId + '\')">trigger</button>')
            print('</td>')
            print('<td>')
            if status == "ready":
                print('<b style="color:' + color + '";><a href="/mbtiles/data/' + country + '/' + myId + '">download</a></br>')
            print('</td>')

            print('</tr>')

        print('</table></body></html>')
    else:
        print('Content-type: application/json')
        print('')
        print(json.dumps(pins))
        # file = open(pinsCache, "r+")
        # print(file.read())
    exit(0)
elif (action == 'data'):
    print('Content-type: application/json')
    print('')
    print(json.dumps(myPlaces))
    exit(0)
elif (action == 'countries'):
    print('Content-type: application/json')
    print('')
    countries = []
    result = []
    for feature in myPlaces['features']:
        country = feature['properties']['country']
        if (not country in countries):
            countries.append(country)
            result.append({"country": country})
    print(json.dumps(result))
    exit(0)
else:
    print("HTTP/1.1 404 Not Found")
    print("Content-type: text/plain")
    print("")
    print("Unknown action")
    exit(0)