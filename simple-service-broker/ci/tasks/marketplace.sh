#!/bin/bash

set +x
set -e

. cg-customer-broker/ci/tasks/common.sh

offering_name=`cf marketplace | grep ${BROKER_SERVICE_NAME}`

if [ -z $offering_name ]; then
  echo "Could not find service offering via 'cf m': Service offering name = ${BROKER_SERVICE_NAME}"
  exit 1
fi

plan_name=`cf m | grep ${BROKER_PLAN_NAME}`

if [ -z $plan_name ]; then
  echo "Could not find service plan via 'cf m': Service plan name = ${BROKER_PLAN_NAME}"
  exit 1
fi
