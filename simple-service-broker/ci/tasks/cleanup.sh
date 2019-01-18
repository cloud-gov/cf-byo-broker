#!/bin/bash

set +x
set -e

. cg-customer-broker/ci/tasks/common.sh

cf purge-service-instance -f $SERVICE_INSTANCE_NAME || echo "Service instance could not be purged: ${SERVICE_INSTANCE_NAME}"

cf delete-service-broker -f ${BROKER_APPNAME}-${CF_ORG}-${CF_SPACE} || echo "Could not delete service broker: ${BROKER_APPNAME}"

cf delete -f -r $BROKER_APPNAME || echo "App could not be deleted: ${BROKER_APPNAME}"

cf t -s $CF_ANOTHER_SPACE

cf delete-service-broker -f ${BROKER_APPNAME}-${CF_ORG}-${CF_ANOTHER_SPACE} || echo "Could not delete service broker: ${BROKER_APPNAME}"
