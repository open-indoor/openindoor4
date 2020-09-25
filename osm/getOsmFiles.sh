#!/bin/bash

osmUpdate () { 
  BBOXES="/data/bboxes.lst"
  BBOXES_JSON="/data/bboxes.json"

  if [ -f "$BBOXES" ]; then
    bboxes=$(cat $BBOXES)
  else
    mkdir -p /data
    read -r -d '' bboxes <<'EOF'
ArgentinaBuenosAiresFineArtsNationalMuseum:"Argentina":"Buenos Aires":"Fine Arts National Museum":-58.39337:-34.58422:-58.39207:-34.58333:0
ArgentinaBuenosAiresNationalGeographicInstitute:"Argentina":"Buenos Aires":"National Geographic Institute":-58.44010:-34.57372:-58.43915:-34.57028:0
ArgentinaBuenosEduardoSivoriPlasticArtsMuseum:"Argentina":"Buenos Aires":"Eduardo Sívori Plastic Arts Museum":-58.41830:-34.57062:-58.41744:-34.56729:0
ArgentinaBuenosAltoAvellanedaShoppingMall:"Argentina":"Buenos Aires / Avellaneda":"Alto Avellaneda Shopping Mall":-58.36999:-34.67910:-58.36662:-34.67365:0
ArgentinaCordobaMathAstronomyPhysicsAndComputerScienceFaculty:"Argentina":"Córdoba":"Math, Astronomy, Physics and Computer Science Faculty":-64.19417:-31.43984:-64.19292:-31.43645:0
ArgentinaMisionesPosadasMisionesNationalUniversity:"Argentina":"Misiones / Posadas":"Misiones National University":-55.88734:-27.43746:-55.88610:-27.43375:0
ArgentinaSantaFeFunesRosarioInternationalAirport:"Argentina":"Santa Fe / Funes":"Rosario International Airport":-60.78098:-32.91820:-60.77986:-32.91568:0
ArgentinaSantaFeFunesFishertonPlazaChic:"Argentina":"Santa Fe / Funes":"Fisherton Plaza Chic":-60.77880:-32.92051:-60.77712:-32.91638:0
AustriaViennaSudtirolerPlatz:"Austria":"Vienna":"Südtiroler Platz":16.37493:48.18283:16.37822:48.18602:0
ColombiaDistritoCapitalBogotaCatedralPrimadaDeBogota:"Colombia":"Distrito Capital / Bogotá":"Catedral Primada de Bogotá":-74.07583:4.59576:-74.07442:4.59926:0
CostaRicaSanJoseStarbucks:"Costa Rica":"San José":"Starbucks":-84.10992:9.93529:-84.10939:9.93968:0
EcuadorPichinchaQuitoQuicentroShopping:"Ecuador":"Pichincha Quito":"Quicentro Shopping":-78.48073:-0.17816:-78.47782:-0.17442:0
FranceIndreEtLoireChenonceauxChateauDeChenonceau:"France":"Indre-et-Loire / Chenonceaux":"Château de Chenonceau":1.07002:47.32338:1.07080:47.32583:0
FranceLoirEtCherTalcyChateauDeTalcy:"France":"Loir-et-Cher / Talcy":"Château de Talcy":1.44418:47.76798:1.44499:47.77097:0
FranceNordVilleneuveDAscqBatimentsDuLIFLIRCICA:"France":"Nord / Villeneuve d\'Ascq":"Bâtiments du LIFL IRCICA":3.14564:50.60357:3.14716:50.60580:0
FranceParisTGI:"France":"Paris":"TGI":2.34292:48.85359:2.34635:48.85773:0
FranceParisENSRueDUUlm:"France":"Paris":"ENS - Rue d\'Ulm":2.34374:48.83926:2.34592:48.84397:0
FranceParisParisGareDuNord:"France":"Paris":"Gare du Nord":2.35373:48.87754:2.35857:48.88620:0
FranceParisGareDeLyon:"France":"Paris":"Gare de Lyon":2.37233:48.83915:2.37697:48.84492:0
FranceParisBibliothequeFrancoisMitterrandTrainStation:"France":"Paris":"Bibliothèque François Mitterrand / train station":2.37653:48.82853:2.37875:48.82950:0
FranceParisECEParis:"France":"Paris":"ECE-Paris":2.28625:48.85066:2.28751:48.85307:0
FranceParisGareDeLEst:"France":"Paris":"Gare de l\'Est":2.244:48.7741:2.252:48.7773:1m
FrancePuyDeDomeClermontFerrandCentreJaude:"France":"Puy-de-Dôme Clermont Ferrand":"Centre Jaude":3.07970:45.77415:3.08377:45.77587:0
FranceRhoneLyonGareDeLaPartDieu:"France":"Rhone / Lyon":"Gare de la Part-Dieu":4.85936:45.75947:4.86156:45.76161:0
FranceRhoneLyonHallePaulBocuse:"France":"Rhone / Lyon":"Halle Paul Bocuse":4.85016:45.76189:4.85134:45.76384:0
FranceSeineEtMarneMaincyChateauDeVauxLeVicomte:"France":"Seine-et-Marne / Maincy":"Château de Vaux-le-Vicomte":2.71362:48.56451:2.71466:48.56722:0
FranceValDeMarneThiaisCentrecommercialBelleEpine:"France":"Val-de-Marne / Thiais":"Centre commercial Belle Épine":2.36905:48.75566:2.37395:48.75793:0
FranceYvelinesVelizyVillacoublayCentreCommercialVelizy2:"France":"Yvelines / Vélizy-Villacoublay":"Centre commercial Vélizy 2":2.21856:48.77735:2.22209:48.78526:0
EOF
    echo "$bboxes" > $BBOXES
  fi

  echo -n "[" > $BBOXES_JSON
  mkdir -p /data/osm
  while read bbox
  do
    filename=$(echo "$bbox" | cut -d':' -f1 | tr -d '"')
    update=$(echo "$bbox" | cut -d':' -f9)
    country=$(echo "$bbox" | cut -d':' -f2 | tr -d '"')
    town=$(echo "$bbox" | cut -d':' -f3 | tr -d '"')
    place=$(echo "$bbox" | cut -d':' -f4 | tr -d '"')
    lon1=$(echo "$bbox" | cut -d':' -f5)
    lat1=$(echo "$bbox" | cut -d':' -f6)
    lon2=$(echo "$bbox" | cut -d':' -f7)
    lat2=$(echo "$bbox" | cut -d':' -f8)
    if [ ! -f "/data/osm/${filename}.osm" ] || ! grep -q '<osm version=' "/data/osm/${filename}.osm" || [ "x${update}" = "x1m" ] ; then
      url="https://map.openindoor.io?bbox=""$lon1"",""$lat1"",""$lon2"",""$lat2"
      overpass="https://overpass-api.de/api/map?bbox=""$lon1"",""$lat1"",""$lon2"",""$lat2"
      echo $overpass
      rm -rf /tmp/${filename}.osm
      curl $overpass > /tmp/${filename}.osm
      if grep -q '<osm version=' "/tmp/${filename}.osm" ; then
        mv -f /tmp/${filename}.osm /data/osm/${filename}.osm
        echo "downloaded"
      fi
    else
      echo "$f already downloaded"
    fi

    if [ -f "/data/osm/${filename}.osm" ] \
    && grep -q '<osm version=' "/data/osm/${filename}.osm"; then
      echo -n "{" >> $BBOXES_JSON
        echo -n '"id":"'"${filename}"'",' >> $BBOXES_JSON
        echo -n '"update":"'${update}'",' >> $BBOXES_JSON
        echo -n '"country":"'${country}'",' >> $BBOXES_JSON
        echo -n '"town":"'${town}'",' >> $BBOXES_JSON
        echo -n '"place":"'${place}'",' >> $BBOXES_JSON
        echo -n '"bbox":[' >> $BBOXES_JSON
          echo -n "${lon1}, ${lat1}, ${lon2}, ${lat2}" >> $BBOXES_JSON
        echo -n ']' >> $BBOXES_JSON 
      echo -n "}," >> $BBOXES_JSON
    fi

  done <<< "$bboxes"
  sed -i 's/,$//' $BBOXES_JSON
  echo "]" >> $BBOXES_JSON
}

echo "osmUpdate"
osmUpdate