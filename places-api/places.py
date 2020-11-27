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


def urlExists(url):
    buffer = BytesIO()
    crl = pycurl.Curl()
    crl.setopt(crl.URL, url)
    crl.setopt(crl.WRITEDATA, buffer)
    crl.perform()
    result = not (crl.getinfo(pycurl.HTTP_CODE) >= 400)
    crl.close()
    return result

def getData(url):
    buffer = BytesIO()
    crl = pycurl.Curl()
    crl.setopt(crl.URL, url)
    crl.setopt(crl.WRITEDATA, buffer)
    crl.perform()
    code = crl.getinfo(pycurl.HTTP_CODE)
    crl.close()
    if code >= 400:
        result = None
    else:   
        result = buffer.getvalue().decode('utf-8')
    return result

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
    if gj['features'][0]['properties']['update'] != "-1":
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
# elif (action == 'wp' ):
#     print('<!-- wp:table -->')
#     # Open table
#     print('<table class="wp-block-table"><tbody><tr><td>Place</td></tr>')
#     # Country
#     print('<tr><td style="text-align:center"><b>')
#     print(Country)
#     print('</b></td></tr>')
#     # Places
#     print('<tr><td><a href="')
#     print(url)
#     print('">')
#     print(place)
#     print('</a></td></tr>')
#     # Close table
#     print('</tbody></table>')
#     print('<!-- /wp:table -->')
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
        print('<td>osm</td>')
        print('<td>checksum</td>')
        print('<td>xml</td>')
        print('<td>geojson</td>')
        print('<td>mbtiles</td>')
        for f in pins['features']:
            country = str(f['properties']['country']).lower().replace(' ', '_')
            myId = f['properties']['id']

            if country != lastCountry:
                lastCountry = country
                country_statusText = ''
                # GET MBTILES COUNTRY STATUS
                countryStatusText = '<button onclick="fetch(\'/mbtiles-country/trigger/' + country + '\')">trigger</button>'

                # url = 'http://mbtiles-country-api/mbtiles-country/status/' + country
                # statusJson = getData(url)
                # status = str(None)
                # color = "#FF0000"
                # if statusJson != None:
                #     status = json.loads(statusJson)['status']
                #     if status == "ready":
                #         color = "#00FF00"
                #         countryStatusText = '<b style="color:' + color + '";>' + status + '</b>'
                #     elif status == "in progress":
                #         color = "#FF7F00"
                #         countryStatusText = '<b style="color:' + color + '";>' + status + '</b>'

                print('<tr style="background-color:#FF0000"><td colspan="4"; style="text-align: center; vertical-align: middle;">' + country + '</td>')
                print('<td>' + countryStatusText + '</td>')
                # print('<td><a href="/mbtiles/data/' + country + '">download</a></td>')

                print('</tr>')

            # GET MBTILES STATUS
            url = 'http://mbtiles-api/mbtiles/status/' + country + '/' + myId
            statusJson = getData(url)
            status = str(None)
            color = "#FF0000"
            if statusJson != None:
                status = json.loads(statusJson)['status']
                if status == "ready":
                    color = "#00FF00"
                elif status == "in progress":
                    color = "#FF7F00"
            statusText = '<b style="color:' + color + '";>' + status + '</b>'

            # GET OSM CHECKSUM
            url = 'http://osm-api/osm/' + country + '/' + myId + '.cksum'
            cksum = str(getData(url))

            print('<tr>')
            print('<td>')

            link = appUrl + '/index.html?country=' + \
                str(f['properties']['country']).lower().replace(' ', '_') + '#map=18/' + \
                str(f['geometry']['coordinates'][0]) + '/' + \
                str(f['geometry']['coordinates'][1]) + '/0/60/0'
            print('<a href="' + link + '">' +
                  f['properties']['country'] + ' - ' + f['properties']['id'] + '</a><br/>')
            print('</td>')
            print('<td>')
            osmUrl = 'https://www.openstreetmap.org/#map=18/' + \
                str(f['geometry']['coordinates'][0]) + '/' + \
                str(f['geometry']['coordinates'][1])
            print(osmUrl)
            print('</td>')
# https://www.openstreetmap.org/#map=6/46.449/2.210
            print('<td>' + cksum + '</td>')

            ### OSM ###
            print('<td>')
            if urlExists('http://osm-api/osm/' + country + '/' + myId + '.osm'):
                print('<a href="/osm/' + country + '/' + myId + '.osm">download</a>')
            else:
                print('Not found')
            print('</td>')

            ## GEOJSON
            print('<td>')
            if urlExists('http://geojson-api/geojson/data/' + country + '/' + myId + '.geojson'):
                print('<a href="/geojson/data/' + country + '/' + myId + '.geojson">download</a>')
            else:
                print('<button onclick="fetch(\'/geojson/trigger/' + country + '/' + myId + '\')">trigger</button>')
            print('</td>')
            print('<td>')
            if status == "ready":
                print('<b style="color:' + color + '";><a href="/mbtiles/data/' + country + '/' + myId + '">download</a></br>')
            else:
                print('<button onclick="fetch(\'/mbtiles/trigger/' + country + '/' + myId + '\')">trigger</button>')
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
