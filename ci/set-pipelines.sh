#!/bin/bash

set -e

if [ "$1" = "" ]; then
  echo $0: usage: $0 target
  exit
fi

target=$1
this_directory=`dirname "$0"`

fly -t ${target} set-pipeline -p simple-service-broker-tutorial -c ${this_directory}/../simple-service-broker/ci/pipeline.yml

fly -t ${target} set-pipeline -p gcp-spanner-broker-tutorial -c ${this_directory}/../gcp-service-broker/ci/pipeline.yml

fly -t ${target} set-pipeline -p azure-service-broker-tutorial -c ${this_directory}/../azure-service-broker/ci/pipeline.yml