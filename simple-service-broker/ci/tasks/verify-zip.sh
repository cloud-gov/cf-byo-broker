#!/bin/bash

set -e

curl -O ${BROKER_ZIP_URL}

unzip simple-service-broker.zip

difference=`diff -arq --exclude=".git" broker-source simple-service-broker`

if [ -z $difference ]; then
  echo "Verified zip file contents"
else
  echo "Downloaded zip differs from the latest broker source: ${difference}"
  exit 1
fi
