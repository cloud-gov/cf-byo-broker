#!/bin/bash

set +x

cf login -a $CF_API -u $CF_USER -p $CF_PWD -o $CF_ORG -s $CF_SPACE

cd stratos
./build/store-git-metadata.sh
cf push $STRATOS_APPNAME --hostname $STRATOS_HOSTNAME
