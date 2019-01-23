# Table of Contents
* [Prerequisites](#prerequisites)
* [GCP Setup](#gcp-setup)
  * [Setup GCP Project](#project)
  * [Enable APIs](#apis)
  * [Create Root Service Account](#service-account)
  * [Setup Backing Database](#database-setup)
    * [Create MySQL Instance](#create-mysql-instance)
    * [Allow Access Externally](#external-db-access)
    * [Create Database](#create-db)
* [Cloud Foundry Setup](#cloud-foundry-setup)
  * [Service Broker Application Deployment and Registration](#deploy-app)
    * [Checking Your Work](#check-create-service-broker)
  * [Create a Spanner Service](#create-spanner-service)
    * [Check Your Work](#check-spanner-service)
  * [Deploy Spanner Application](#deploy-spanner-app)
    * [Check Your Work - Bind](#check-bind-service)
    * [Check Your Work - Trades App Deploy](#check-trades-app-deploy)
* [Cleanup](#cleanup)


<a name="space-scoped-broker"></a>
# Adding a Space Scoped GCP Service Broker 

This tutorial walks you through the steps of adding a space scoped GCP Service Broker to Cloud Foundry  and 
then deploys an application demonstrating how to use the Broker to access the GCP Spanner service. 

<a name="prerequisites"></a>
## Prerequisites

* A working knowledge of the [Cloud Foundry CLI](https://docs.cloudfoundry.org/cf-cli/).
* A working knowledge of Space Scoped Service Brokers. For an excellent introduction, 
see the [Simple Service Broker Tutorial](https://github.com/resilientscale/cg-customer-broker/tree/master/simple-service-broker)
* An account to a Cloud Foundry instance. A free account can be established at [Pivotal Web Services](https://run.pivotal.io/).
* A [Google Cloud Platform (GCP) account](https://accounts.google.com/).
* Please be sure you are logged into a Cloud Foundry instance and targeted to an org and space.

<a name="gcp-setup"></a>
## GCP Setup

The first step to setting up a GCP Service Broker requires setup on the GCP side. It is assumed you have already setup a 
GCP account. The steps in this section walk you through setting up a project that will be used by the Service Broker. This 
involves  enabling the appropriate services in the project, creating a service account, and creating a MySQL database 
that will be used by the Service Broker as a backing store.

<a name="project"></a>
### Create GCP Project

The first task is to create the project that will be used by the Service Broker.

1. Go to the [Google Cloud Console](https://console.cloud.google.com).
1. Next to the Google Cloud Platform logo in the upper left-hand corner, click the dropdown. In the popup, select "New Project"
in the upper right.
1. Give your project a name and click "Create".
1. A notification in the upper right indicates when the project is created. Refresh the page.
1. You may need to select the newly created project from the project drop down in the upper left.

<a name="api"></a>
### Enable APIs

Enable the following services in **[APIs & Services > Library](https://console.cloud.google.com/apis/library)**.

1. Enable the [Google Cloud Resource Manager API](https://console.cloud.google.com/apis/api/cloudresourcemanager.googleapis.com/overview)
1. Enable the [Google Identity and Access Management (IAM) API](https://console.cloud.google.com/apis/api/iam.googleapis.com/overview)
1. Enable the [Cloud Spanner API](https://console.cloud.google.com/apis/library/spanner.googleapis.com?q=spanner)

<a name="service-account"></a>
### Create Root Service Account

A root service account is used by the Service Broker to access the GCP project. In this section you will create
the root service account and download a JSON document with the corresponding connection information. This JSON doc
will be used by the Service Broker to connect to the GCP project in a later section.

1. From the GCP console, navigate to **IAM & Admin > Service accounts** and click **Create Service Account**.
1. Enter a **Service account name**.
1. In the **Project Role** dropdown, choose **Project > Owner**.
1. Select the checkbox to **Furnish a new Private Key**, make sure the **JSON** key type is specified.
1. Click **Save** to create the account, key and grant it the owner permission.
1. Save the automatically downloaded key file to a secure location.

<a name="database-setup"></a>
### Setup Backing Database

The GCP Service Broker stores the state of provisioned resources in a MySQL database. This will created using
the Cloud SQL service.

<a name="create-mysql-instance"></a>
#### Create MySQL Instance

1. In the GCP console, select "Marketplace" from the dropdown in the upper right.
1. Enter "MySQL" in the search box.
1. Select "Cloud SQL" in the results.
1. Select the "GO TO CLOUD SQL" button.
1. Select the "Create Instance" button.
1. Select the "MySQL" radio button.
1. Select the "Choose Second Generation" button.
1. Give you instance a name and root password.
1. Select the "Create" button.
1. Select the "Next" button.

<a name="external-db-access"></a>
#### Allow Access Externally

By default the database cannot be accessed by external IPs. These next steps open the database to external access.

1. Select the newly created instance from the list, which brings you to the "Instance details".
1. Select the "Connections" tab.
1. Select the "+ Add network" push button.
1. For "Network" enter, `0.0.0.0/0`
1. Select the "Done" button.

<a name="create-db"></a>
#### Create Database

Now that the instance has been created, it's time to the Service Broker database within the instance. The following 
steps use Google's Cloud Shell to connect to the MySQL instance to create the required database and user that the
broker will use to connect.

1. Select the "Overview" tab.
1. In the "Connect to this instance" section, select "Connect using Cloud Shell".
1. If an introduction dialog displays, click through it.
1. You'll be taken to a command prompt that already has the proper command to connect to the instance. 
Just press "Return".
1. Wait for your shell to be whitelisted.
1. Run `CREATE DATABASE servicebroker;`
1. Run `CREATE USER '<username>'@'%' IDENTIFIED BY '<password>';`. Be sure to remember the username and password!
1. Run `GRANT ALL PRIVILEGES ON servicebroker.* TO '<username>'@'%' WITH GRANT OPTION;`
1. Exit from the shell.

<a name="cloud-foundry-setup"></a>
## Cloud Foundry Setup
With the GCP setup complete, we now direct our attention to setting up the Service Broker within Cloud Foundry. For 
this tutorial that involves deploying the GCP Service Broker as an application and then registering that application as a
Service Broker with Cloud Foundry. 
<a name="deploy-app"></a>

### Service Broker Application Deployment and Registration

The first step to setting up the Cloud Foundry portions is to deploy the  Service Broker as an application.
This involves cloning the github repository where the source of the broker resides, modifying the manifest.yml with information
corresponding to your GCP project, and then pushing the application to CF.

  ```
  $ git clone https://github.com/GoogleCloudPlatform/gcp-service-broker.git
  $ cd gcp-service-broker
  ```

Add these to the `env` section of `manifest.yml`

* `ROOT_SERVICE_ACCOUNT_JSON` - the string version of the credentials file created for the Owner level Service Account.
* `SECURITY_USER_NAME` - the username to authenticate broker requests - this will be used in the `cf create-service-broker` below.
* `SECURITY_USER_PASSWORD` - the password to authenticate broker requests - this will be used in the `cf create-service-broker` below.
* `DB_HOST` - the host for the database to back the service broker.
* `DB_USERNAME` - the database username for the service broker to use.
* `DB_PASSWORD` - the database password for the service broker to use.

Now that the `manifest.yml` is ready, it is time to push the application to Cloud Foundry and register it as a 
Service Broker.

* Deploy the Service Broker Application to Cloud Foundry.

  ```
  $ cf p  # Take note of the URL. It is used in the next command.
  ```
 
  If everything is successful you should see output similar to:
 
  ```
  name:              gcp-service-broker
  requested state:   started
  routes:            gcp-service-broker.cfapps.io
  last uploaded:     Wed 23 Jan 07:46:57 MST 2019
  stack:             cflinuxfs2
  buildpacks:        go
   
  type:            web
  instances:       1/1
  memory usage:    1024M
  start command:   gcp-service-broker
       state     since                  cpu    memory    disk      details
  #0   running   2019-01-23T14:47:15Z   0.0%   0 of 1G   0 of 1G   
  ```

* Register the above application as a service broker with Cloud Foundry.
   
  ```
  $ cf create-service-broker gcp-spanner-service-broker <username> <password> <service broker app url> --space-scoped
  ```
  
  If everything is successful you should see output similar to:
  
  ```
  Creating service broker gcp-spanner-service-broker in org 18f / space development as steve.wall@primetimesoftware.com...
  OK
  ```

<a name="check-create-service-broker"></a>
#### Check Your Work
Once the broker is installed, the services will be available in the marketplace. Use `cf marketplace` to list the 
services in the marketplace. Executing the marketplace command should show the GCP services are now available. 
There are a large number of available services. For the sake of brevity, ellipses are used to demonstrate a large list.


  ```
  ...
    
  google-bigquery                 default    A fast, economical and fully managed data warehouse for large-scale data analytics.
    
  ...
    
  google-spanner                  sandbox, minimal-production
    
  ...
  ```

Then we exercise the service broker by create a GCP Spanner service and deploying the `trades` example application that 
uses the service.

<a name="create-spanner-service"></a>
### Create a Spanner Service

* Create the Spanner service that will be used by the `trades` application.

  ```
  $ cf create-service google-spanner sandbox trades-spanner -c '{"name":"auth-database"}'
  ```
  
  If everything is successful you should see output similar to:
  
  ```
  Creating service instance trades-spanner in org 18f / space development as steve.wall@primetimesoftware.com...
  OK
  
  Create in progress. Use 'cf services' or 'cf service trades-spanner' to check operation status.
  
  Attention: The plan `sandbox` of service `google-spanner` is not free.  The instance `trades-spanner` will incur a cost.  Contact your administrator if you think this is in error.
  ```

<a name="check-spanner-service"></a>
#### Check Your Work
Once the service has been create, executing the `cf services` command shows it as an available service in the space.

```$ cf services
Getting services in org 18f / space development as steve.wall@primetimesoftware.com...

name             service                 plan                bound apps           last operation
trades-spanner   google-spanner          sandbox             trades               create succeeded
```

<a name="deploy-spanner-app"><a>
### Deploy Spanner Application

Now it is time to deploy an application to use the Spanner service. The first step is to copy the example application 
and associated manifest.yml. For this, you will use the 
[Trades](https://github.com/primetimesoftware/trades) example Spanner applications.

Navigate to the [Trades release page](https://github.com/primetimesoftware/trades/releases) and download the latest 
trades.zip release.

Create a working directory, copy the trades.zip to the directory, and expand the zip file. For example:

  ```
  $ mkdir trades-working
  $ cd trades-working
  $ cp ~/Downloads/trades.zip
  $ unzip trades.zip
  ```

The next step is to deploy the application. Do not start the application yet. You'll need to bind the service to the 
application and then it'll be ready to start.

```
$ `cf p --no-start`
```

  If everything is successful you should see output similar to:
  
```
name:              trades
requested state:   stopped
routes:            trades-daring-platypus.cfapps.io
last uploaded:     
stack:             
buildpacks:        

type:           web
instances:      0/1
memory usage:   1024M
     state   since                  cpu    memory   disk     details
#0   down    2019-01-23T15:40:45Z   0.0%   0 of 0   0 of 0   
```

The Trades application uses a `random-route` when deploying the application. Take note of the application url.

> Note: We are using `random-route` to help prevent route collisions.  You should not use this feature except in development, 
training or CI/CD scenarios such as this. We do not recommend using `random-route` in production.

Now you are ready to bind the service to the application. Binding the service adds the required connection information 
to the application `VCAP_SERVICES` environment variable.

```
$ `cf bs trades trades-spanner -c '{"role":"spanner.databaseAdmin"}'`
```

  If everything is successful you should see output similar to:

```
Binding service trades-spanner to app trades in org 18f / space development as steve.wall@primetimesoftware.com...
OK
TIP: Use 'cf restage trades' to ensure your env variable changes take effect
```

<a name="check-bind-service></a>
#### Check your work

To verify your work use the `cf env trades` command. If the service is properly bound, you'll see a `google-spanner` 
section in the `VCAP_SERVICES` environment variable.

```
Getting env variables for app trades-lemur in org 18f / space development as steve.wall@primetimesoftware.com...
OK

System-Provided:
{
 "VCAP_SERVICES": {
  "google-spanner": [
   {
    "binding_name": null,
    "credentials": {
     "Email": "pcf-binding-debc921f@microp.iam.gserviceaccount.com",
     "Name": "pcf-binding-debc921f",
     "PrivateKeyData": "a really long private key",
     "ProjectId": "microp",
     "UniqueId": "112542272797442861821",
     "instance_id": "auth-database"
    },
    "instance_name": "gcpspanner",
    "label": "google-spanner",
    "name": "gcpspanner",
    "plan": "sandbox",
    "provider": null,
    "syslog_drain_url": null,
    "tags": [
     "gcp",
     "spanner"
    ],
    "volume_mounts": []
   }
  ]
 }
}
```

Once the service is successfully bound, it is time to start the application.

```
$ `cf start trades`
```

  If everything is successful you should see output similar to:

```
name:              trades
requested state:   started
routes:            trades-daring-platypus.cfapps.io
last uploaded:     Wed 23 Jan 08:46:03 MST 2019
stack:             cflinuxfs2
buildpacks:        client-certificate-mapper=1.8.0_RELEASE container-security-provider=1.16.0_RELEASE
                   java-buildpack=v4.17.1-offline-https://github.com/cloudfoundry/java-buildpack.git#47e68da
                   java-main java-opts java-security jvmkill-agent=1.16.0_RELEASE open-jd...

type:            web
instances:       1/1
memory usage:    1024M
start command:   JAVA_OPTS="-agentpath:$PWD/.java-buildpack/open_jdk_jre/bin/jvmkill-1.16.0_RELEASE=printHeapHistogram=1
                 -Djava.io.tmpdir=$TMPDIR -XX:ActiveProcessorCount=$(nproc)
                 -Djava.ext.dirs=$PWD/.java-buildpack/container_security_provider:$PWD/.java-buildpack/open_jdk_jre/lib/ext
                 -Djava.security.properties=$PWD/.java-buildpack/java_security/java.security $JAVA_OPTS" &&
                 CALCULATED_MEMORY=$($PWD/.java-buildpack/open_jdk_jre/bin/java-buildpack-memory-calculator-3.13.0_RELEASE
                 -totMemory=$MEMORY_LIMIT -loadedClasses=17853 -poolType=metaspace -stackThreads=250
                 -vmOptions="$JAVA_OPTS") && echo JVM Memory Configuration: $CALCULATED_MEMORY && JAVA_OPTS="$JAVA_OPTS
                 $CALCULATED_MEMORY" && MALLOC_ARENA_MAX=2 SERVER_PORT=$PORT eval exec
                 $PWD/.java-buildpack/open_jdk_jre/bin/java $JAVA_OPTS -cp $PWD/.
                 org.springframework.boot.loader.JarLauncher
     state     since                  cpu      memory         disk           details
#0   running   2019-01-23T15:46:36Z   151.8%   192.5M of 1G   163.5M of 1G   
```
<a name="check-trades-app-deploy"></a>
#### Checking your work
To check the application deployed correctly, access the `trades` endpoint from a browser.

https://<app url>/trades

This should return the following json document.

```
{
  "_embedded" : {
    "trades" : [ {
      "tradesId" : "demo_trades1",
      "firstName" : "John",
      "lastName" : "Doe",
      "_links" : {
        "self" : {
          "href" : "https://trades-lemur.cfapps.io/trades/demo_trades1"
        },
        "trades" : {
          "href" : "https://trades-lemur.cfapps.io/trades/demo_trades1"
        }
      }
    }, {
      "tradesId" : "demo_trades2",
      "firstName" : "Mary",
      "lastName" : "Jane",
      "_links" : {
        "self" : {
          "href" : "https://trades-lemur.cfapps.io/trades/demo_trades2"
        },
        "trades" : {
          "href" : "https://trades-lemur.cfapps.io/trades/demo_trades2"
        }
      }
    }, {
      "tradesId" : "demo_trades3",
      "firstName" : "Scott",
      "lastName" : "Smith",
      "_links" : {
        "self" : {
          "href" : "https://trades-lemur.cfapps.io/trades/demo_trades3"
        },
        "trades" : {
          "href" : "https://trades-lemur.cfapps.io/trades/demo_trades3"
        }
      }
    } ]
  },
  "_links" : {
    "self" : {
      "href" : "https://trades-lemur.cfapps.io/trades{?page,size,sort}",
      "templated" : true
    },
    "profile" : {
      "href" : "https://trades-lemur.cfapps.io/profile/trades"
    }
  },
  "page" : {
    "size" : 20,
    "totalElements" : 3,
    "totalPages" : 1,
    "number" : 0
  }
}
```

<a name="cleanup"></a>
## Cleanup

Through the course of the tutorial, there were several things created in your CF space. We don't have to leave things
hanging around consuming resources, so now it's time to cleanup! This essentially involves deleting the items that were
created in reverse order.

* Delete the Trades application.

$ `cf d trades`

* Delete the service instance.

$ `cf ds trades-spanner`

* Delete the service broker.

$ `cf delete-service-broker gcp-spanner-service-broker`

* Delete the GCP Service Broker application.

$ `cf d gcp-service-broker`

<b>Checking your work</b>

Running `cf a` should show the Trades and GCP Service Broker applications are
no longer deployed.

Running `cf s` should show the service no longer exists.

Running `cf service-brokers` should show the service broker no longer exists.
