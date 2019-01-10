# Adding a Custom Broker to Cloud Foundry

## What is a broker?

A service broker is an application that implements a standard API, the [Open Service Broker API](https://www.openservicebrokerapi.org/). Service brokers hide the complexity of provisioning and configuring the underlying service behind a standard API. In Cloud Foundry terms, this means you can do things like create a database using a standard command `cf create-service`, rather than needing to know how to install and configure the database.

If you have used anything out of the marketplace in Cloud Foundry, you have interacted with a service broker.  But what if the service you want to use isn't in the marketplace for your Cloud Foundry?

The services you see in the marketplace are likely system-wide; brokers are installed and configured by the administrators of your Cloud Foundry. However, if you are SpaceDeveloper, you can bring your own space scoped broker. This tutorial will show you how to do this.

## Deploying a Broker as an App

Deploying a broker as an application is the same as deploying any application to Cloud Foundry. It is just a `cf push`.

Ex. `cf push my-service-broker`

## Registering a Space Scoped Broker

Once the broker application is running, it is time to register it as a service broker with Cloud Foundry. This is done using `cf create-service-broker` with the `--space-scope` options.

Ex. `cf create-service-broker my-service-broker some-username some-password https://my-service-broker.somedomain.com`

### Viewing in the Marketplace

Registering the service broker with Cloud Foundry adds it to the marketplace. The marketplace is the services available to an application. Executing `cf marketplace` displays a list of the services. Since the service broker that was just added is a spaced scoped broker, this will only show up in the marketplace if you are targeted at the appropriate space.

## Using the Broker

The first step in using the broker is to provision an instance of the service, then bind the application to the service instance.

### Provisioning

Provisioning the service asks the broker to create an instance of the service based on a given service plan. Where a service could be the resiliency of the service. i.e. an HA version for production, or a minimal version for development.

`cf create-service my-service-broker my-ha-service-plan my-service-instance`

### Binding

Binding to the service asks the broker to provide the connection information to the application through the VCAP_SERVICE environment variable.

`cf bind-service my-app my-service-broker`

### Cleaning Up

In a service broker environment there are two distinct areas. The instances which the service broker creates and the service broker itself. 