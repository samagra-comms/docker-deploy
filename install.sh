#!/bin/bash
set -e


# ANSI color escape sequences
green="\033[0;32m"
red="\033[0;31m"
reset="\033[0m"

# Function to check the status of a Docker service
get_status() {
    local service_name="$1"

    # Check if Docker Compose file exists
    if [ ! -f "docker-compose.yml" ]; then
        echo -e "${red}Docker Compose file 'docker-compose.yml' not found.${reset}"
        return 1
    fi

    # Check if service is running
    local status=$(docker-compose ps -q "$service_name")

    if [ -n "$status" ]; then
        echo -e "${green}Container '$service_name' is running.${reset}"
    else
        echo -e "${red}Container '$service_name' is not running.${reset}"
        exit 1
    fi
}

# Define versions
INSTALL_NODE_VER=16.14.0
INSTALL_NVM_VER=0.39.1
INSTALL_YARN_VER=1.22.17

# Ensure .bashrc exists and is writable
echo "==> Ensuring .bashrc exists and is writable"
touch ~/.bashrc

# Install Node Version Manager (NVM)
echo "==> Installing Node Version Manager (NVM). Version $INSTALL_NVM_VER"
# Remove if already installed
rm -rf ~/.nvm
# Unset exported variable
export NVM_DIR=
# Install NVM
curl -o- https://raw.githubusercontent.com/creationix/nvm/v$INSTALL_NVM_VER/install.sh | bash
# Make nvm command available to terminal
source ~/.nvm/nvm.sh

# Install Node.js
echo "==> Installing Node.js version $INSTALL_NODE_VER"
nvm install $INSTALL_NODE_VER
# Make this version the system default
echo "==> Making Node.js version $INSTALL_NODE_VER the system default"
nvm alias default $INSTALL_NODE_VER
nvm use default

# Install Yarn package manager
echo "==> Installing Yarn package manager"
rm -rf ~/.yarn
curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version $INSTALL_YARN_VER

# Add Yarn to environment path
echo "==> Adding Yarn to environment path"
export PATH="$HOME/.yarn/bin:$PATH"
yarn config set prefix ~/.yarn -g

# Print welcome message
echo ""
echo ""
echo ""
echo "****************************************************"
echo "Welcome to the installation script for UCI"
echo "****************************************************"
echo ""
echo ""
echo ""

# Export keys required for installation
echo "==> Exporting keys required for installation"
echo "Please provide the Encryption Key (If you don't have it, please contact the administrator)"
read ENCRYPTION_KEY
if [ -z "$ENCRYPTION_KEY" ]; then
  echo "ENCRYPTION_KEY is empty. Please contact the administrator."
  exit 0
fi
echo "Please provide the Netcore Whatsapp Auth Token (If you don't have it, press Enter to continue)"
read NETCORE_WHATSAPP_AUTH_TOKEN 
echo "Please provide the Netcore Whatsapp Source (If you don't have it, press Enter to continue)"
read NETCORE_WHATSAPP_SOURCE
echo "Please provide the Netcore Whatsapp URI (If you don't have it, press Enter to continue)"
read NETCORE_WHATSAPP_URI
echo ""

# Export environment variables
echo "==> Exporting environment variables"
sed -i "s|NETCORE_WHATSAPP_AUTH_TOKEN=.*|NETCORE_WHATSAPP_AUTH_TOKEN=${NETCORE_WHATSAPP_AUTH_TOKEN}|g" .env
sed -i "s|NETCORE_WHATSAPP_SOURCE=.*|NETCORE_WHATSAPP_SOURCE=${NETCORE_WHATSAPP_SOURCE}|g" .env
sed -i "s|NETCORE_WHATSAPP_URI=.*|NETCORE_WHATSAPP_URI=${NETCORE_WHATSAPP_URI}|g" .env
sed -i "s|ENCRYPTION_KEY=.*|ENCRYPTION_KEY=${ENCRYPTION_KEY}|g" .env

# Check and install Docker if not available
if [ -x "$(command -v docker)" ]; then
    echo "Docker is already installed."
    echo ""
else
    echo "Installing Docker"
    echo ""
    # Install Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    # DRY_RUN=1 sh ./get-docker.sh
fi

# Check and install Docker Compose if not available
if [ -x "$(command -v docker-compose)" ]; then
    echo "Docker Compose is already installed."
    echo ""
else
    echo "Installing docker-compose"
    echo ""
    sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Clone ODK repository
if [[ ! -e odk-aggregate ]]; then
    mkdir odk-aggregate
    cd odk-aggregate
    echo "Cloning ODK project from Git"
    git clone -b release-4.4.0 https://github.com/samagra-comms/odk.git
    cd ..
fi

# Clone UCI APIs repository
if [[ ! -e uci-apis ]]; then
    echo ""
    echo "Cloning UCI APIs project from Git"
    git clone -b release-4.7.0  https://github.com/samagra-comms/uci-apis.git
    echo ""
fi

SYSTEM_IP=`ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p'`

# Build and set up UCI Web Channel
if [[ ! -e uci-web-channel ]]; then
  git clone https://github.com/samagra-comms/uci-web-channel.git
  cp .env-uci-web-channel uci-web-channel/.env
  cd uci-web-channel
  # Replace transport socket URL in .env file
  transportSocketURL="REACT_APP_TRANSPORT_SOCKET_URL=ws://$SYSTEM_IP:3005"
  sed -i "3s|^.*$|$transportSocketURL|" .env
  yarn install
  yarn build
  cd ..
else 
  cp .env-uci-web-channel uci-web-channel/.env
  cd uci-web-channel
  # Replace transport socket URL in .env file
  transportSocketURL="REACT_APP_TRANSPORT_SOCKET_URL=ws://$SYSTEM_IP:3005"
  sed -i "3s|^.*$|$transportSocketURL|" .env
  yarn install
  yarn build
  cd ..
fi

# Build and set up UCI Admin
if [[ ! -e uci-admin ]]; then
  git clone https://github.com/samagra-comms/uci-admin
  cp .env-uci-admin uci-admin/.env
  cd uci-admin
  # Replace UCI API base URL in .env file
  uciApiBaseURL="NG_APP_url='http://$SYSTEM_IP:9999'"
  sed -i "1s|^.*$|$uciApiBaseURL|" .env
  npm i
  npm run build --configuration production
  cd ..
else 
  if [[ -e .env-uci-admin ]]; then
    cp .env-uci-admin uci-admin/.env
  fi
  cd uci-admin
  # Replace UCI API base URL in .env file
  uciApiBaseURL="NG_APP_url='http://$SYSTEM_IP:9999'"
  sed -i "1s|^.*$|$uciApiBaseURL|" .env
  # Remove existing node modules
  rm -rf node_modules
  rm -rf build
  npm i
  npm run build --configuration production
  cd ..
fi

# Running Docker Compose for FusionAuth, ElasticSearch, and Kafka
docker-compose up -d fa-search fusionauth fa-db

echo ""
echo ""
echo "Building ElasticSearch and FusionAuth containers. This may take a few minutes."
echo ""
echo ""

get_status fa-search

get_status fusionauth

get_status fa-db

docker-compose up -d cass kafka schema-registry zookeeper connect

echo ""
echo ""
echo "Setting up Kafka components. This may take a few minutes."
echo ""
echo ""

get_status cass

get_status kafka

get_status schema-registry

get_status zookeeper

get_status connect

docker-compose up -d aggregate-db wait_for_db aggregate-server

echo ""
echo ""
echo "Setting up ODK components. This may take a few minutes."
echo ""
echo ""

get_status aggregate-db

get_status wait_for_db

get_status aggregate-server

echo ""
echo ""
echo "Resolving dependencies"
echo ""
echo ""

docker-compose up -d

echo "All services are up"