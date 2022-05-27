#!/bin/sh

#  Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
# DRY_RUN=1 sh ./get-docker.sh

#Loader 
BAR='############################################################'   # this is full bar, e.g. 60 

loader(){
sleep_time=$(($1/60))
for i in $(eval echo {1..$1}); do
    echo -ne "\r${BAR:0:$i}" # print $i chars of $BAR from 0 position
    sleep $(($sleep_time))                 # wait 100ms between "frames"
done
echo ""
}

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
cp .env-uci-web-channel uci-web-channel/.env
cd uci-web-channel
uciWebChannelBaseURL=${GITPOD_WORKSPACE_URL:-default_value}
uciWebChannelBaseURL="REACT_APP_TRANSPORT_SOCKET_URL=wss://3005-${uciWebChannelBaseURL:8}"
sed -i "3s|^.*$|$uciWebChannelBaseURL|" .env
yarn install
yarn build
cd ..


# UCI Admin
git clone https://github.com/samagra-comms/uci-admin
cp .env-uci-admin uci-admin/.env
cd uci-admin
uciAdminBaseURL=${GITPOD_WORKSPACE_URL:-default_value}
uciAdminBaseURL="NG_APP_url='https://9999-${uciAdminBaseURL:8}'"
sed -i "3s|^.*$|$uciAdminBaseURL|" .env
npm install -g @angular/cli
npm i
ng build --prod
cd ..

docker-compose up -d fa-search fusionauth fa-db
# Sleep for 60s
loader 60
docker-compose up -d cass kafka schema-registry zookeeper connect akhq
# Sleep for 240s
loader 60
loader 60
docker-compose up -d aggregate-db wait_for_db aggregate-server
# Sleep for 60s
loader 60

docker-compose up -d uci-api-service uci-api-db uci-api-db-gql uci-api-scheduler-db
# Sleep for 60s
loader 60
docker-compose up -d uci-transport-socket uci-pwa uci-admin cache redis formsdb graphql-formsdb
# Sleep for 240s
loader 60
loader 60
loader 60
loader 60
docker-compose up -d inbound orchestrator transformer outbound broadcast-transformer cdac
# Sleep for 240s
loader 60
loader 60
loader 60
loader 60
docker restart transformer
# Sleep for 120s
loader 60
loader 60
echo "All Services are up"