#!/bin/bash
###################################################################################
#
#  This script creates a GCP Spanner service instance which apps will then bind.
#
####################################################################################

set +x
set -e

. cg-customer-broker/ci/tasks/common.sh

# Start the creation of the service instance
cf cs $TRADES_SERVICE $TRADES_SERVICE_PLAN $TUTORIAL_TRADES_SERVICE_INSTANCE_NAME -c '{"name":"trades"}'

# The above command returns before the create has completed. Loop until the service creation has succeeded.
until cf service $TUTORIAL_TRADES_SERVICE_INSTANCE_NAME | grep "succeeded"; do
  echo sleeping
  sleep 1
  if [[ $(cf service tutorial-trades-service-instance | grep status) == *failed* ]]
  then
      echo "failed"
      exit 1
  fi
done

