### Installation Scripts for UCI

Please note this installation is just the first step. If your needs are not fulfilled with the current installation, please start scaling the individual services by using them in docker stack.

```bash install.sh```

If you are just here to try the setup please click on the button below.

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/samagra-comms/docker-deploy)

### Manual Steps

1. To get the messages from any service provider say netcore/gupshup, contact their support team, and ask them to add your ip with netcore/gupshup adapter url
For Netcore: ip:inbound_extrenal_port/netcore/whatsApp (Eg. - 143.112.x.x:9080/netcore/whatsApp)
For Gupshup: ip:inbound_external_port/gupshup/whatsApp (Eg. - 143.112.x.x:9080/gupshup/whatsApp)

2. To sent messages via outbound, we'll use API from service provider (Netcore/Gupshup). For Netcore, Contact their support team to grant below credentials :
    ```
        NETCORE_WHATSAPP_AUTH_TOKEN = # Authentication Token 

        NETCORE_WHATSAPP_SOURCE = # Source ID for sending messages to Netcore 

        NETCORE_WHATSAPP_URI = # Netcore API Base URL
    ```

2. [Tracking Tables](https://hasura.io/docs/latest/graphql/core/databases/postgres/schema/using-existing-database.html#step-1-track-tables-views). Go to the url http://localhost:15003/console/data/default/schema/public and track all tables and relations. The admin secret can be controlled using this [line](https://github.com/samagra-comms/docker-deploy/blob/10bdbc4b837a61f74a1270ce53467b15f63d182d/.env#L67)

3. Adding default data for transformers 
    - Go to http://localhost:15003/console/data/default/schema/public and track all of the items one by one.
    - In the sidebar click on the SQL button and add the following commands and run.
        ```sql
        INSERT INTO service ("id", "type", "config")
        VALUES ('94b7c56a-6537-49e3-88e5-4ea548b2f075', 'odk', '{"cadence": { "retries": 0, "timeout": 60, "concurrent": true, "retries-interval": 10 }, "credentials": { "vault": "samagra", "variable": "samagraMainODK" } }');
        INSERT INTO adapter ("id", "provider", "channel", "config", "name") 
        VALUES ('44a9df72-3d7a-4ece-94c5-98cf26307324', 'WhatsApp', 'gupshup', '{ "2WAY": "2000193033", "phone": "9876543210", "HSM_ID": "2000193031", "credentials": { "vault": "samagra", "variable": "gupshupSamagraProd" } }', 'SamagraProd');
        INSERT INTO adapter ("id", "provider", "channel", "config", "name") 
        VALUES ('44a9df72-3d7a-4ece-94c5-98cf26307323', 'WhatsApp', 'Netcore', '{ "phone": "912249757677", "credentials": { "vault": "samagra", "variable": "netcoreUAT" } }', 'SamagraNetcoreUAT');
        INSERT INTO transformer ("name", "tags", "config", "id", "service_id") 
        VALUES ('SamagraODKAgg', array['ODK'], '{}', 'bbf56981-b8c9-40e9-8067-468c2c753659', '94b7c56a-6537-49e3-88e5-4ea548b2f075'); 
        ```

4. to Create a bot use these steps :
    * Upload a odk form :
        ```
            curl --location --request POST 'http://localhost:9999/admin/v1/forms/upload' \
            --header 'admin-token: EXnYOvDx4KFqcQkdXqI38MHgFvnJcxMS' \
            --form 'form=@"{PATH_OF_ODK_FORM}"'
        ```
    * Create a conversation logic :
        ```
            curl --location --request POST 'http://localhost:9999/admin/v1/conversationLogic/create' \
            --header 'admin-token: EXnYOvDx4KFqcQkdXqI38MHgFvnJcxMS' \
            --header 'Content-Type: application/json' \
            --data-raw '{
                "data": {
                    "name": "UCI demo bot logic",
                    "transformers": [
                        {
                            "id": "bbf56981-b8c9-40e9-8067-468c2c753659",
                            "meta": {
                                "form": "https://hosted.my.form.here.com",
                                "formID": "UCI-demo-1"
                            }
                        }
                    ],
                    "adapter": "44a9df72-3d7a-4ece-94c5-98cf26307323"
                }
            }'
        ```

    * Create a bot :
        ```
            curl --location --request POST 'http://localhost:9999/admin/v1/bot/create' \
            --header 'admin-token: EXnYOvDx4KFqcQkdXqI38MHgFvnJcxMS' \
            --header 'Content-Type: application/json' \
            --data-raw '{
                "data": {
                    "startingMessage": "Hi UCI",
                    "name": "UCI demo bot",
                    "users": [],
                    "logic": [
                        "c556dfc8-5dd3-477c-83bb-65d234c4d223"
                    ],
                    "status": "enabled",
                    "startDate": "2022-03-25",
                    "endDate": "2022-05-25"
                }
            }'
        ```

5. Now update Form List of transformer :
    ```
        curl --location --request GET 'localhost:9091/odk/updateAll' \
        --header 'Content-Type: application/json'
    ```

6. Now we can start Sent/Receive messages from channel.

7. You can start using FusionAuth Console using [link](http://localhost:9011/) and create an Account, for managing users and what resources they are authorized to access.

8. For managing all the assesment data go on URL : http://localhost:15002/ and track all the tables and relation.


### TODO
1. DB for UCI APIs doesn't get auto populated for the default ODK transformers.
2. [Auto Tracking of tables not supported](https://github.com/hasura/graphql-engine/issues/1418) - this can be automated by writing a script to do POST requests like mentioned [here](https://hasura.io/docs/latest/graphql/core/api-reference/schema-metadata-api/table-view.html).
3. Adding docker stack commands to scale up.
4. Add benchmarking.
5. Add Gitpod.
6. Add CI to verify setup.