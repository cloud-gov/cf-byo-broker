#!/bin/bash

cf_login() {
  # For testing on pcfdev
  if $CF_SKIP_SSL; then
    SKIP_SSL="--skip-ssl-validation"
  else
    SKIP_SSL=""
  fi

  cf login -a $CF_API -u $CF_USER -p $CF_PWD -o $CF_ORG -s $CF_SPACE $SKIP_SSL
}

cf target | grep -q "User:" || cf_login

get_route() {
  guid=` cf app $1 --guid`
  route=`cf curl /v2/apps/${guid}/env | jq -r '.application_env_json.VCAP_APPLICATION.application_uris[0]'`
  echo ${route}
}

get_service_broker_name() {
  echo "${BROKER_APPNAME}-${CF_ORG}-${CF_SPACE}"
}
