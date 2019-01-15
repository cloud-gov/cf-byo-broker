#!/bin/bash

set +x
set -e

. cg-customer-broker/ci/tasks/common.sh

cf delete -f $STRATOS_APPNAME || echo "App could not be deleted: ${STRATOS_APPNAME}"
