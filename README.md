# Notification System #

ATTENTION: this is a work in progress

This project implements a notification system designed to handle push notification to mobile devices from different client languages

## Parts ##

* Client: an application that will consume services. You can find a Dart web version in this repo.
* Server: an application that serves endpoints for handling notification. Basically the code in this repo.

## Environment Setup ##

* Run lines on the Command section
* Install plugins on VSCode - Dart and vscode-proto3
* Create a project and a service account on GCP

## Contribution guideline ##

* Create Android client app using Kotlin and Java
* Create iOS client app using Swift and Objective-C
* Create Flutter mobile client
* Create React Native client
* Create Flutter web client

## Commands ##
```
# Installing Dart on Mac
brew tap dart-lang/dart
brew install dart

# Installing protobuf on Mac
brew install protobuf
protoc --version

# Activating proto to Dart
dart pub global activate protocol_plugin

# Add it to Path
PATH="$PATH:$HOME/.pub-cache/bin/" on Mac
PATH="$PATH:/home/<your_user>/.pub-cache/bin/" on Linux

# Add googleapis
cd /opt
git clone https://github.com/googleapis/googleapis
PATH="$PATH:/opt/googleapis/" on Linux
OR export GOOGLEAPIS_DIR=/opt/googleapis on /home/<USER>/.bashrc

# gcloud
Download adn extract google-cloud-sdk at https://cloud.google.com/sdk/docs/quickstart
Run ./google-cloud-sdk.install.sh
Run gcloud init 
Choose your GCP project when prompted

# GCP Services
gcloud services enable apigateway.googleapis.com
gcloud services enable servicemanagement.googleapis.com
gcloud services enable servicecontrol.googleapis.com
gcloud services enable containerregistry.googleapis.com

# Docker on Mac
Download and install https://docs.docker.com/desktop/mac/install/
gcloud auth configure-docker
```

## Running ##
**This generates classes for proto**
```bash
protoc --include_imports --include_source_info --proto_path=${GOOGLEAPIS_DIR} --proto_path=protos/ --descriptor_set_out=lib/src/generated/api_descriptor.pb --dart_out=grpc:lib/src/generated protos/sm.proto google/protobuf/timestamp.proto
```

**This runs a client example**
```bash
dart bin/sm_client.dart
```

**This runs the server**
```bash
dart bin/sm_server.dart
```


## Deploying ##
**Docker**
```bash
open -a Docker # on Mac
# First change api_config.yaml backend > address to CloudRun URL (replace https to grpc)
docker build -t grc.io/<your_gcp_project>/grpc-notification-sys:v0.0.1 .
docker push gcr.io/<your_gcp_project>/grpc-notification-sys:v0.0.1
```

**Cloud Run**
```bash
gcloud run deploy --image gcr.io/<your_gcp_project>/grpc-notification-sys:v0.0.1 --memory 1Gi --port=50050 --use-http2 --allow-unauthenticated --add-cloudsql-instances=<instance:region:db_name>
# Choose default name, us-central, allow unauthenticated invocations
gcloud run services describe grpc-notification-sys
```

**API Gateway**
```bash
# Replace with your own values
gcloud api-gateway api-configs create grpc-notification-sys-config --api=notification-sys --project=<your_gcp_project> --gr-files=lib/src/generated/api_descriptor.pb,protos/api_config.yaml
gcloud api-gateway gateways create grpc-notification-sys-gateway --api=notification-sys-config --location=us-east1 --project=<your_gcp_project>
gcloud api-gateway describe grpc-notificationsys-gateway --location=us-east1 --project=<your_gcp_project>
```

**Cloud SQL Postgres**
*Remote DB*
Follow https://cloud.google.com/sql/docs/postgres/connect-run
Use a db-f1-micro instance with lower values at first to not increase cost initially. You can scale it up later.

*Local DB (on Mac)*
It is recommended using DBeaver Community edition as a tool to access either local and remote database. Here's the steps you can follow to get your local db up and running on Mac.
```bash
brew install --cask dbeaver-community
brew install postgresql
brew services start postgresql
initdb /user/local/va/postgres -E utf8

# from now on you can use dbeaver gui instead of next commands
psql postgres

# put a passwd for postgres and save it elsewhere
\password postgres

create database <db_name>;

# create a diff database user
create user <your_db_role> with password '<your_passwd>';

alter role <your_db_role> set client_encoding to 'utf-8'; 
alter role <your_db_role> set default transaction_isolation to 'read committed';
alter role <your_db_role> set set timezone to 'utc';
grant all privileges on database <db_name> to <your_db_role>;
grant execute on all functions in schema <your_schema> to <your_db_role>;
grant usage on schema <your_schema> to <your_db_role>;
grant all on all tables in schema <your_schema> to <your_db_role>;

\q
```

*Local DB (on Linux)*
```bash
sudo pacman -S postgresql
sudo snap install dbeaver-ce
sudo -iu postgres
initdb --locale $LANG -E UTF8 -D '/var/lib/postgres/data/'
exit
sudo systemctl enable --now postgresql.service
sudo su - postgres
psql
CREATE DATABASE notification_sys_db;
CREATE USER client_user WITH PASSWORD '<<YOUR_PASSWD>>';
ALTER ROLE client_user SET client_encoding TO 'utf8';
ALTER ROLE client_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE client_user SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE notification_sys_db TO client_user;
\q
exit
```

*Database Loading*
Run the script at [here](db/create.sql)

**FCM**
Add FCM generated json to keys/ folder. This can be downloaded when you set notifications up or at the settings of Firebase.

**Env Vars**
Fill variables at helper/utils.dart
Example
```json
{
    "database_location": "LOCAL",
    "endpoint_location": " LOCAL",    
    "gcp_project_name": "grpc-notification-sys-asdsadadsa-ue.a.run.app",
    "gcp_sa_key_filename": "keys/my-project-asfsadsada.json",
    "cloud_run_url_without_https": "grpcs://grpc-notification-sys-asdsadadsa-ue.a.run.app",
    "firebase_sa_key_filename": "keys/my-fcm-project-abcde-firebase-adminsdk-abcde-asdasdasdsa.json",
    "firebase_project_name": "projects/notificationsys-abcde",
    "local_postgres_connection_json": {
        "host": "localhost", "port": 5432, "database": "<db_name>", "username": "<your_db_role>", "password": "<your_db_role_local_passwd>"
    },
    "remote_postgres_connection_json": {
        "host": "<cloud_sql_public_ip>", "port": 5432, "database": "<db_name>", "username": "<your_db_role>", "password": "<your_db_role_local_passwd>"
    }    
}
```

**Env Var on GCP Secret Manager**
Add the json above to a secret and name it /keys/notification_sys_secret
