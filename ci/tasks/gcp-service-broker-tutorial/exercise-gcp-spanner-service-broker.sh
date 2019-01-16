#!/bin/bash
###################################################################################
#
#  This script exercises the GCP Spanner service create in a previous step.
#      * Create the Spanner service
#      * Push an example Spanner application to CF
#      * Bind the service to the app
#      * Start the service
#      * Access the app endpoint and verify the expected results are return.
#
####################################################################################

set -x
set -e

. cg-customer-broker/ci/tasks/common.sh

# Start the creation of the service instance
cf cs $GCP_SPANNER_SERVICE $GCP_SPANNER_SERVICE_PLAN $TUTORIAL_GCP_SPANNER_SERVICE_INSTANCE_NAME -c '{"name":"trades"}'

# The above command returns before the create has completed. Loop until the service creation has succeeded.
until cf service $TUTORIAL_GCP_SPANNER_SERVICE_INSTANCE_NAME | grep "succeeded"; do
  echo sleeping
  sleep 1
  if [[ $(cf service tutorial-gcp-spanner-service-instance | grep status) == *failed* ]]
  then
      echo "failed"
      exit 1
  fi
done

