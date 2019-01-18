#!/bin/bash

set +x
set -e

. cg-customer-broker/ci/tasks/common.sh

broker_route="$(get_route $BROKER_APPNAME)"

plan_id="$(curl -u admin:secret -H "X-Broker-API-Version: 2.14" https://${BROKER_USERNAME}:${BROKER_PASSWORD}@${broker_route}/v2/catalog | jq -r '.services[] | select(.name=="'"${BROKER_SERVICE_NAME}"'") | .plans[] | select(.name=="'"${BROKER_PLAN_NAME}"'") | .id')"

if [ -z $plan_id ]; then
  echo "Could not find the a plan in the service offering. Service name = ${BROKER_SERVICE_NAME}, Plan name = ${BROKER_PLAN_NAME}"
  exit 1
fi
