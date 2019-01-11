#!/bin/bash

set +x
set -e

cf login -a $CF_API -u $CF_USER -p $CF_PWD -o $CF_ORG -s $CF_SPACE

cd cg-customer-broker

./gradlew assemble

cf push -f simple-service-broker_manifest.yml -p build/libs/*.jar
