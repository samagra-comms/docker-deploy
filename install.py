import os
import subprocess
import sys
import shutil
import time
import requests
import json
import argparse
import git
import socket
import os
from dotenv import load_dotenv

# Load environment variables from the .env file
load_dotenv()

# ANSI color escape sequences
green = "\033[0;32m"
red = "\033[0;31m"
reset = "\033[0m"
INSTALL_NODE_VER = "16.14.0"
INSTALL_NVM_VER = "0.39.1"
INSTALL_YARN_VER = "1.22.17"

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

def export_keys(args):
    global ENCRYPTION_KEY, NETCORE_WHATSAPP_AUTH_TOKEN, NETCORE_WHATSAPP_SOURCE, NETCORE_WHATSAPP_URI

    print_stage_message("Exporting keys required for installation")

    # Export keys required for installation
    ENCRYPTION_KEY = args.encryption_key if args.encryption_key else 'None'
    if not ENCRYPTION_KEY:
        print_error_message("ENCRYPTION_KEY is empty. Please contact the administrator.")
        sys.exit(1)

    NETCORE_WHATSAPP_AUTH_TOKEN = args.netcore_whatsapp_auth_token if args.netcore_whatsapp_auth_token else 'None'
    NETCORE_WHATSAPP_SOURCE = args.netcore_whatsapp_source if args.netcore_whatsapp_source else 'None'
    NETCORE_WHATSAPP_URI = args.netcore_whatsapp_uri if args.netcore_whatsapp_uri else 'None'

    print()

    # Export environment variables
    with open('.env', 'r') as file:
        env_lines = file.readlines()

    with open('.env', 'w') as file:
        for line in env_lines:
            if line.startswith('NETCORE_WHATSAPP_AUTH_TOKEN='):
                line = f'NETCORE_WHATSAPP_AUTH_TOKEN={NETCORE_WHATSAPP_AUTH_TOKEN}\n'
            elif line.startswith('NETCORE_WHATSAPP_SOURCE='):
                line = f'NETCORE_WHATSAPP_SOURCE={NETCORE_WHATSAPP_SOURCE}\n'
            elif line.startswith('NETCORE_WHATSAPP_URI='):
                line = f'NETCORE_WHATSAPP_URI={NETCORE_WHATSAPP_URI}\n'
            elif line.startswith('ENCRYPTION_KEY='):
                line = f'ENCRYPTION_KEY={ENCRYPTION_KEY}\n'
            file.write(line)
            
def update_env_with_ip(env_file_path):
    try:
        system_ip = get_system_ip()
        if system_ip:
            # Define the lines to be updated with the system IP
            lines_to_update = [
                f'REACT_APP_TRANSPORT_SOCKET_URL="ws://{system_ip}:3005/"\n',
                f'REACT_APP_UCI_BOT_BASE_URL="http://{system_ip}:3002"\n',
                f'REACT_APP_CHAT_HISTORY_URL="http://{system_ip}:9080/"\n'
            ]

            # Read the .env file and update the specified lines
            with open(env_file_path, 'r') as file:
                env_lines = file.readlines()

            with open(env_file_path, 'w') as file:
                for line in env_lines:
                    if line.startswith('REACT_APP_TRANSPORT_SOCKET_URL='):
                        line = lines_to_update[0]
                    elif line.startswith('REACT_APP_UCI_BOT_BASE_URL='):
                        line = lines_to_update[1]
                    elif line.startswith('REACT_APP_CHAT_HISTORY_URL='):
                        line = lines_to_update[2]
                    file.write(line)

            print("Updated .env file with system IP:", system_ip)
        else:
            print("Failed to get the system IP address. .env file not updated.")
    except Exception as e:
        print("Error updating .env file:", str(e))

def clone_odk_repository():
    print_stage_message("Cloning ODK repository")

    if os.path.exists("odk-aggregate"):
        print("ODK repository already exists.")
        print()
        return

    # Clone the ODK repository using GitPython
    try:
        git.Repo.clone_from("https://github.com/samagra-comms/odk.git", "odk-aggregate")
        print("ODK repository clone complete.")
        print()
    except git.exc.GitCommandError as e:
        print_error_message(f"Error while cloning ODK repository: {e}")
        sys.exit(1)

def clone_uci_admin():
    print_stage_message("Cloning Admin repository")

    if os.path.exists("uci-admin"):
        print("Admin repository already exists.")
        print()
        return

    try:
        git.Repo.clone_from("https://github.com/samagra-comms/uci-admin", "uci-admin")
        print("Admin repository clone complete.")
        print()
    except git.exc.GitCommandError as e:
        print_error_message(f"Error while cloning Admin repository: {e}")
        sys.exit(1)
        
def clone_uci_web_channel():
    print_stage_message("Cloning Web-channel")

    if os.path.exists("uci-admin"):
        print("Web-channel repository already exists.")
        print()
        return

    try:
        git.Repo.clone_from("https://github.com/samagra-comms/uci-web-channel", "uci-web-channel", branch="demo-NL")
        print("Web-channel clone complete.")
        print()
    except git.exc.GitCommandError as e:
        print_error_message(f"Error while cloning Web-channel: {e}")
        sys.exit(1)


def replace_env_variable(file_path, variable_name, variable_value):
    with open(file_path, "r") as file:
        lines = file.readlines()

    with open(file_path, "w") as file:
        for line in lines:
            if line.startswith(f"{variable_name}="):
                line = f"{variable_name}={variable_value}\n"
            file.write(line)

def run_fusionauth_services():
    print_stage_message("Building ElasticSearch and FusionAuth containers. This may take a few minutes.")

    try:
        services_to_start = ["fa-search","fusionauth","fa-db"]

        for service in services_to_start:
            print(f"Starting '{service}' service...")
            subprocess.run(["docker-compose", "up", "-d", service], check=True)

        print("All services are up")
        print()

    except subprocess.CalledProcessError as e:
        print_error_message(f"Error while running Docker Compose services: {e}")
        sys.exit(1)
        
def run_odk_services():
    print_stage_message("Setting up ODK components. This may take a few minutes.")

    try:
        services_to_start = ["aggregate-db","wait_for_db","aggregate-server"]

        for service in services_to_start:
            print(f"Starting '{service}' service...")
            subprocess.run(["docker-compose", "up", "-d", service], check=True)

        print("All services are up")
        print()

    except subprocess.CalledProcessError as e:
        print_error_message(f"Error while running Docker Compose services: {e}")
        sys.exit(1)
        
def run_docker_services():
    print_stage_message("Setting up ODK components. This may take a few minutes.")

    try:
        subprocess.run(["docker-compose", "up", "-d"], check=True)

        print("All services are up")
        print()

    except subprocess.CalledProcessError as e:
        print_error_message(f"Error while running Docker Compose services: {e}")
        sys.exit(1)
        
def run_kafka_services():
    print_stage_message("Setting up Kafka components. This may take a few minutes.")

    try:
        services_to_start = ["cass","kafka","schema-registry","zookeeper","connect"]

        for service in services_to_start:
            print(f"Starting '{service}' service...")
            subprocess.run(["docker-compose", "up", "-d", service], check=True)

        print("All services are up")
        print()

    except subprocess.CalledProcessError as e:
        print_error_message(f"Error while running Docker Compose services: {e}")
        sys.exit(1)
    
def upload_form(path_to_xml):
    print_stage_message("Uploading form")

    url = "http://localhost:8080/formUpload"
    files = {
        "form_def_file": (path_to_xml.split("/")[-1], open(path_to_xml, "rb"))
    }

    try:
        response = requests.post(url, files=files)
        response.raise_for_status()
        print("Form upload successful.")
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
        logic_id = response_data["result"]["id"]
        print("Conversation logic creation successful.")
        print()
        return logic_id
    except requests.exceptions.RequestException as e:
        print_error_message(f"Error while creating conversation logic: {e}")
        sys.exit(1)



def create_bot_with_curl(conversation_logic_id, admin_token):
    url = 'http://localhost:9999/admin/bot'
    asset = 'bot'
    owner_org_id = 'org01'
    owner_id = '8f7ee860-0163-4229-9d2a-01cef53145ba'
    bot_image_path = './media/Test-Bot-Flow-pwa.png'

    # JSON data containing the conversation_logic_id
    data = {
        "data": {
            "name": "Sample Conversation Bot",
            "description": "Sample",
            "purpose": "Sample",
            "startingMessage": "Hey",
            "startDate": "2023-06-16",
            "endDate": "2024-06-30",
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
    
def get_system_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        system_ip = s.getsockname()[0]
        s.close()
        return system_ip
    except Exception as e:
        print_error_message(f"Error while getting system IP: {e}")
        sys.exit(1)
        
def run_cassandra_queries(cql_file_path):
    command = [
        "docker-compose", "exec", "cass",
        "cqlsh", "-f", cql_file_path
    ]
    
    subprocess.run(command)
    
def create_empty_topic(topic_name, broker_list="localhost:9092"):
    
    command = "docker-compose exec kafka sh -c 'echo "" | kafka-console-producer --broker-list localhost:9092 --topic com.odk.transformer'"
    subprocess.run(command, shell=True, executable='/bin/sh')

def restart_transformer():
    command = [
        "docker", "compose", "restart", "transformer"
    ]
    
    subprocess.run(command)

def execute_hasura_queries():
    
    hasura_admin_key = os.getenv("HASURA_GRAPHQL_ADMIN_SECRET")
    
    system_ip = get_system_ip()
    
    instructions_prev=f"""
        1. Open your web browser and go to {system_ip}:15003 (Hasura Console).
        2. Enter this api key when asked: {hasura_admin_key}
        3. Once logged in, you'll be on the main dashboard.
        4. Look for the "Data" tab, usually located in the top menu or navigation panel.
        5. Under the "Data" tab, you'll find a list of databases and schemas on the left side. Locate the "public" schema under the default database.
        6. Click on the "public" schema. The schema's contents will be displayed in the main area.
        7. In the upper-right corner, you'll find a button that might say "Untracked" or "Track All." Click on it to start tracking all the relations and tables within the "public" schema.
        8. Hasura will initiate the tracking process, and you'll see the status changing for each table and relation as they are being tracked.
        9. Wait for the tracking process to complete. Once done, you'll see that all tables and relations have been successfully tracked

        1. Look for the "SQL" tab, typically located below the "Databases" section.
        2. Click on the "SQL" tab to access the SQL editor.
        3. In the SQL editor, you'll see a space where you can write and execute SQL queries.
        4. Copy these below queries:
        """
    
    instructions_after="""
        INSERT INTO "Service" ("id", "updatedAt", "type", "config")
        VALUES ('94b7c56a-6537-49e3-88e5-4ea548b2f075', NOW(), 'odk', '{"cadence": { "retries": 0, "timeout": 60, "concurrent": true, "retries-interval": 10 }, "credentials": { "vault": "samagra", "variable": "samagraMainODK" } }');
        INSERT INTO "Adapter" ("id", "updatedAt", "provider", "channel", "config", "name") 
        VALUES ('44a9df72-3d7a-4ece-94c5-98cf26307324', NOW(), 'gupshup', 'WhatsApp', '{ "2WAY": "2000193033", "phone": "9876543210", "HSM_ID": "2000193031", "credentials": { "vault": "samagra", "variable": "gupshupSamagraProd" } }', 'SamagraProd');

        INSERT INTO "Adapter" ("id", "updatedAt", "provider", "channel", "config", "name") 
        VALUES ('44a9df72-3d7a-4ece-94c5-98cf26307323', NOW(), 'Netcore', 'WhatsApp', '{ "phone": "912249757677", "credentials": { "vault": "samagra", "variable": "netcoreUAT" } }', 'SamagraNetcoreUAT');

        INSERT INTO "Adapter" ("id", "updatedAt", "provider", "channel", "config", "name") 
        VALUES ('64036edb-e763-44b1-99b8-37b6c7b292c5', NOW(), 'gupshup', 'sms', '{"2WAY":"2000193033","phone":"9876543210","HSM_ID":"2000193031","credentials":{"vault":"samagra","variable":"gupshupSamagraProd"}}', 'SamagraGupshupSms');

        INSERT INTO "Adapter" ("id", "updatedAt", "provider", "channel", "config", "name") 
        VALUES ('4e0c568c-7c42-4f88-b1d6-392ad16b8546', NOW(), 'cdac', 'sms', '{"2WAY":"2000193033","phone":"9876543210","HSM_ID":"2000193031","credentials":{"vault":"samagra","variable":"gupshupSamagraProd"}}', 'SamagraCdacSms');

        INSERT INTO "Adapter" ("id", "updatedAt", "provider", "channel", "config", "name") 
        VALUES ('2a704e82-132e-41f2-9746-83e74550d2ea', NOW(), 'firebase', 'web', '{ "credentials": { "vault": "samagra", "variable": "uci-firebase-notification" } }', 'SamagraFirebaseWeb');

        INSERT INTO "Transformer" ("name", "tags", "config", "id", "serviceId", "updatedAt") 
        VALUES ('SamagraODKAgg', array['ODK'], '{}', 'bbf56981-b8c9-40e9-8067-468c2c753659', '94b7c56a-6537-49e3-88e5-4ea548b2f075', NOW());

        INSERT INTO "Transformer" ("name", "tags", "config", "id", "serviceId", "updatedAt") 
        VALUES ('SamagraBroadcast', array['broadcast'], '{}', '774cd134-6657-4688-85f6-6338e2323dde', '94b7c56a-6537-49e3-88e5-4ea548b2f075', NOW());

        INSERT INTO "Transformer" ("name", "tags", "config", "id", "serviceId", "updatedAt") 
        VALUES ('SamagraGeneric', array['generic'], '{}', '0832ca13-c698-4234-8070-b5f708bc0b1a', '94b7c56a-6537-49e3-88e5-4ea548b2f075', NOW());    

        5. Paste the queries into the SQL editor, just below the "public" database schema.
        6. After verifying the queries, you can execute them by clicking on the "Run" or "Execute" button, often represented by a play button icon.
        7. The queries will be executed, and the tables will be populated by sample adapters.
        """
    print(instructions_prev)
    print(instructions_after)
    
    user_input = input("Once you've executed the queries, enter 'YES' to continue: ")
    
    if user_input.strip().upper() == 'YES':
        print("Continuing with the execution...")
    else:
        print("Execution aborted.")    

def cassandra_wait(seconds, message="Waiting..."):
    print(message, end=" ")
    for remaining in range(seconds, -1, -1):
        progress = (seconds - remaining) / seconds * 100
        sys.stdout.write("\r[%-50s] %d%%" % ('=' * int(progress / 2), progress))
        sys.stdout.flush()
        time.sleep(1)
    print("\nCassandra is ready now!")

def main():
    parser = argparse.ArgumentParser(description="UCI Installation Script")
    parser.add_argument("encryption_key", help="Encryption Key")
    parser.add_argument("--netcore_whatsapp_auth_token", help="Netcore Whatsapp Auth Token",required=False)
    parser.add_argument("--netcore_whatsapp_source", help="Netcore Whatsapp Source",required=False)
    parser.add_argument("--netcore_whatsapp_uri", help="Netcore Whatsapp URI",required=False)
    args = parser.parse_args()

    # Print welcome message
    print("\n\n\n****************************************************")
    print("Welcome to the installation script for UCI")
    print("****************************************************")
    print("\n\n\n")

    # Ensure .bashrc exists and is writable
    os.system("touch ~/.bashrc")

    # Stage 1: Exporting keys and environment variables
    print_stage_message("Stage 1: Exporting keys and environment variables")

    export_keys(args)
    update_env_with_ip(".env") 
    get_system_ip()

    # Stage 3: Cloning repositories
    print_stage_message("Stage 2: Cloning ODK")

    clone_odk_repository()
    clone_uci_admin()

    # Stage 4: Running Docker Compose services
    print_stage_message("Stage 3: Running Docker Compose services")

    run_fusionauth_services()
    run_kafka_services()
    run_odk_services()
    run_docker_services()
    
    # Additional steps after installation...
    
    execute_hasura_queries()

    cassandra_wait(60, "Let's give cassandra some time to be up and running")

    run_cassandra_queries("/docker-entrypoint-initdb.d/cassandra.cql")

    admin_token = os.getenv("ADMIN_TOKEN")
    path_to_xml = "./media/odk.xml"
    upload_form(path_to_xml)       
    form_id = "UCI-Setup-Test-Form"
    print(f"Form ID: {form_id}")

    logic_id = create_conversation_logic(admin_token, form_id)
    print(f"Logic ID: {logic_id}")

    bot_id = create_bot_with_curl(logic_id,admin_token)
    print("Bot ID:", bot_id)     
    
    #create an empty kafka topic (transformer dependency)
    create_empty_topic("localhost:9092", "com.odk.transformer")

    restart_transformer()

if __name__ == "__main__":
    main()
