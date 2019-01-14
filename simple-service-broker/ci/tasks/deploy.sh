#!/bin/bash

set +x
set -e

. cg-customer-broker/ci/tasks/common.sh

pushd broker-source
  cf push --random-route
popd
