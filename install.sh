#!/bin/sh

#  Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
# DRY_RUN=1 sh ./get-docker.sh

# Clone repo for ODK
if [[ ! -e odk-aggregate ]]; then
    mkdir odk-aggregate
fi
cd odk-aggregate
git clone -b release-4.4.0  https://github.com/samagra-comms/odk.git
cd ..
git clone -b release-4.7.0 https://github.com/samagra-comms/uci-apis.git

# UCI Web Channel
git clone https://github.com/samagra-comms/uci-web-channel.git
cd uci-web-channel
# uciWebChannelBaseURL="export const socket = io('ws://localhost:3005/');"
# sed -i "7s|^.*$|$uciWebChannelBaseURL|" src/websocket.ts
yarn install
yarn build
cd ..


# UCI Admin
git clone https://github.com/samagra-comms/uci-admin
cd uci-admin
uciAdminBaseURL="url: 'http://localhost:9999',"
sed -i "3s|^.*$|$uciAdminBaseURL|" src/environments/environment.prod.ts
npm install -g @angular/cli
npm i
ng build --prod
cd ..

docker-compose up -d fa-search fusionauth fa-db
sleep 60s
docker-compose up -d cass kafka schema-registry zookeeper connect akhq
sleep 120s
docker-compose up -d aggregate-db wait_for_db aggregate-server
sleep 60s

docker-compose up -d