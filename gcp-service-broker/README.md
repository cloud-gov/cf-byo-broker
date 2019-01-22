# Table of Contents
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
  * [Create a Spanner Service](#create-spanner-service)
  * [Deploy Spanner Application](#deploy-spanner-app)
* [Cleanup](#cleanup)
    
<a name="space-scoped-broker"></a>
# Adding a Space Scoped GCP Service Broker 

This tutorial walks you through the steps of adding a space scoped GCP Service Broker to Cloud Foundry  and 
then deploys an application that demonstrate how to use the Broker to access the GCP Spanner service.

<a name="gcp-setup"></a>
## GCP Setup

The first step to setting up a GCP Service Broker requires setup on the GCP side. This involves GCP project, enabling the appropriate services in
the project, creating a service, and then creating a MySQL database that will be used by the Service Broker. The following
steps guide you through this process.

<a name="project"></a>
### Setup GCP Project

1. Go to the [Google Cloud Console](https://console.cloud.google.com) and sign up, walking through the setup wizard.
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

<a name="deploy-app"></a>
### Service Broker Application Deployment and Registration

Now that the database is setup, you are ready to deploy the Service Broker as an application to Cloud Foundry.

The first step to installing the GCP Service Broker is cloning the github repository where the source of the broker
resides. Clone this repository into a working directory and then change to the directory to the clone repo.

\> git clone https://github.com/GoogleCloudPlatform/gcp-service-broker.git
\> cd gcp-service-broker


Add these to the `env` section of `manifest.yml`

* `ROOT_SERVICE_ACCOUNT_JSON` - the string version of the credentials file created for the Owner level Service Account.
* `SECURITY_USER_NAME` - the username to authenticate broker requests - the same one used in `cf create-service-broker` below.
* `SECURITY_USER_PASSWORD` - the password to authenticate broker requests - the same one used in `cf create-service-broker` below.
* `DB_HOST` - the host for the database to back the service broker.
* `DB_USERNAME` - the database username for the service broker to use.
* `DB_PASSWORD` - the database password for the service broker to use.

Now that the `manifest.yml` is ready, it is time to push the application to Cloud Foundry and register it as a 
Service Broker.

1. `cf p`  # Take note of the URL. It is used in the next command.
1. `cf create-service-broker gcp-spanner-service-broker <username> <password> <service broker app url> --space-scoped`

<b>Checking your work</b>
Once the broker is installed, the services will be available in the marketplace. Executing the marketplace command shows the GCP service are now available. 
There are a large number of available services. For the sake of brevity, ellipses are used to demonstrate a large list.

\> `cf marketplace`

```
...

google-bigquery                 default    A fast, economical and fully managed data warehouse for large-scale data analytics.

...

google-spanner                  sandbox, minimal-production

...
```

<a name="cloud-foundry-setup"></a>
## Cloud Foundry Setup
With the GCP setup complete, we now direct our attention to setting up the Service Broker within Cloud Foundry. For 
this tutorial that involves deploying the GCP Service Broker as an application and then registering that application as a
Service Broker with Cloud Foundry. 

Then we excercise the service broker by create a GCP Spanner service and deploying an example application that uses
the service.

<a name="create-spanner-service"></a>
### Create a Spanner Service

\> `cf create-servcie google-spanner sandbox trades-spanner -c '{"name":"auth-database"}'`

<b>Checking your work</b>
Once the service has been create, executing the `services` command shows it as an available service in the space.

\> `cf services`

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

Create a working directory, copy the trades.zip to the directory, and expand the zip file.

\> mkdir trades-working
\> cd trades-working
\> cp ~/Downloads/trades.zip
\> unzip trades.zip

The next step is to deploy the application. Do not start the application yet. You'll need to bind the service to the 
application and then it'll be ready to start.

\> `cf p --nostart`

The Trades application uses a `random-route` when deploying the application. Take note of the application url.

Now you are ready to bind the service to the application. Binding the service adds the required connection information 
to the application `VCAP_SERVICES` environment variable.

\> `cf bs trades gcpspanner -c '{"role":"spanner.databaseAdmin"}'`

<b>Checking your work</b>

If the service is properly bound, you'll see a `google-spanner` section in the `VCAP_SERVICES` environment variable.

\> `$ cf env trades`

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

\> `cf start trades`

<b>Checking your work</b>
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

\> `cf d trades`


* Delete the service instance.

\> `cf ds trades-spanner`

* Delete the service broker.

\> `cf delete-service-broker gcp-spanner-service-broker`

* Delete the GCP Service Broker application.

\> `cf d gcp-service-broker`

<b>Checking your work</b>

Running `cf a` should show the Trades and GCP Service Broker applications are
no longer deployed.

Running `cf s` should show the service no longer exists.

Running `cf service-brokers` should show the service broker no longer exists.
