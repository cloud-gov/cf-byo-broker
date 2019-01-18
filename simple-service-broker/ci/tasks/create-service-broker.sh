#!/bin/bash

set +x
set -e

. cg-customer-broker/ci/tasks/common.sh

broker_route="$(get_route $BROKER_APPNAME)"

cf create-service-broker ${BROKER_APPNAME}-${CF_ORG}-${CF_SPACE} ${BROKER_USERNAME} ${BROKER_PASSWORD} https://${broker_route} --space-scoped
