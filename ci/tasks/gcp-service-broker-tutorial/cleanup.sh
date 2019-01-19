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

# Cleanup resouces pipeline created.
#     * Application
#     * Service Instance
#     * Service Broker
#     * Service Broker Application
cf d $TRADES_APP_NAME -f || echo "Failed deleting application : ${TRADES_APP_NAME}"
cf ds $TUTORIAL_TRADES_SERVICE_INSTANCE_NAME -f || echo "Failed deleting service instance : ${TUTORIAL_TRADES_SERVICE_INSTANCE_NAME}"
cf delete-service-broker $GCP_SERVICE_BROKER_NAME -f || echo "App could not be deleted: ${GCP_SERVICE_BROKER_NAME}"
cf d -f $GCP_SERVICE_BROKER_APP_NAME  || echo "App could not be deleted: ${GCP_SERVICE_BROKER_APP_NAME}"
