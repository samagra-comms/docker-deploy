#!/bin/bash
set -e

BAR='############################################################'   # this is full bar, e.g. 60 chars

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
    `git clone -b v2  https://github.com/samagra-comms/uci-apis.git`
    echo ""
fi

SYSTEM_IP=`ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p'`

if [[ ! -e uci-web-channel ]]; then
  # UCI Web Channel
  git clone https://github.com/samagra-comms/uci-web-channel.git
  cp .env-uci-web-channel uci-web-channel/.env
  cd uci-web-channel
  # Replace transport socker url in env
  transportSocketURL="REACT_APP_TRANSPORT_SOCKET_URL=ws://$SYSTEM_IP:3005"
  sed -i "3s|^.*$|$transportSocketURL|" .env
  cat .env
  yarn install
  yarn build
  cd ..
fi

if [[ ! -e uci-admin ]]; then
  # UCI Admin
  git clone -b nlp https://github.com/samagra-comms/uci-admin
  # Replace uci api base url in env
  uciApiBaseURL="NG_APP_url='http://$SYSTEM_IP:9999'"
  sed -i "1s|^.*$|$uciApiBaseURL|" .env
fi

docker-compose up -d

echo "All Services are up!"