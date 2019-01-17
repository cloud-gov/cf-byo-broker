#!/bin/bash

set +x
set -e

. cg-customer-broker/ci/tasks/common.sh

cf stop ${BROKER_APPNAME}

cf purge-service-instance -f ${SERVICE_INSTANCE_NAME}

instance=`cf services | grep ${SERVICE_INSTANCE_NAME}`

echo "instance: $instance"

if [ -z "$instance" ]; then
  echo "Service instance purged"
else
  echo "Service instance was not purged (found by cf services): Service instance name = ${SERVICE_INSTANCE_NAME}"
  exit 1
fi
