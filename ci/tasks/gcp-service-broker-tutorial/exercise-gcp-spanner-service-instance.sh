#!/bin/bash

set -x
set -e

. cg-customer-broker/ci/tasks/common.sh

cd gcp-spanner-example-release

unzip *.zip

cf p $GCP_SPANNER_EXAMPLE_APP_NAME -p *.jar --no-start

cf bs $GCP_SPANNER_EXAMPLE_APP_NAME $TUTORIAL_GCP_SPANNER_SERVICE_INSTANCE_NAME: -c '{"role":"spanner.databaseAdmin"}'

cf start $GCP_SPANNER_EXAMPLE_APP_NAME

