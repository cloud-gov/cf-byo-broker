#!/bin/bash

set +x
set -e

. cg-customer-broker/ci/tasks/common.sh

cf create-service ${BROKER_SERVICE_NAME} ${BROKER_PLAN_NAME} ${SERVICE_INSTANCE_NAME}

instance=`cf services | grep ${SERVICE_INSTANCE_NAME}`

if [ -z $instance ]; then
  echo "Could not find service instance via 'cf services': Service instance name = ${SERVICE_INSTANCE_NAME}"
  exit 1
fi
