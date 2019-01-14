#!/bin/bash

set +x
set -e

. cg-customer-broker/ci/tasks/common.sh

cf t

echo $ROOT_SERVICE_ACCOUNT_JSON