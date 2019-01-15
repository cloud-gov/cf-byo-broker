#!/bin/bash

set -x
set -e

. cg-customer-broker/ci/tasks/common.sh

get_route $GCP_BROKER_APP_NAME

cf csb $GCP_SERVICE_BROKER_NAME $SECURITY_USER_NAME $SECURITY_USER_PASSWORD https://$route --space-scoped
