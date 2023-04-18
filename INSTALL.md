# Here are some steps that are to be manually run to get UCI working

- Setup a minio + FusionAuth setup following this guide -> https://github.com/Samagra-Development/minio-oauth2-docs. This part will be automated in future versions, but it is manual for now. 

- Populate the .env file with minio and fusionauth secrets after setup. 

- ODK's default password is not picked on runtime, if you are using something other password than default password, you have to manually reset the password for administrator user. 

- Hashicorp Vault has to initiated for the first time and relevant keys should be copied. 
- A `kv v1` engine has to be created with firebase secrets

- Org and ownerIDs to be created

- Manual adapters are need to be created - https://uci.sunbird.org/use/developer/uci-basics 

- Transformer - broadcast, generic and ODK has to created

- On the first run cassandra migrations are applied. If you see any migration error then set it to `0` to run all migrations if not already applied, else set to `6` if all migrations are applied. In most cases after the first run, setting the `migrations count` in `.env` to `6` will work. 

