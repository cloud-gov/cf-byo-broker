#!/bin/bash

set +x
set -e

cf login -a $CF_API -u $CF_USER -p $CF_PWD -o $CF_ORG -s $CF_SPACE

cf delete -f -r $STRATOS_APPNAME || echo "${STRATOS_APPNAME} could not be deleted"
