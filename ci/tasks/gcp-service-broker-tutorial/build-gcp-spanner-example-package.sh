#!/bin/bash
#########################################################################
#
#  This script builds the GCP Spanner tutorial application and creates
#  a zip file with the resulting jar and a Cloud Foundry manifest.yml.
#  The zip is then stored in an S3 bucket.
#
#########################################################################

set +x
set -e

cd gcp-spanner-example

./mvnw package -DskipTests
