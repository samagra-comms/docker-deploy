#!/bin/bash
set -e

BAR='############################################################'   # this is full bar, e.g. 60 chars

get_status(){
CONTAINER=$1

if [ "x${CONTAINER}" == "x" ]; then
  echo "$1 Container Status: UNKNOWN" # "UNKNOWN - Container ID or Friendly Name Required"
  echo ""
  return 3
fi

if [ "x$(which docker)" == "x" ]; then
  echo "$1 Container Status: UNKNOWN" # "UNKNOWN - Missing docker binary"
  echo ""
  return 3
fi

docker info > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "$1 Container Status: UNKNOWN" # "UNKNOWN - Unable to talk to the docker daemon"
  echo ""
  return 3
fi

RUNNING=$(docker inspect --format="{{.State.Running}}" $CONTAINER 2> /dev/null)

if [ $? -eq 1 ]; then
  echo "$1 Container Status: UNKNOWN" # "UNKNOWN - $CONTAINER does not exist."
  echo ""
  return 3
fi

if [ "$RUNNING" == "false" ]; then
  echo "$1 Container Status: CRITICAL" # "CRITICAL - $CONTAINER is not running."
  echo ""
  return 2
fi

RESTARTING=$(docker inspect --format="{{.State.Restarting}}" $CONTAINER)

if [ "$RESTARTING" == "true" ]; then
  echo "$1 Container Status: RUNNING" # "WARNING - $CONTAINER state is restarting."
  echo ""
  return 1
fi

STARTED=$(docker inspect --format="{{.State.StartedAt}}" $CONTAINER)
NETWORK=$(docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" $CONTAINER)

echo "$1 Container Status: RUNNING" # OK - $CONTAINER is running. IP: $NETWORK, StartedAt: $STARTED"
echo ""
return 0
}

loader(){
sleep_time=$(($1/60))
for i in $(eval echo {1..$1}); do
    echo -ne "\r${BAR:0:$i}" # print $i chars of $BAR from 0 position
    sleep $(($sleep_time))                 # wait 100ms between "frames"
done
echo ""
}

# Define versions
INSTALL_NODE_VER=16.14.0
INSTALL_NVM_VER=0.39.1
INSTALL_YARN_VER=1.22.17

echo "==> Ensuring .bashrc exists and is writable"
touch ~/.bashrc

echo "==> Installing node version manager (NVM). Version $INSTALL_NVM_VER"
# Removed if already installed
rm -rf ~/.nvm
# Unset exported variable
export NVM_DIR=

# Install nvm 
curl -o- https://raw.githubusercontent.com/creationix/nvm/v$INSTALL_NVM_VER/install.sh | bash
# Make nvm command available to terminal
source ~/.nvm/nvm.sh

echo "==> Installing node js version $INSTALL_NODE_VER"
nvm install $INSTALL_NODE_VER

echo "==> Make this version system default"
nvm alias default $INSTALL_NODE_VER
nvm use default

#echo -e "==> Update npm to latest version, if this stuck then terminate (CTRL+C) the execution"
#npm install -g npm

echo "==> Installing Yarn package manager"
rm -rf ~/.yarn
curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version $INSTALL_YARN_VER

echo "==> Adding Yarn to environment path"
# Yarn configurations
export PATH="$HOME/.yarn/bin:$PATH"
yarn config set prefix ~/.yarn -g

echo "==> Checking for versions"
nvm --version
node --version
npm --version
yarn --version

echo "Welcome to the installation script for UCI"
echo ""
echo "Let's first start by exporting keys required for installation"
echo ""
echo "Please provide Encryption Key (If you don't have it please contact to administrator)"
read ENCRYPTION_KEY
if [ -z "$ENCRYPTION_KEY" ]; then
  echo "ENCRYPTION_KEY is empty please contact with administrator"
  exit 0
fi
echo "Please provide the Netcore Whatsapp Auth Token (If you don't have it press enter to continue)"
read NETCORE_WHATSAPP_AUTH_TOKEN 
echo "Please provide Netcore Whatsapp Source (If you don't have it press enter to continue)"
read NETCORE_WHATSAPP_SOURCE
echo "Please provide Netcore Whatsapp URI (If you don't have it press enter to continue)"
read NETCORE_WHATSAPP_URI
echo ""
# export env variables
sed -i "s|NETCORE_WHATSAPP_AUTH_TOKEN=.*|NETCORE_WHATSAPP_AUTH_TOKEN=${NETCORE_WHATSAPP_AUTH_TOKEN}|g" .env
sed -i "s|NETCORE_WHATSAPP_SOURCE=.*|NETCORE_WHATSAPP_SOURCE=${NETCORE_WHATSAPP_SOURCE}|g" .env
sed -i "s|NETCORE_WHATSAPP_URI=.*|NETCORE_WHATSAPP_URI=${NETCORE_WHATSAPP_URI}|g" .env
sed -i "s|ENCRYPTION_KEY=.*|ENCRYPTION_KEY=${ENCRYPTION_KEY}|g" .env

if [ -x "$(command -v docker)" ]; then
    echo "Docker already available"
    echo ""
else
    echo "Installing Docker"
    echo ""
    #  Install Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    # DRY_RUN=1 sh ./get-docker.sh
fi
if [ -x "$(command -v docker)" ]; then
    echo "Docker Compose already available"
    echo ""
else
    echo "Installing docker-compose"
    echo ""
    sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Clone repo for ODK
if [[ ! -e odk-aggregate ]]; then
    mkdir odk-aggregate
    cd odk-aggregate
    # echo "Provide release branch name for ODK"
    # read ODK_BRANCH_NAME
    echo "Cloning project from git odk"
    `git clone -b release-4.4.0 https://github.com/samagra-comms/odk.git`
    cd ..
fi

if [[ ! -e  uci-apis ]]; then
    echo ""
    # echo "Provide release branch name for UCI APIs"
    # read UCI_BRANCH_NAME
    echo "Cloning project from git uci-apis"
    `git clone -b release-4.7.0  https://github.com/samagra-comms/uci-apis.git`
    echo ""
fi


if [[ ! -e uci-web-channel ]]; then
  # UCI Web Channel
  git clone https://github.com/samagra-comms/uci-web-channel.git
  cp .env-uci-web-channel uci-web-channel/.env
  cd uci-web-channel
  # Replace transport socker url in env
  uciWebChannelBaseURL=${GITPOD_WORKSPACE_URL:-default_value}
  uciWebChannelBaseURL="REACT_APP_TRANSPORT_SOCKET_URL=wss://3005-${uciWebChannelBaseURL:8}"
  sed -i "3s|^.*$|$uciWebChannelBaseURL|" .env
  yarn install
  yarn build
  cd ..
else 
  cp .env-uci-web-channel uci-web-channel/.env
  cd uci-web-channel
  # Replace transport socker url in env
  uciWebChannelBaseURL=${GITPOD_WORKSPACE_URL:-default_value}
  uciWebChannelBaseURL="REACT_APP_TRANSPORT_SOCKET_URL=wss://3005-${uciWebChannelBaseURL:8}"
  sed -i "3s|^.*$|$uciWebChannelBaseURL|" .env
  yarn install
  yarn build
  cd ..
fi

if [[ ! -e uci-admin ]]; then
  # UCI Admin
  git clone https://github.com/samagra-comms/uci-admin
  cp .env-uci-admin uci-admin/.env
  cd uci-admin
  # Replace uci api url in env
  uciApiBaseURL=${GITPOD_WORKSPACE_URL:-default_value}
  uciApiBaseURL="NG_APP_url='http://9999:${uciApiBaseURL:8}'"
  sed -i "1s|^.*$|$uciApiBaseURL|" .env
  npm install -g @angular/cli
  npm i
  ng build --prod
  cd ..
else 
  if [[ -e .env-uci-admin ]]; then
    cp .env-uci-admin uci-admin/.env
  fi
  cd uci-admin
  # Replace uci api url in env
  uciApiBaseURL=${GITPOD_WORKSPACE_URL:-default_value}
  uciApiBaseURL="NG_APP_url='http://9999:${uciApiBaseURL:8}'"
  sed -i "1s|^.*$|$uciApiBaseURL|" .env
  # Remove existing node modules
  rm -rf node_modules
  npm install -g @angular/cli
  npm i
  ng build --prod
  cd ..
fi

# running docker-compose
docker-compose up -d fa-search fusionauth fa-db
echo "Building elastic search and fusionauth container, may take few mins"
loader 60

get_status fa-search
if [[ $? != 0 ]]
then
    echo ""
    echo "Error in running container fa-search"
    exit 0
fi

get_status fusionauth
if [[ $? != 0 ]]
then
    echo ""
    echo "Error in running container fusionauth"
    exit 0
fi

get_status fa-db
if [[ $? != 0 ]]
then
    echo ""
    echo "Error in running container fa-db"
    exit 0
fi

docker-compose up -d cass kafka schema-registry zookeeper connect akhq
echo "Setting up kafka components, may take few mins"
loader 120

get_status cass
if [[ $? != 0 ]]
then
    echo ""
    echo "Error in running container cass"
    exit 0
fi

get_status kafka
if [[ $? != 0 ]]
then
    echo ""
    echo "Error in running container kafka"
    exit 0
fi

# get_status schema-registry
# if [[ $? != 0 ]]
# then
#     echo ""
#     echo "Error in running container schema-registry"
#     exit 0
# fi

# get_status zookeeper
# if [[ $? != 0 ]]
# then
#     echo ""
#     echo "Error in running container zookeeper"
#     exit 0
# fi

# get_status connect
# if [[ $? != 0 ]]
# then
#     echo ""
#     echo "Error in running container connect"
#     exit 0
# fi

# get_status akhq
# if [[ $? != 0 ]]
# then
#     echo ""
#     echo "Error in running container akhq"
#     exit 0
# fi

docker-compose up -d aggregate-db wait_for_db aggregate-server
echo "Setting up ODK components, may take few mins"
loader 60

get_status aggregate-db
if [[ $? != 0 ]]
then
    echo ""
    echo "Error in running container aggregate-db"
    exit 0
fi

# get_status wait_for_db
# if [[ $? != 0 ]]
# then
#     echo ""
#     echo "Error in running container wait_for_db"
#     exit 0
# fi

get_status aggregate-server
if [[ $? != 0 ]]
then
    echo ""
    echo "Error in running container aggregate-server"
    exit 0
fi

echo "Resolving dependencies"
echo ""

docker-compose up -d

echo "All Services are up"