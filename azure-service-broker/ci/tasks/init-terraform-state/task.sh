#!/bin/bash

set -eux

# az login --service-principal --username ${AZURE_CLIENT_ID} --password ${AZURE_CLIENT_SECRET} --tenant ${AZURE_TENANT_ID}

# az account set --subscription ${AZURE_SUBSCRIPTION_ID}

blobs=$(az storage blob list -c ${CONTAINER})
files=$(echo "$blobs" | jq -r .[].name)

set +e
echo ${files} | grep terraform.tfstate
if [ "$?" -gt "0" ]; then
  echo "{\"version\": 3}" > terraform.tfstate
  az storage blob upload -c ${CONTAINER} -n terraform.tfstate -f terraform.tfstate
  set +x
  if [ "$?" -gt "0" ]; then
    echo "Failed to upload empty tfstate file"
    exit 1
  fi
  set -x
  az storage blob snapshot -c ${CONTAINER} -n terraform.tfstate
  set +x
  if [ "$?" -gt "0" ]; then
    echo "Failed to create snapshot of tfstate file"
    exit 1
  fi
else
  echo "terraform.tfstate file found, skipping"
  exit 0
fi