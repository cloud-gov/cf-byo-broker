# Adding a Space Scoped GCP Service Broker 

This tutorial walks you through the steps of adding the GCP Service Broker to a Cloud Foundry space and then deploys an application to demonstrate how to use the Broker to access the GCP Spanner service.

## Broker Installation

## Create Spanner Service

`cf cs google-spanner sandbox gcpspanner -c '{"name":"auth-database"}'`

<b>Checking your work</b>

`cf m`

## Deploy Spanner Application

`git clone https://<spanner example>`

`cf p --nostart`

`cf bs spanner-sample-<unique id> gcpspanner -c '{"role":"spanner.databaseAdmin"}'`

`cf st spanner-sample-<unique id>`

<b>Checking your work</b>