#!/bin/sh
ssh kimsufi '
set -x
cd ~/Project/openindoor4
docker-compose stop
git pull
rm -rf .env
ln -s ./environment/map.openindoor.io.env ./.env
docker-compose up -d --build
'
