#!/bin/bash

set -x
set -e

. cg-customer-broker/ci/tasks/common.sh

cd gcp-service-broker

cat << EOF > manifest.yml
---
applications:
  - name: gcp-service-broker
    product_version: "4.1.0"
    metadata_version: "1.0"
    label: 'GCP Service Broker'
    description: 'A service broker for Google Cloud Platform services.'
    memory: 1G
    buildpacks: 
      - go_buildpack
    env:
      GOPACKAGENAME: github.com/GoogleCloudPlatform/gcp-service-broker
      GOVERSION: go1.10
      ROOT_SERVICE_ACCOUNT_JSON: $ROOT_SERVICE_ACCOUNT_JSON
      SECURITY_USER_NAME: secuser
      SECURITY_USER_PASSWORD: secpass
      DB_HOST: 104.197.57.63
      DB_USERNAME: root
      DB_PASSWORD: micropdb

EOF

cat manifest.yml