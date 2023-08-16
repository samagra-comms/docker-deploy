#!/bin/bash
set -e

# Function to check the status of a service in Docker Compose
get_status() {
    local service_name="$1"

    # ANSI color escape sequences
    local green="\033[0;32m"
    local red="\033[0;31m"
    local reset="\033[0m"

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

echo "==> Ensuring .bashrc exists and is writable"
touch ~/.bashrc

echo "==> Installing Node Version Manager (NVM) version $INSTALL_NVM_VER"
# Remove NVM if already installed
rm -rf ~/.nvm
# Unset exported variable
export NVM_DIR=

# Install NVM
curl -o- https://raw.githubusercontent.com/creationix/nvm/v$INSTALL_NVM_VER/install.sh | bash
# Make NVM command available in the terminal
source ~/.nvm/nvm.sh

echo "==> Installing Node.js version $INSTALL_NODE_VER"
nvm install $INSTALL_NODE_VER

echo "==> Setting this version as the system default"
nvm alias default $INSTALL_NODE_VER
nvm use default

echo "==> Installing Yarn package manager version $INSTALL_YARN_VER"
rm -rf ~/.yarn
curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version $INSTALL_YARN_VER

echo "==> Adding Yarn to the environment path"
# Yarn configurations
export PATH="$HOME/.yarn/bin:$PATH"
yarn config set prefix ~/.yarn -g

echo "==> Checking versions"
nvm --version
node --version
npm --version
yarn --version

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

echo "Let's first start by exporting keys required for installation"
echo ""
echo "Please provide the Encryption Key (If you don't have it, please contact the administrator)"
read -r ENCRYPTION_KEY
if [ -z "$ENCRYPTION_KEY" ]; then
  echo "ENCRYPTION_KEY is empty. Please contact the administrator."
  exit 0
fi
echo "Please provide the Netcore WhatsApp Auth Token (If you don't have it, press Enter to continue)"
read -r NETCORE_WHATSAPP_AUTH_TOKEN
echo "Please provide the Netcore WhatsApp Source (If you don't have it, press Enter to continue)"
read -r NETCORE_WHATSAPP_SOURCE
echo "Please provide the Netcore WhatsApp URI (If you don't have it, press Enter to continue)"
read -r NETCORE_WHATSAPP_URI
echo ""
# Export environment variables
sed -i "s|NETCORE_WHATSAPP_AUTH_TOKEN=.*|NETCORE_WHATSAPP_AUTH_TOKEN=${NETCORE_WHATSAPP_AUTH_TOKEN}|g" .env
sed -i "s|NETCORE_WHATSAPP_SOURCE=.*|NETCORE_WHATSAPP_SOURCE=${NETCORE_WHATSAPP_SOURCE}|g" .env
sed -i "s|NETCORE_WHATSAPP_URI=.*|NETCORE_WHATSAPP_URI=${NETCORE_WHATSAPP_URI}|g" .env
sed -i "s|ENCRYPTION_KEY=.*|ENCRYPTION_KEY=${ENCRYPTION_KEY}|g" .env

if [ -x "$(command -v docker)" ]; then
    echo "Docker is already available"
    echo ""
else
    echo "Installing Docker"
    echo ""
    # Install Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
fi

if [ -x "$(command -v docker)" ]; then
    echo "Docker Compose is already available"
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
    echo "Cloning project from git odk"
    git clone -b release-4.4.0 https://github.com/samagra-comms/odk.git
    cd ..
fi

# Clone repo for web-channel
if [[ ! -e uci-web-channel ]]; then
  # UCI Web Channel
  git clone https://github.com/samagra-comms/uci-web-channel.git
  cp .env-uci-web-channel uci-web-channel/.env
  cd uci-web-channel
  # Replace transport socket URL in .env file
  uciWebChannelBaseURL=${GITPOD_WORKSPACE_URL:-default_value}
  uciWebChannelBaseURL="REACT_APP_TRANSPORT_SOCKET_URL=wss://3005-${uciWebChannelBaseURL:8}"
  sed -i "3s|^.*$|$uciWebChannelBaseURL|" .env
  yarn install
  yarn build
  cd ..
else
  cp .env-uci-web-channel uci-web-channel/.env
  cd uci-web-channel
  # Replace transport socket URL in .env file
  uciWebChannelBaseURL=${GITPOD_WORKSPACE_URL:-default_value}
  uciWebChannelBaseURL="REACT_APP_TRANSPORT_SOCKET_URL=wss://3005-${uciWebChannelBaseURL:8}"
  sed -i "3s|^.*$|$uciWebChannelBaseURL|" .env
  yarn install
  yarn build
  cd ..
fi

# Clone repo for uci-admin
if [[ ! -e uci-admin ]]; then
  # UCI Admin
  git clone https://github.com/samagra-comms/uci-admin
  cp .env-uci-admin uci-admin/.env
  cd uci-admin
  # Replace UCI API URL in .env file
  uciApiBaseURL=${GITPOD_WORKSPACE_URL:-default_value}
  uciApiBaseURL="NG_APP_url='http://9999:${uciApiBaseURL:8}'"
  sed -i "1s|^.*$|$uciApiBaseURL|" .env
  npm i
  npm run build --configuration production
  cd ..
else
  if [[ -e .env-uci-admin ]]; then
    cp .env-uci-admin uci-admin/.env
  fi
  cd uci-admin
  # Replace UCI API URL in .env file
  uciApiBaseURL=${GITPOD_WORKSPACE_URL:-default_value}
  uciApiBaseURL="NG_APP_url='http://9999:${uciApiBaseURL:8}'"
  sed -i "1s|^.*$|$uciApiBaseURL|" .env
  # Remove existing node modules
  rm -rf node_modules
  rm -rf build
  npm i
  npm run build --configuration production
  cd ..
fi

# Running Docker-Compose

# FusionAuth components
echo ""
echo ""
echo "Building elastic search and fusionauth container, may take a few minutes"
echo ""
echo ""

docker-compose up -d fa-search fusionauth fa-db

get_status fa-search

get_status fusionauth

get_status fa-db

# Kafka Components
echo ""
echo ""
echo "Setting up Kafka components, may take a few minutes"
echo ""
echo ""

docker-compose up -d cass kafka schema-registry zookeeper connect 

get_status cass

get_status kafka

get_status schema-registry

get_status zookeeper

get_status connect

# ODK Components
echo ""
echo ""
echo "Setting up ODK components, may take a few minutes"
echo ""
echo ""

docker-compose up -d aggregate-db wait_for_db aggregate-server

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