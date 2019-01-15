#!/bin/bash
#########################################################################
#
#  This script builds the GCP Spanner tutorial application and creates
#  a zip file with the resulting jar and a Cloud Foundry manifest.yml.
#  The zip is then stored in an S3 bucket.
#
#########################################################################

set -x
set -e

cd gcp-spanner-example

#./mvnw package -DskipTests

# Make a temporary directory to use for zipping the archive and manifest
mkdir ../zip-files
#
#cp manifest.yml zip-files/.
#cp target/spring-cloud-gcp-data-spanner-sample-1.1.0.BUILD-SNAPSHOT.jar zip-files/.
#
cd ../zip-files
touch gcp-spanner-tutorial-app.zip
#jar cMf gcp-spanner-tutorial-app.zip manifest.yml spring-cloud-gcp-data-spanner-sample-1.1.0.BUILD-SNAPSHOT.jar
