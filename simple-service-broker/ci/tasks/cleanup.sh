#!/bin/bash

set +x
set -e

. cg-customer-broker/ci/tasks/common.sh

cf delete-service-broker -f ${BROKER_APPNAME} || echo "Could not delete service broker: ${BROKER_APPNAME}"

cf delete -f -r $BROKER_APPNAME || echo "App could not be deleted: ${BROKER_APPNAME}"

cf delete-service -f $SERVICE_INSTANCE_NAME || echo "Service instance could not be deleted: ${SERVICE_INSTANCE_NAME}"
