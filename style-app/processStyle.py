#!/usr/bin/python3
import json
import os

indoorLayers=[]
shapeLayers=[]

####################
# indoor - symbols #
####################
with open('indoor/symbol.json') as symbol_file:
    symbolStyle = symbol_file.read()

for symbol in [
    {"id": "poi-indoor-room",             "image": "",                  "filter": [ "all", [ "==", [ "get", "indoor" ], "room" ]]},
    {"id": "poi-indoor-shop",             "image": "shop_64",           "filter": [ "any", [ "has", "shop" ]]},
    {"id": "poi-indoor-fast-food",        "image": "fast_food_64",      "filter": [ "all", [ "==", ["get", "amenity"], "fast_food" ]]},
    {"id": "poi-indoor-toilets",          "image": "toilet_64",         "filter": [ "all", [ "==", ["get", "amenity"], "toilets" ]]},
    {"id": "poi-indoor-shop-coffee",      "image": "cafe_64",           "filter": [ "all", [ "==", ["get", "amenity"], "cafe" ]]},
    {"id": "poi-indoor-shop-cosmetics",   "image": "perfumery_64",      "filter": [ "any", [ "==", ["get", "shop"], "cosmetics" ]]},
    {"id": "poi-indoor-shop-clothes",     "image": "clothing_store_64", "filter": [ "any", [ "==", ["get", "shop"], "clothes" ]]},
    {"id": "poi-indoor-shop-electronics", "image": "electronics_64",    "filter": [ "any", [ "==", ["get", "shop"], "electronics" ]]},
    {"id": "poi-indoor-shop-jewelry",     "image": "jewelry_64",        "filter": [ "any", [ "==", ["get", "shop"], "jewelry" ]]},
    {"id": "poi-indoor-shop-bakery",      "image": "bakery_64",         "filter": [ "any", [ "==", ["get", "shop"], "bakery" ]]},
    {"id": "poi-indoor-shop-dim",         "image": "dim_64",            "filter": [ "any", [ "==", ["get", "name"], "DIM" ]]},
    {"id": "poi-indoor-shop-fnac",        "image": "fnac_64",           "filter": [ "any", [ "==", ["get", "name"], "Fnac" ]]}
]:
    symbolStyleOut = symbolStyle.replace(
        '__id__', json.dumps(symbol['id'])).replace(
        '__image__', json.dumps(symbol['image'])).replace(
        '__filter__', json.dumps(symbol['filter']))
    indoorLayers.append(json.loads(symbolStyleOut))

##################
# indoor - rooms #
##################
with open('indoor/room.json') as room_file:
    roomStyle = room_file.read()

for room in [
    {"id": "indoor-room-extrusion",   "color": "#fddaa0", "height": 3, "filter": [ "all", [ "==", [ "get", "indoor" ], "room" ]]},
    {"id": "indoor-area-extrusion",   "color": "#9559f8", "height": 0, "filter": [ "all", [ "==", [ "get", "indoor" ], "area" ]]},
    {"id": "indoor-indoor-extrusion", "color": "#ddb7b0", "height": 0, "filter": [ "all", [ "has", "indoor" ]]}
]:
    roomStyleOut = roomStyle.replace(
    '__id__', json.dumps(room['id'])).replace(
    '__color__', json.dumps(room['color'])).replace(
    '__filter__', json.dumps(room['filter'])).replace(
    '__height__', json.dumps(room['height']))
    indoorLayers.append(json.loads(roomStyleOut))

####################
# indoor - highway #
####################
with open('indoor/line.json') as line_file:
    lineStyle = line_file.read()

for line in [
    {"id": "indoor-highway-line",      "color": "#ebbc00", "width": 5, "filter": [ "all", [ "has", "highway" ]]},
    {"id": "indoor-footway-line",      "color": "#ff0000", "width": 5, "filter": [ "all", [ "has", "highway" ], [ "==", [ "get", "highway" ], "footway" ]]}
]:
    lineStyleOut = lineStyle.replace(
        '__id__', json.dumps(line['id'])).replace(
        '__color__', json.dumps(line['color'])).replace(
        '__filter__', json.dumps(line['filter'])).replace(
        '__width__', json.dumps(line['width']))
    indoorLayers.append(json.loads(lineStyleOut))

with open('indoor/indoorLayers.json', 'w') as outfile:
    json.dump(indoorLayers, outfile)

#####################
# shape - extrusion #
#####################

with open('shape/extrusion.json') as extrusion_file:
    # extrusionStyle = json.load(extrusion_file)
    extrusionStyle = extrusion_file.read()

for extrusion in [
    { "id": "shape-area-extrusion-indoor-00",
      "color": "#dad0c8",
      "colorHover": "#ffaf99",
      "colorClic": "#fdff00",
      "filter": ["all",["has","indoor"],["has","level"],["==",["index-of",";",["get","level"]],-1],[">=",["to-number",["get","level"]],0],["==", ["%", ["to-number",["get","level"]], 3], 0]],
      "extrusionBase": ["*",int(os.environ['DEFAULT_LEVEL_HEIGHT']),["to-number",["get","level"]]],
      "extrusionHeight": ["*",int(os.environ['DEFAULT_LEVEL_HEIGHT']),["to-number",["get","level"]]]
    },
    { "id": "shape-area-extrusion-indoor-01",
      "color": "#6a615b",
      "colorHover": "#ffaf99",
      "colorClic": "#fdff70",
      "filter": ["all",["has","indoor"],["has","level"],["==",["index-of",";",["get","level"]],-1],[">=",["to-number",["get","level"]],0],["==", ["%", ["to-number",["get","level"]], 3], 1]],
      "extrusionBase": ["*",int(os.environ['DEFAULT_LEVEL_HEIGHT']),["to-number",["get","level"]]],
      "extrusionHeight": ["*",int(os.environ['DEFAULT_LEVEL_HEIGHT']),["to-number",["get","level"]]]
    },
    { "id": "shape-area-extrusion-indoor-02",
      "color": "#39312b",
      "colorHover": "#ffaf99",
      "colorClic": "#fdfff0",
      "filter": ["all",["has","indoor"],["has","level"],["==",["index-of",";",["get","level"]],-1],[">=",["to-number",["get","level"]],0],["==", ["%", ["to-number",["get","level"]], 3], 2]],
      "extrusionBase": ["*",int(os.environ['DEFAULT_LEVEL_HEIGHT']),["to-number",["get","level"]]],
      "extrusionHeight": ["*",int(os.environ['DEFAULT_LEVEL_HEIGHT']),["to-number",["get","level"]]]
    }
]:
    extrusionStyleOut = extrusionStyle.replace(
        '__id__', json.dumps(extrusion['id'])).replace(
        '__color__', json.dumps(extrusion['color'])).replace(
        '__color_hover__', json.dumps(extrusion['colorHover'])).replace(
        '__color_clic__', json.dumps(extrusion['colorClic'])).replace(
        '__filter__', json.dumps(extrusion['filter'])).replace(
        '__extrusionBase__', json.dumps(extrusion['extrusionBase'])).replace(
        '__extrusionHeight__', json.dumps(extrusion['extrusionHeight']))
    print(extrusionStyleOut)
    shapeLayers.append(json.loads(extrusionStyleOut))

with open('shape/shapeLayers.json', 'w') as outfile:
    json.dump(shapeLayers, outfile)

#############
# Merge all #
#############

with open('building/buildingLayers.json') as json_file:
    # print(json_file.read())
    buildingLayers = json.load(json_file)

with open('openindoorStyle.json') as json_file:
    myStyle = json.load(json_file)

myStyle['layers'].extend(indoorLayers)
myStyle['layers'].extend(shapeLayers)
myStyle['layers'].extend(buildingLayers)

if "BUILDING_GEOJSON" in os.environ:
    myStyle['sources']['building']['type'] = 'geojson'
    myStyle['sources']['building']['data'] = os.environ['BUILDING_GEOJSON']
    myStyle['sources']['building'].pop('url', None)
    myStyle['sources']['building'].pop('minzoom', None)
    myStyle['sources']['building'].pop('maxzoom', None)
    # for layer in myStyle['layers']:
    #     if layer['source-layer'] and layer['source'] == 'building':
    #        layer.pop('source-layer', None) 
if "SHAPE_GEOJSON" in os.environ:
    myStyle['sources']['shape']['type'] = 'geojson'
    myStyle['sources']['shape']['data'] = os.environ['SHAPE_GEOJSON']
    myStyle['sources']['shape'].pop('url', None)
    myStyle['sources']['shape'].pop('minzoom', None)
    myStyle['sources']['shape'].pop('maxzoom', None)
    # for layer in myStyle['layers']:
    #     if layer['source-layer'] and layer['source'] == 'shape':
    #        layer.pop('source-layer', None) 
if "INDOOR_GEOJSON" in os.environ:
    myStyle['sources']['indoor']['type'] = 'geojson'
    myStyle['sources']['indoor']['data'] = os.environ['INDOOR_GEOJSON']
    myStyle['sources']['indoor'].pop('url', None)
    myStyle['sources']['indoor'].pop('minzoom', None)
    myStyle['sources']['indoor'].pop('maxzoom', None)
    # for layer in myStyle['layers']:
    #     if layer['source-layer'] and layer['source'] == 'indoor':
    #        layer.pop('source-layer', None) 

with open('openindoorStyle.json', 'w') as outfile:
    json.dump(myStyle, outfile)