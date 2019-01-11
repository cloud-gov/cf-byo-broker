#!/bin/bash

set +x
set -e

. cg-customer-broker/ci/tasks/common.sh

pushd cg-customer-broker/simple-service-broker/app-source
  ./gradlew assemble
  cf push -f ../simple-service-broker_manifest.yml -p build/libs/*.jar
popd
