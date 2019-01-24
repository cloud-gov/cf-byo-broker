#!/bin/bash

set -x
set -e

. cg-customer-broker/ci/tasks/common.sh

cd trades-release

unzip *.zip

cd trades
cf p $TRADES_APP_NAME -p trades*.jar --no-start --random-route

cf bs $TRADES_APP_NAME $TUTORIAL_TRADES_SERVICE_INSTANCE_NAME -c '{"role":"spanner.databaseAdmin"}'

cf start $TRADES_APP_NAME

