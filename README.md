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
```
protoc --include_imports --include_source_info --proto_path protos/ --descriptor_set_out=lib/src/generated/api_descriptor.pb --dart_out=grpc:lib/src/generated protos/sm.proto google/protobuf/timestamp.proto
```

**This runs the server**
```
dart bin/sm_server.dart
```

**This runs a client example**
```
dart bin/sm_client.dart
```

## Deploying ##
```
# First change api_config.yaml backend > address to CloudRun URL (replace https to grpc)
docker build -t grc.io/<your_gcp_project>/grpc-notification-sys:v0.0.1 .```
docker push gcr.io/<your_gcp_project>/grpc-notification-sys:v0.0.1
```

## Cloud Run ##
```
gcloud run deploy --image gcr.io/<your_gcp_project>/grpc-notification-sys:v0.0.1 --memory 1Gi --port=50050 --use-http2 --allow-unauthenticated
gcloud run services describe grpc-notification-sys
```

## API Gateway ##
```
# Replace with your own values
gcloud api-gateway api-configs create grpc-notification-sys-config --api=notification-sys --project=<your_gcp_project> --gr-files=lib/src/generated/api_descriptor.pb,protos/api_config.yaml
gcloud api-gateway gateways create grpc-notification-sys-gateway --api=notification-sys-config --location=us-east1 --project=<your_gcp_project>
gcloud api-gateway describe grpc-notificationsys-gateway --location=us-east1 --project=<your_gcp_project>
```

## Set an env.json file ##
```json
{
    "gcp_project_name": "<replace_it_with_your_own>", 
    "gcp_sa_key_filename": "<replace_it_with_your_own>",
    "cloud_run_url_without_https": "<replace_it_with_your_own>", 
    "firebase_sa_key_filename": "<replace_it_with_your_own>",
    "firebase_project_name": "<replace_it_with_your_own>", 
    "local_postgres_connection_json": {
            "host": "localhost", "port": 5432, "database": "notification_sys_db", "username": "client_user", "password": "<replace_it_with_your_own>"
    }
}
```