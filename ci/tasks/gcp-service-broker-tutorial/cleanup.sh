#!/bin/bash
#########################################################################
#
#  This script performs the cleanup activities for the GCP Service Broker
#  tutorial pipeline. The intent is to leave the environment in the same
#  state prior to the execution of the pipeline.
#
#########################################################################

set +x
set -e

. cg-customer-broker/ci/tasks/common.sh

# Delete the service broker and then the application backing the service broker.
cf delete-service-broker $GCP_SERVICE_BROKER_NAME || echo "App could not be deleted: ${GCP_SERVICE_BROKER_NAME}"
cf d -f $GCP_SERVICE_BROKER_APP_NAME  || echo "App could not be deleted: ${GCP_SERVICE_BROKER_APP_NAME}"
