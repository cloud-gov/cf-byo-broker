
set +x
set -e

. cg-customer-broker/ci/tasks/common.sh

cf d -f $GCP_BROKER_APP_NAME  || echo "App could not be deleted: ${BROKER_APPNAME}"
