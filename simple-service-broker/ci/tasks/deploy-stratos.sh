#!/bin/bash

set +x
set -e

. cg-customer-broker/ci/tasks/common.sh

cd stratos
./build/store-git-metadata.sh
cf push ${STRATOS_APPNAME} --hostname ${STRATOS_HOSTNAME}
