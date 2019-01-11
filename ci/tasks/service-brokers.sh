#!/bin/bash

. cg-customer-broker/ci/tasks/common.sh

broker_name=`cf service-brokers | grep ${BROKER_APPNAME}`

if [ -z $broker_name ]; then
  echo "Could not find broker via 'cf service-brokers': Broker name = ${BROKER_APPNAME}"
  exit 1
fi
