# Adding a Simple Broker to Cloud Foundry

In this tutorial, we will show you how to deploy a simple service broker to a space in Cloud Foundry and make it available for use in the marketplace.

Before you begin, please be sure you are logged into a Cloud Foundry instance and targeted to an org and space.

## What is a broker?

A service broker is an application that implements a standard API, the [Open Service Broker API](https://www.openservicebrokerapi.org/). Service brokers hide the complexity of provisioning and configuring the underlying service behind a standard API. In Cloud Foundry terms, this means you can do things like create a database using a standard command `cf create-service`, rather than needing to know how to install and configure the database.

If you have used anything out of the marketplace in Cloud Foundry, you have interacted with a service broker.  But what if the service you want to use isn't in the marketplace for your Cloud Foundry?

The services you see in the marketplace are likely system-wide; brokers are installed and configured by the administrators of your Cloud Foundry. However, if you are SpaceDeveloper, you can bring your own space scoped broker. This tutorial will show you how to do this.

## Deploying a Broker as an App

A service broker is an application that implements a RESTful API, the [Open Service Broker API](https://www.openservicebrokerapi.org/). Brokers can be deployed anywhere as long as the Cloud Foundry instance (specifically the Cloud Controller) can reach it via HTTPS. Because our broker is a stateless app and Cloud Foundry is the best platform for stateless apps, we will deploy our broker as an app to Cloud Foundry.

* Download the simple-service-broker.zip and unzip it (TODO: Add zip and link). Inside is a very simple service broker written in Go along with a Cloud Foundry manifest.
* Change to the unzipped directory and use the supplied manifest to deploy the application. We can add the `--random-route` flag to push command to try to prevent route collisions.

  ```
  $ cf push --random-route
  ```

  If everything is successful you should see output similar to:

  ```
  name:              simple-service-broker
  requested state:   started
  routes:            simple-service-broker-humble-wallaby.cfapps.io
  last uploaded:     Mon 14 Jan 12:51:03 MST 2019
  stack:             cflinuxfs2
  buildpacks:        go

  type:            web
  instances:       1/1
  memory usage:    128M
  start command:   ./bin/simple-service-broker
       state     since                  cpu    memory          disk           details
  #0   running   2019-01-14T19:51:09Z   0.0%   11.2M of 128M   9.3M of 256M   
  ```


* Make note of the route created as you will need this in the next step.

> Note: We are using `random-route` to help prevent route collisions.  You should not use this feature except in development, training or CI/CD scenarios such as this. We do not recommend using `random-route` in production.

### Checking Your Work

You can verify the broker application is running with `cf apps`. You should see output similar to:

  ```
  name                    requested state   instances   memory   disk   urls
  simple-service-broker   started           1/1         128M     256M   simple-service-broker-humble-wallaby.cfapps.io
  ```

#### OPTIONAL: Accessing the Catalog

OPTIONAL: If you have `curl` (or another REST client) installed, you can access the broker's catalog via the `/v2/catalog` endpoint. This is the same endpoint used to populate the marketplace.

* You can curl your endpoint using `curl -s -u admin -H "X-Broker-API-Version: 2.14" https://<YOUR-BROKER-ROUTE>/v2/catalog`.  You will see output similar to:

  ```
  {
    "services": [
      {
        "id": "simple-service",
        "name": "simple-service",
        "description": "This service is for demonstration purposes. The same broker could advertise more than one service.",
        "bindable": true,
        "plan_updateable": false,
        "plans": [
          {
            "id": "simple-service-plan-1",
            "name": "simple-service-plan-1",
            "description": "This is plan. Plans can be used to create tiers or levels of service. For example, plans could be used to provide different amounts of cpu, memory, capacity, number of concurrent connections, network performance, etc.",
            "free": true,
            "bindable": true
          },
          {
            "id": "simple-service-plan-2",
            "name": "simple-service-plan-2",
            "description": "This is another plan. Perhaps the service instance created according this plan has more capacity or capability than simple-service-plan-1.",
            "free": true,
            "bindable": true
          }
        ],
        "metadata": {
          "displayName": "simple-service"
        }
      }
    ]
  }
  ```

Let's break down the request:

* Service Brokers in Cloud Foundry are protected by basic authentication (i.e. they require a username and password to be supplied). This broker has a default username of `admin` and password of `secret`.
  * The `-u` flag allows you to specify the username which in our case is `admin`.
  * The `-s` flag asks `curl` to prompt you for a password. `curl` does allow you to specify the password as part of the command. However if you used that flag, the password would end up in your terminal history. It is best to get in the habit of not putting passwords into commands.
* The `-H` flag allows you to specify a header and value.  The `X-Broker-API-Version` header must also be sent with the request. The value of this header is the version of the Open Service Broker API this broker supports. This is so the platform (like our Cloud Foundry instance) can verify it supports the version of the broker (in our case version `2.14`).

You will see this broker exposes a single service called `simple-service` which offers two plans (or tiers) `simple-plan-1` and `simple-plan-2`. More on this later.

> NOTE: `jq` (https://stedolan.github.io/jq/) is a very helpful utility that can parse and format JSON output. To view the output of our curl request in a more human friendly format, you can pipe the output of the `curl` into `jq`: `curl -s -u admin -H "X-Broker-API-Version: 2.14" https://<YOUR-BROKER-ROUTE>/v2/catalog | jq`

## Registering a Space Scoped Broker

Once the broker application is running, we can register it as a service broker with Cloud Foundry. If you are a Cloud Foundry admin, you can register a broker and make it available system wide. These brokers are referred to as `standard brokers`. However, if you aren't an admin you can still register a broker within a space provided you have the SpaceDeveloper role. These brokers are referred to as `space scoped brokers`

> More information on roles in Cloud Foundry is availble here: https://docs.cloudfoundry.org/concepts/roles.html.

* Use the `create-service-broker` command to register your broker with Cloud Foundry.
  * `cf create-service-broker --help` shows we need to supply the following:
    * `SERVICE_BROKER`: This is the name of the broker as referenced within Cloud Foundry.
    * `USERNAME` & `PASSWORD`: Service brokers are protected by basic authentication. This broker's default username is `admin` and password is `secret`.
    * `URL`: This is the route of your broker prefixed with `https://`.
    * `--space-scoped`: This tells Cloud Foundry to register the broker only within your space. This allows you to add any broker to your space.
  * Substituting your information, this should look something like:

    ```
    $ cf create-service-broker simple-service-broker admin secret https://<YOUR-ROUTE> --space-scoped
    ```

### Checking Your Work

At this point, your broker should be registered with Cloud Foundry.  You can check this by running via the `cf service-brokers` command.  You should see output similar to:

  ```
  Getting service brokers as sgreenberg@rscale.io...

  name            url
  simple-service-broker   https://simple-service-broker-boisterous-warthog.cfapps.io
  ```

## Using the Broker

At this point, your new service called `simple-service` should show up in the marketplace along side the other services.

> NOTE: Because this is a space scoped broker, it will only show up in the marketplace in the space or spaces which it is registered. You can register the same broker in multiple spaces.

### Viewing the Marketplace

You can see this via the CLI or using the Stratos UI.

* Run `cf m` using the CLI. You should see output similar to:

  ```
  $ cf m
  Getting services from marketplace in org 18f / space development as sgreenberg@rscale.io...
  OK

  service                         plans

  ...other services...

  simple-service                  simple-plan-1*, simple-plan-2*                                                                                    

  ...other services...

  ```



* Open your Stratos console and navigate to the marketplace.  You should see the `simple-service` listed.

You should be seeing the same service and plans as you saw accessing the broker via a browswer above. This information is populated from the same `/v2/catalog` endpoint.  

### Provisioning

The first step in using the broker is to provision an instance of the service.


This is where the broker handles the complexity of the service.  Rather than you knowing how to install and configure each service, the broker encapsulates this for you.  All you need to know is how to invoke `create-service`.


Provisioning the service asks the broker to create an instance of the service based on the selected service plan. Where a service could be the resiliency of the service. i.e. an HA version for production, or a minimal version for development.

`cf create-service my-service-broker my-ha-service-plan my-service-instance`

Behind the scenes, brokers will provision resources.  Exactly how is up the implementer of the broker.  



#### Checking Your Work

If the instance is created successfully, you should be able to see it by running `cf services`:



### Binding

Binding to the service asks the broker to provide the connection information to the application through the VCAP_SERVICE environment variable.

`cf bind-service my-app my-service-broker`

### Cleaning Up

In a service broker environment there are two distinct areas. The instances which the service broker creates and the service broker itself.
