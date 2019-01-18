#!/bin/bash

set +x
set -e

. cg-customer-broker/ci/tasks/common.sh

if [ -z "$(cf service-brokers | grep ${BROKER_APPNAME})" ]; then
  echo "Could not find broker via 'cf service-brokers': Broker name = ${BROKER_APPNAME}"
  exit 1
fi
