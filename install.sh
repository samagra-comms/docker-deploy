#!/bin/sh

#  Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
# DRY_RUN=1 sh ./get-docker.sh

# Clone repo for ODK
mkdir odk-aggregate && cd odk-aggregate
git clone -b release-4.4.0  https://github.com/samagra-comms/odk.git
cd ..
git clone -b release-4.7.0 https://github.com/samagra-comms/uci-apis.git

docker-compose up -d