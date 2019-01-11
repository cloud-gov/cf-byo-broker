#!/bin/bash

set +x
set -e

cf login -a $CF_API -u $CF_USER -p $CF_PWD -o $CF_ORG -s $CF_SPACE

broker_guid=` cf app ${BROKER_APPNAME} --guid`

broker_route=`cf curl /v2/apps/${broker_guid}/env | jq -r '.application_env_json.VCAP_APPLICATION.application_uris[0]'`

plan_id=`curl https://${BROKER_USERNAME}:${BROKER_PASSWORD}@${broker_route}/v2/catalog | jq -r '.services[] | select(.name=="'"${BROKER_SERVICE_NAME}"'") | .plans[] | select(.name=="'"${BROKER_PLAN_NAME}"'") | .id'`

if [ -z $plan_id ]; then
  echo "Could not find the a plan in the service offering. Service name = ${BROKER_SERVICE_NAME}, Plan name = ${BROKER_PLAN_NAME}"
  exit 1
fi
