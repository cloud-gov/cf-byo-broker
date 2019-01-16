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

set +x
set -e

. cg-customer-broker/ci/tasks/common.sh

cf cs $GCP_SERVICE_BROKER_NAME sandbox $GCP_SPANNER_SERVICE_NAME -c '{"name":"trades"}'

