#!/bin/bash

set +x
set -e

. cg-customer-broker/ci/tasks/common.sh

if [ -z "$(cf marketplace | grep ${BROKER_SERVICE_NAME})" ]; then
  echo "Could not find service offering via 'cf m': Service offering name = ${BROKER_SERVICE_NAME}"
  exit 1
fi

if [ -z "$(cf m | grep ${BROKER_PLAN_NAME})" ]; then
  echo "Could not find service plan via 'cf m': Service plan name = ${BROKER_PLAN_NAME}"
  exit 1
fi
