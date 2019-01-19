#!/bin/bash

set +x
set -e

. cg-customer-broker/ci/tasks/common.sh

cf bind-service ${BROKER_APPNAME} ${SERVICE_INSTANCE_NAME}

if [ -z "$(cf services | grep ${SERVICE_INSTANCE_NAME} | grep ${BROKER_APPNAME})" ]; then
  echo "Could not find bound service instance via 'cf services': App name = ${BROKER_APPNAME}, Service instance name = ${SERVICE_INSTANCE_NAME}"
  exit 1
fi
