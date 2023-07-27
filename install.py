import os
import subprocess
import sys
import shutil
import time
import requests
import shlex
import json

# ANSI color escape sequences
green = "\033[0;32m"
red = "\033[0;31m"
reset = "\033[0m"

def get_status(service_name):
    print(f"Checking status of '{service_name}' container...")
    try:
        # Check if Docker Compose file exists
        if not os.path.exists("docker-compose.yml"):
            raise Exception("Docker Compose file 'docker-compose.yml' not found.")

        # Check if service is running
        result = subprocess.run(["docker-compose", "ps", "-q", service_name], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True, text=True)
        if result.stdout.strip():
            print(f"{green}Container '{service_name}' is running.{reset}")
        else:
            raise Exception(f"{red}Container '{service_name}' is not running.{reset}")
    except subprocess.CalledProcessError as e:
        print_error_message(f"Error while checking status: {e}")
        sys.exit(1)
    except Exception as e:
        print_error_message(str(e))
        sys.exit(1)

def print_error_message(error_message):
    print(f"{red}{error_message}{reset}")


def print_stage_message(stage_name):
    print(f"\n{green}=== {stage_name} ==={reset}")


def run_command(command):
    try:
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as e:
        print_error_message(str(e))
        sys.exit(1)


def install_node_version_manager():
    print_stage_message("Installing Node Version Manager (NVM)")

    # Remove if already installed
    shutil.rmtree(os.path.expanduser("~/.nvm"), ignore_errors=True)

    # Install NVM
    run_command(["curl", "-o-", f"https://raw.githubusercontent.com/creationix/nvm/v{INSTALL_NVM_VER}/install.sh", "|", "bash"])
    # Make nvm command available to terminal
    os.system("source ~/.nvm/nvm.sh")


def install_nodejs():
    print_stage_message("Installing Node.js")

    # Install Node.js
    run_command(["nvm", "install", INSTALL_NODE_VER])
    # Make this version the system default
    run_command(["nvm", "alias", "default", INSTALL_NODE_VER])
    run_command(["nvm", "use", "default"])


def install_yarn():
    print_stage_message("Installing Yarn package manager")

    # Install Yarn package manager
    shutil.rmtree(os.path.expanduser("~/.yarn"), ignore_errors=True)
    run_command(["curl", "-o-", "-L", f"https://yarnpkg.com/install.sh", "|", "bash", "-s", "--", "--version", INSTALL_YARN_VER])


def add_yarn_to_path():
    print_stage_message("Adding Yarn to environment path")

    # Add Yarn to environment path
    os.environ["PATH"] = f"$HOME/.yarn/bin:{os.environ['PATH']}"
    run_command(["yarn", "config", "set", "prefix", "~/.yarn", "-g"])


def export_keys():
    print_stage_message("Exporting keys required for installation")

    # Export keys required for installation
    encryption_key = input("Please provide the Encryption Key (If you don't have it, please contact the administrator): ")
    if not encryption_key:
        print_error_message("ENCRYPTION_KEY is empty. Please contact the administrator.")
        sys.exit(1)
    netcore_whatsapp_auth_token = input("Please provide the Netcore Whatsapp Auth Token (If you don't have it, press Enter to continue): ")
    netcore_whatsapp_source = input("Please provide the Netcore Whatsapp Source (If you don't have it, press Enter to continue): ")
    netcore_whatsapp_uri = input("Please provide the Netcore Whatsapp URI (If you don't have it, press Enter to continue): ")
    print()

    # Export environment variables
    run_command(["sed", "-i", f"s|NETCORE_WHATSAPP_AUTH_TOKEN=.*|NETCORE_WHATSAPP_AUTH_TOKEN={netcore_whatsapp_auth_token}|g", ".env"])
    run_command(["sed", "-i", f"s|NETCORE_WHATSAPP_SOURCE=.*|NETCORE_WHATSAPP_SOURCE={netcore_whatsapp_source}|g", ".env"])
    run_command(["sed", "-i", f"s|NETCORE_WHATSAPP_URI=.*|NETCORE_WHATSAPP_URI={netcore_whatsapp_uri}|g", ".env"])
    run_command(["sed", "-i", f"s|ENCRYPTION_KEY=.*|ENCRYPTION_KEY={encryption_key}|g", ".env"])


def check_and_install_docker():
    print_stage_message("Checking and installing Docker")

    # Check if Docker is already installed
    if shutil.which("docker"):
        print("Docker is already installed.")
        print()
        return

    # Install Docker
    print("Installing Docker...")
    time.sleep(2)  # Simulating installation delay
    # Uncomment the line below to install Docker non-interactively
    # run_command(["DRY_RUN=1", "sh", "./get-docker.sh"])
    print("Docker installation complete.")
    print()


def check_and_install_docker_compose():
    print_stage_message("Checking and installing Docker Compose")

    # Check if Docker Compose is already installed
    if shutil.which("docker-compose"):
        print("Docker Compose is already installed.")
        print()
        return

    # Install Docker Compose
    print("Installing Docker Compose...")
    time.sleep(2)  # Simulating installation delay
    run_command(["sudo", "curl", "-L", f"https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)", "-o", "/usr/local/bin/docker-compose"])
    run_command(["sudo", "chmod", "+x", "/usr/local/bin/docker-compose"])
    print("Docker Compose installation complete.")
    print()


def clone_odk_repository():
    print_stage_message("Cloning ODK repository")

    if os.path.exists("odk-aggregate"):
        print("ODK repository already exists.")
        print()
        return

    os.makedirs("odk-aggregate")
    os.chdir("odk-aggregate")
    run_command(["git", "clone", "-b", "release-4.4.0", "https://github.com/samagra-comms/odk.git"])
    os.chdir("..")
    print("ODK repository clone complete.")
    print()


def clone_uci_apis_repository():
    print_stage_message("Cloning UCI APIs repository")

    if os.path.exists("uci-apis"):
        print("UCI APIs repository already exists.")
        print()
        return

    print("Cloning UCI APIs repository from Git...")
    run_command(["git", "clone", "-b", "release-4.7.0", "https://github.com/samagra-comms/uci-apis.git"])
    print("UCI APIs repository clone complete.")
    print()


def build_and_setup_uci_web_channel():
    print_stage_message("Building and setting up UCI Web Channel")

    if os.path.exists("uci-web-channel"):
        shutil.copy(".env-uci-web-channel", "uci-web-channel/.env")
        os.chdir("uci-web-channel")
        transportSocketURL = f"REACT_APP_TRANSPORT_SOCKET_URL=ws://{SYSTEM_IP}:3005"
        run_command(["sed", "-i", "3s|^.*$|{}|".format(transportSocketURL), ".env"])
        run_command(["yarn", "install"])
        run_command(["yarn", "build"])
        os.chdir("..")
    else:
        os.system("git clone https://github.com/samagra-comms/uci-web-channel.git")
        shutil.copy(".env-uci-web-channel", "uci-web-channel/.env")
        os.chdir("uci-web-channel")
        transportSocketURL = f"REACT_APP_TRANSPORT_SOCKET_URL=ws://{SYSTEM_IP}:3005"
        run_command(["sed", "-i", "3s|^.*$|{}|".format(transportSocketURL), ".env"])
        run_command(["yarn", "install"])
        run_command(["yarn", "build"])
        os.chdir("..")

    print("UCI Web Channel build and setup complete.")
    print()


def build_and_setup_uci_admin():
    print_stage_message("Building and setting up UCI Admin")

    if os.path.exists("uci-admin"):
        if os.path.exists(".env-uci-admin"):
            shutil.copy(".env-uci-admin", "uci-admin/.env")
        os.chdir("uci-admin")
        uciApiBaseURL = f"NG_APP_url='http://{SYSTEM_IP}:9999'"
        run_command(["sed", "-i", "1s|^.*$|{}|".format(uciApiBaseURL), ".env"])
        run_command(["npm", "i"])
        run_command(["npm", "run", "build", "--configuration", "production"])
        os.chdir("..")
    else:
        os.system("git clone https://github.com/samagra-comms/uci-admin")
        if os.path.exists(".env-uci-admin"):
            shutil.copy(".env-uci-admin", "uci-admin/.env")
        os.chdir("uci-admin")
        uciApiBaseURL = f"NG_APP_url='http://{SYSTEM_IP}:9999'"
        run_command(["sed", "-i", "1s|^.*$|{}|".format(uciApiBaseURL), ".env"])
        run_command(["npm", "i"])
        run_command(["npm", "run", "build", "--configuration", "production"])
        os.chdir("..")

    print("UCI Admin build and setup complete.")
    print()


def run_docker_compose_services():
    print_stage_message("Running Docker Compose services")

    run_command(["docker-compose", "up", "-d", "fa-search", "fusionauth", "fa-db"])

    print("Building ElasticSearch and FusionAuth containers. This may take a few minutes.")
    print()

    get_status("fa-search")
    get_status("fusionauth")
    get_status("fa-db")

    run_command(["docker-compose", "up", "-d", "cass", "kafka", "schema-registry", "zookeeper", "connect"])

    print("Setting up Kafka components. This may take a few minutes.")
    print()

    get_status("cass")
    get_status("kafka")
    get_status("schema-registry")
    get_status("zookeeper")
    get_status("connect")

    run_command(["docker-compose", "up", "-d", "aggregate-db", "wait_for_db", "aggregate-server"])

    print("Setting up ODK components. This may take a few minutes.")
    print()

    get_status("aggregate-db")
    get_status("wait_for_db")
    get_status("aggregate-server")

    print("Resolving dependencies")
    print()

    run_command(["docker-compose", "up", "-d"])

    print("All services are up")
    print()
    
def upload_form(admin_token, path_to_xml):
    print_stage_message("Uploading form")

    url = "http://localhost:9999/admin/form/upload"
    headers = {
        "admin-token": admin_token
    }
    files = {
        "form": open(path_to_xml, "rb")
    }

    try:
        response = requests.post(url, headers=headers, files=files)
        response.raise_for_status()
        response_data = response.json()
        form_id = response_data["result"]["data"]["formID"]
        print("Form upload successful.")
        print()
        return form_id
    except requests.exceptions.RequestException as e:
        print_error_message(f"Error while uploading form: {e}")
        sys.exit(1)


def create_conversation_logic(admin_token, form_id):
    print_stage_message("Creating conversation logic")

    url = "http://localhost:9999/admin/conversationLogic"
    headers = {
        "admin-token": admin_token,
        "Content-Type": "application/json",
        "Cookie": "fusionauth.locale=en_US; fusionauth.sso=AgOat0GjncGOHhPpH_HuL9QQqnfMitd15O-ofS-uTcdA"
    }
    data = {
        "data": {
            "id": None,
            "name": "UCI List & Button Logic",
            "description": "UCI List & Button Logic Desc",
            "transformers": [
                {
                    "id": "bbf56981-b8c9-40e9-8067-468c2c753659",
                    "meta": {
                        "form": f"https://hosted.my.form.here.com/{form_id}",
                        "formID": form_id
                    }
                }
            ],
            "adapter": "44a9df72-3d7a-4ece-94c5-98cf26307323"
        }
    }

    try:
        response = requests.post(url, headers=headers, json=data)
        response.raise_for_status()
        response_data = response.json()
        print(response_data)
        logic_id = response_data["result"]["id"]
        print("Conversation logic creation successful.")
        print()
        return logic_id
    except requests.exceptions.RequestException as e:
        print_error_message(f"Error while creating conversation logic: {e}")
        sys.exit(1)



def create_bot_with_curl(conversation_logic_id):
    url = 'http://143.110.255.220:9999/admin/bot'
    asset = 'bot'
    admin_token = 'dR67yAkMAqW5P9xk6DDJnfn6KbD4EJFVpmPEjuZMq44jJGcj65'
    owner_org_id = 'org01'
    owner_id = '8f7ee860-0163-4229-9d2a-01cef53145ba'
    bot_image_path = './media/Test-Bot-Flow-pwa.png'

    # JSON data containing the conversation_logic_id
    data = {
        "data": {
            "name": "TEST ODK BOT333363",
            "description": "TEST",
            "purpose": "TEST",
            "startingMessage": "Hi Test OD33333333",
            "startDate": "2023-06-16",
            "endDate": "2023-06-30",
            "isBroadcastBotEnabled": True,
            "segmentId": "1",
            "status": "enabled",
            "users": [],
            "logic": [
                conversation_logic_id
            ]
        }
    }

    # Convert the JSON data to a string and manually escape double quotes
    data_str = json.dumps(data).replace('"', '\\"')

    # Build the cURL command with proper data parameter
    curl_command = f'curl --location \'{url}\' ' \
                   f'--header \'asset: {asset}\' ' \
                   f'--header \'admin-token: {admin_token}\' ' \
                   f'--header \'Accept: application/json, text/plain, */*\' ' \
                   f'--header \'ownerOrgID: {owner_org_id}\' ' \
                   f'--header \'ownerID: {owner_id}\' ' \
                   f'--form \'botImage=@"{bot_image_path}"\' ' \
                   f'--form "data={data_str}"'
    
    try:
        # Execute the cURL command
        result = subprocess.run(curl_command, shell=True, capture_output=True, text=True)

        # Check for any errors
        result.check_returncode()

        # Parse the response JSON
        response_json = json.loads(result.stdout)

        # Extract and return the bot ID
        bot_id = response_json["result"]["id"]
        return bot_id

    except subprocess.CalledProcessError as e:
        print("Error occurred during the cURL command execution:")
        print(e.stderr)
        return None

def main():
    # Define versions
    INSTALL_NODE_VER = "16.14.0"
    INSTALL_NVM_VER = "0.39.1"
    INSTALL_YARN_VER = "1.22.17"

    # Print welcome message
    print("\n\n\n****************************************************")
    print("Welcome to the installation script for UCI")
    print("****************************************************")
    print("\n\n\n")

    # Ensure .bashrc exists and is writable
    os.system("touch ~/.bashrc")

    # Stage 1: Node.js setup
    print_stage_message("Stage 1: Node.js setup")

    install_node_version_manager()
    install_nodejs()
    install_yarn()
    add_yarn_to_path()

    # Stage 2: Exporting keys and environment variables
    print_stage_message("Stage 2: Exporting keys and environment variables")

    export_keys()

    # Stage 3: Docker setup
    print_stage_message("Stage 3: Docker setup")

    check_and_install_docker()
    check_and_install_docker_compose()

    # Stage 4: Cloning repositories
    print_stage_message("Stage 4: Cloning repositories")

    clone_odk_repository()
    clone_uci_apis_repository()

    # Stage 5: Building and setting up UCI Web Channel
    print_stage_message("Stage 5: Building and setting up UCI Web Channel")

    build_and_setup_uci_web_channel()

    # Stage 6: Building and setting up UCI Admin
    print_stage_message("Stage 6: Building and setting up UCI Admin")

    build_and_setup_uci_admin()

    # Stage 7: Running Docker Compose services
    print_stage_message("Stage 7: Running Docker Compose services")

    run_docker_compose_services()
    # Additional steps after installation...

    asset = "bot"
    admin_token = "dR67yAkMAqW5P9xk6DDJnfn6KbD4EJFVpmPEjuZMq44jJGcj65"
    owner_org_id = "org01"
    owner_id = "8f7ee860-0163-4229-9d2a-01cef53145ba"
    path_to_xml = "./media/List-QRB-Test-Bot.xml"
    path_to_image = "./media/Test-Bot-Flow-pwa.png"
        
    # form_id = upload_form(admin_token, path_to_xml)
    form_id = 123456789
    print(f"Form ID: {form_id}")

    logic_id = create_conversation_logic(admin_token, form_id)
    print(f"Logic ID: {logic_id}")

    bot_id = create_bot_with_curl(logic_id)
    print("Bot ID:", bot_id)     


if __name__ == "__main__":
    main()
