#!/bin/bash

set -x
set -e

. cg-customer-broker/ci/tasks/common.sh

cd gcp-service-broker

cat <<EOF
stuff
EOF > manifest.yml

cat manifest.yml