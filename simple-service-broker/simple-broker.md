# Adding a Simple Broker to Cloud Foundry

In this tutorial, we will show you how to deploy a simple service broker to a space in Cloud Foundry and make it available for use in the marketplace.

Before you begin, please be sure you are logged into a Cloud Foundry instance and targeted to an org and space.

## What is a broker?

A service broker is an application that implements a standard API, the [Open Service Broker API](https://www.openservicebrokerapi.org/). Service brokers hide the complexity of provisioning and configuring the underlying service behind a standard API. In Cloud Foundry terms, this means you can do things like create a database using a standard command `cf create-service`, rather than needing to know how to install and configure the database.

If you have used anything out of the marketplace in Cloud Foundry, you have interacted with a service broker.  But what if the service you want to use isn't in the marketplace for your Cloud Foundry?

The services you see in the marketplace are likely system-wide; brokers are installed and configured by the administrators of your Cloud Foundry. However, if you are SpaceDeveloper, you can bring your own space scoped broker. This tutorial will show you how to do this.

## Deploying a Broker as an App

A service broker is an application that implements a RESTful API, the [Open Service Broker API](https://www.openservicebrokerapi.org/). Brokers can be deployed anywhere as long as the Cloud Foundry instance (specifically the Cloud Controller) can reach it. Because our broker is a stateless app and Cloud Foundry is the best platform for stateless apps, we will deploy our broker as an app to Cloud Foundry.

* Download the simple-service-broker.zip and unzip it (TODO: Add zip and link). Inside is a jar file (the application) and a manifest.
* Change to the unzipped directory and use the supplied manifest to deploy the application.

  ```
  $ cf push -f simple-service-broker_manifest.yml
  ```

  If everything is successful you should see output similar to:

  ```
  name:              simple-service-broker
  requested state:   started
  routes:            simple-service-broker-boisterous-warthog.cfapps.io
  last uploaded:     Thu 10 Jan 12:37:49 MST 2019
  stack:             cflinuxfs2
  buildpacks:        java_buildpack

  type:            web
  instances:       1/1
  memory usage:    750M
  start command:   JAVA_OPTS="-agentpath:$PWD/.java-buildpack/open_jdk_jre/bin/jvmkill-1.16.0_RELEASE=printHeapHistogram=1 -Djava.io.tmpdir=$TMPDIR
                   -Djava.ext.dirs=$PWD/.java-buildpack/container_security_provider:$PWD/.java-buildpack/open_jdk_jre/lib/ext
                   -Djava.security.properties=$PWD/.java-buildpack/java_security/java.security $JAVA_OPTS" &&
                   CALCULATED_MEMORY=$($PWD/.java-buildpack/open_jdk_jre/bin/java-buildpack-memory-calculator-3.13.0_RELEASE -totMemory=$MEMORY_LIMIT -loadedClasses=15147
                   -poolType=metaspace -stackThreads=250 -vmOptions="$JAVA_OPTS") && echo JVM Memory Configuration: $CALCULATED_MEMORY && JAVA_OPTS="$JAVA_OPTS $CALCULATED_MEMORY"
                   && MALLOC_ARENA_MAX=2 SERVER_PORT=$PORT eval exec $PWD/.java-buildpack/open_jdk_jre/bin/java $JAVA_OPTS -cp $PWD/. org.springframework.boot.loader.JarLauncher
       state     since                  cpu    memory      disk      details
  #0   running   2019-01-10T19:38:07Z   0.0%   0 of 750M   0 of 1G   
  ```


* Make note of the route created as you will need this in the next step.

> Note: The supplied manifest uses `random-route` to help prevent route collisions.  You should not use this feature except in training scenarios such as this.

### Checking Your Work

With the broker running, you should be able to query it using a browser. We can access the `/v2/catalog` endpoint which is the same endpoint used by Cloud Foundry to populate the marketplace.

Service Brokers in Cloud Foundry are protected by basic authentication (i.e. they require a username and password to be supplied). This broker has a default username of `admin` and password of `secret`.

* In a browser, access https://<YOUR-BROKER-ROUTE>/v2/catalog. Supplied the username and password above when prompted. You should see output similar to:

  ```
  {
    "services": [
      {
        "id": "simple-service",
        "name": "simple-service",
        "description": "This service is for demonstration purposes. The same broker could advertise more than one service.",
        "bindable": true,
        "plan_updateable": false,
        "instances_retrievable": false,
        "bindings_retrievable": false,
        "plans": [
          {
            "id": "simple-plan-1",
            "name": "simple-plan-1",
            "description": "This is plan. Plans can be used to create tiers or levels of service. For example, plans could be used to provide different amounts of cpu, memory, capacity, number of concurrent connections, network performance, etc.",
            "metadata": {},
            "bindable": false,
            "free": false
          },
          {
            "id": "simple-plan-2",
            "name": "simple-plan-2",
            "description": "This is another plan. Perhaps the service instance created according this plan has more capacity or capability than plan1.",
            "metadata": {},
            "bindable": false,
            "free": false
          }
        ],
        "tags": [
          "demo"
        ],
        "metadata": {},
        "requires": []
      }
    ]
  }
  ```

You will see this broker exposes a single service called `simple-service` which offers two plans (or tiers) `simple-plan-1` and `simple-plan-2`. More on this later.

> NOTE: Browser extensions such as JSONView (https://chrome.google.com/webstore/detail/jsonview/chklaanhfefbnpoihckbnefhakgolnmc) can be helpful in formatting JSON output such as that returned from service brokers.

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
    $ cf create-service-broker simple-broker admin secret https://<YOUR-ROUTE> --space-scoped
    ```

### Checking Your Work

At this point, your broker should be registered with Cloud Foundry.  You can check this by running via the `cf service-brokers` command.  You should see output similar to:

  ```
  Getting service brokers as sgreenberg@rscale.io...

  name            url
  simple-broker   https://simple-service-broker-boisterous-warthog.cfapps.io
  ```

### Viewing in the Marketplace

At this point you should see the service offering listed in the marketplace.

* Run `cf m`. You should see output similar to:

  ```
  $ cf m
  Getting services from marketplace in org 18f / space development as sgreenberg@rscale.io...
  OK

  service                         plans

  ...other services...

  simple-service                  simple-plan-1*, simple-plan-2*                                                                                    

  ...other services...

  ```

  Since the service broker that was just added is a spaced scoped broker, this will only show up in the marketplace if you are targeted at the appropriate space.

If you have the Stratos UI available to you, you can also see the marketplace via Stratos.

* 


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
