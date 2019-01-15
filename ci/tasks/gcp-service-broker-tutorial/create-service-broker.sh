#!/bin/bash

set +x
set -e

. cg-customer-broker/ci/tasks/common.sh

GCP_SERVICE_BROKER_ROUTE=get_route $GCP_BROKER_APP_NAME

echo "route $GCP_SERVICE_BROKER_ROUTE"

#cf csb $GCP_SERVICE_BROKER_NAME $SECURITY_USER_NAME $SECURITY_USER_PASSWORD $GCP_SERVICE_BROKER_ROUTE --space-scoped
