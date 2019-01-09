# Adding a Custom Broker to Cloud Foundry

## What is a broker?

A service broker is an application that implements a standard API, the [Open Service Broker API](https://www.openservicebrokerapi.org/). Service brokers hide the complexity of provisioning and configuring the underlying service behind a standard API. In Cloud Foundry terms, this means you can do things like create a database using a standard command `cf create-service`, rather than needing to know how to install and configure the database.

If you have used anything out of the marketplace in Cloud Foundry, you have interacted with a service broker.  But what if the service you want to use isn't in the marketplace for your Cloud Foundry?

The services you see in the marketplace are likely system-wide; brokers are installed and configured by the administrators of your Cloud Foundry. However, if you are SpaceDeveloper, you can bring your own space scoped broker. This tutorial will show you how to do this.

## Deploying a Broker as an App


## Creating a Space Scoped Broker

### Register

### Viewing in the Marketplace

## Using the Broker

### Provisioning

### Binding

### Cleaning Up
