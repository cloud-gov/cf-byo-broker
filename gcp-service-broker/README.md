# Google Spanner Service Broker

This tutorial shows you how to deploy the Google Cloud Platform (GCP) service broker to a space on Cloud Foundry. It includes a sample application that will connect to a Google Spanner instance provisioned by the broker.

**Table of Contents**

* [Prerequisites](#prerequisites)
* [GCP Setup](#gcp-setup)
  * [Setup GCP Project](#create-gcp-project)
  * [Enable APIs](#enable-apis)
  * [Create Root Service Account](#create-root-service-account)
  * [Service Broker Database](#service-broker-database)
    * [Provision MySQL](#provision-mysql)
    * [Allow Database Access](#allow-database-access)
    * [Create Database and User](#create-database-and-user)
  * [GCP Setup Recap](#gcp-setup-recap)
* [Deploying the Broker](#deploying-the-broker)
  * [Cloning](#cloning)
  * [Configuring](#configuring)
  * [Pushing](#pushing)
  * [Registering](#registering)
  * [The Marketplace](#the-marketplace)
* [Using Spanner with a Sample Application](#using-spanner-with-a-sample-application)
  * [Deploying the Trades Application](#deploying-the-trades-application)
  * [Creating and Binding](#creating-and-binding)
  * [Accessing the Trades App](#accessing-the-trades-app)
* [Conclusion](#conclusion)
  * [Cleaning Up](#cleaning-up)

## Prerequisites

In order to complete the tutorial, please be sure you have:

* A [Google Cloud Platform (GCP) account](https://accounts.google.com/).
* A working knowledge of Cloud Foundry with experience using the [CLI](https://docs.cloudfoundry.org/cf-cli/).
* A working knowledge of space-scoped service brokers. For an  introduction, see the [Simple Service Broker Tutorial](../simple-service-broker).
* A Cloud Foundry account and a space to deploy apps.  You need the `SpaceDeveloper` role in the space.

## GCP Setup

The GCP service broker will provision and manipulate resources in your Google Cloud Platform project. This section shows you how to create and configure a project that will be used by the service broker.

### Create GCP Project

The first task is to create the project that will be used by the service broker. In GCP, projects form the basis for creating, enabling, and using all GCP services.

1. Sign in to your GCP account: [Google Cloud Console](https://console.cloud.google.com).
1. Next to the Google Cloud Platform logo in the upper left-hand corner, click the dropdown. In the popup, select `New Project`.
in the upper right.
1. Give your project a name and click `CREATE`.
1. A notification in the upper right indicates when the project is created. Refresh the page.
1. You may need to select the newly created project from the project drop down in the upper left once it is created.

### Enable APIs

The service broker utilizes APIs to provision and manipulate resources. By default, APIs are not enabled when you create a project.  

The following services are required for the broker to provision and manipulate Spanner instances.

1. In the left hand navigation bar, select `APIs & Services` > `Library`.
1. Enable the following services:
  * [Google Cloud Resource Manager API](https://console.cloud.google.com/apis/api/cloudresourcemanager.googleapis.com/overview)
  * [Google Identity and Access Management (IAM) API](https://console.cloud.google.com/apis/api/iam.googleapis.com/overview)
  * [Cloud Spanner API](https://console.cloud.google.com/apis/library/spanner.googleapis.com?q=spanner)

> NOTE: The GCP Service Broker supports a multitude of services in addition to Spanner. While this tutorial focuses on only enabling Spanner, you can enable additional services by following the instructions here: https://github.com/GoogleCloudPlatform/gcp-service-broker.

### Create Root Service Account

A root service account is used by the service broker to access the GCP project. In this section you will create
the root service account and download a JSON document with the corresponding connection information. This JSON doc
will be used by the service broker to connect to the GCP project in a later section.

1. From the GCP console, navigate to `IAM & admin` > `Service accounts` and click `Create Service Account`.
1. Enter a descriptive `Service account name` (for example *gcp-service-broker*) then click `CREATE`.
1. In the `Project Role` dropdown, choose `Project` > `Owner` then click `CONTINUE`.
1. On the next screen, click `+ CREATE KEY`. Be sure `JSON` is selected as the key type and select `CREATE`. A key file will be generated and downloaded to your computer.
1. Accept the confirmation and click `DONE`.

> Be sure you protect the json key file. This file contains credentials that can be used to access your account. If you lose this file, you cannot retrieve it. You will have to generate a new set of credentials.

### Service Broker Database

The GCP service broker stores the state of provisioned resources in a MySQL database. We will use the Google Cloud SQL service for this.

#### Provision MySQL

1. In the GCP console, select `Marketplace`.
1. Enter `MySQL` in the search box.
1. Select `Cloud SQL` in the results.
1. Select the `GO TO CLOUD SQL` button.
1. Select the `Create Instance` button.
1. Select the `MySQL` radio button.
1. Select the `Choose Second Generation` button.
1. Give you instance a name and root password. Be sure to remember your root password!
1. Select the `Create` button.
1. Select the `Next` button.

#### Allow Database Access

By default the database cannot be accessed from external IPs. Since our broker will be running in Cloud Foundry, we need to allow access to the database from that Cloud Foundry. These next steps open the database to external access.

1. Select the newly created instance from the list, which brings you to the `Instance details`.
1. Select the `Connections` tab.
1. Select the `+ Add network` push button.
1. For `Network` enter, `0.0.0.0/0`
1. Select the `Done` button.

> NOTE: The `Network` value of `0.0.0.0/0` will allow connections from any IP. We recommend you contact your Cloud Foundry administrator for the limited IP range on which applications are deployed.

#### Create Database and User

The following steps use Google's Cloud Shell to connect to the MySQL instance to create the required database and user that the broker will use to connect.

1. Select the `Overview` tab.
1. In the `Connect to this instance` section, select `Connect using Cloud Shell`.
1. If an introduction dialog displays, click through it.
1. You'll be taken to a command prompt that already has the proper command to connect to the instance.
Just press `Return`.
1. Wait for your shell to be whitelisted.
1. Enter the root password you sent when you created the instance.
1. Run `CREATE DATABASE servicebroker;`
1. Run `CREATE USER '<username>'@'%' IDENTIFIED BY '<password>';` replacing `<username>` and `<password>` with values you select. Be sure to remember the username and password!
1. Run `GRANT ALL PRIVILEGES ON servicebroker.* TO '<username>'@'%' WITH GRANT OPTION;` replacing `<username>` with the value from the above command.
1. Exit from the MySQL client and cloud shell by typing `exit` and hitting `<ENTER>` twice.

### GCP Setup Recap

Before we continue, let's be sure we understand what we have done so far. The service broker is going to leverage Google Cloud APIs to provision and manipulate resources in our project. As our broker performs work, it will store the state of the resources it has provisioned in a MySQL database.

So far, we have:
* created a project
* enabled APIs our broker will use
* provisioned a MySQL database for the broker to store state and configured the database so the broker will be able to connect

Now, we can deploy the broker and use it.

## Deploying the Broker

We will now deploy the GCP service broker as an application to Cloud Foundry. We will then register this application as a service broker. Before continuing, be sure you are logged into a Cloud Foundry instance and targeted to an org and space

### Cloning

We will start by cloning the latest broker source from github. If you don't have git installed, you can also download a zip file of the broker source.

**Option 1: Cloning**

If you are a git user, you can clone the repository and change to it.

  ```
  $ git clone https://github.com/GoogleCloudPlatform/gcp-service-broker.git
  $ cd gcp-service-broker
  ```

**Option 2: Downloading a Zip**

If you are not a git user, you can download a zip of the repository.

  * Download the zip: https://github.com/GoogleCloudPlatform/gcp-service-broker/archive/master.zip
  * Unzip the downloaded file
  * In a terminal window, change to the unzipped directory.

### Configuring

Configuration of the broker is done via environment variables. We can set these values in the manifest. However, the values are sensitive. Typically, manifests are checked into source control and therefore we need to keep our secrets elsewhere.  For this, we will create a separate secrets file and reference the values in the manifest.

* Using your favorite text editor, open the `manifest.yml`. Add the following under the `env` section of the manifest after the existing values (you can ignore the comment about not editing this file):

  ```
      ROOT_SERVICE_ACCOUNT_JSON: ((root-service-account-json))
      SECURITY_USER_NAME: ((security-user-name))
      SECURITY_USER_PASSWORD: ((security-user-password))
      DB_HOST: ((db-host))
      DB_USERNAME: ((db-username))
      DB_PASSWORD: ((db-password))
  ```

  The values inside the `(())` will be stored in a separate file. This ensures our manifest is safe to commit to version control without leaking secrets.

* Now in your favorite text editor, create a file to hold these secrets called `secrets.yml`. Paste the following into the file:

  ```
  root-service-account-json:
  security-user-name:
  security-user-password:
  db-host:
  db-username:
  db-password:
  ```

  Set the following values:

  * `root-service-account-json`: Open the key file which was downloaded to your computer in the "Create Root Service Account" section above. Copy the entire contents and past it as the value inside single quotes.

  * `security-user-name`: This is the username used by the broker to authenticate requests. It will be used when you register the broker with Cloud Foundry below. You can set this to anything you want.

  * `security-user-password`: This is the password used by the broker to authenticate requests. It will be used when you register the broker with Cloud Foundry below. You can set this to anything you want. If you have special characters in the password, you should place the value inside of double quotes.

  * `db-host`: Set this to the public IP address of the MySQL database you created above. You can find this in the GCP console on the instance details page for your database.

  * `db-username`: Set this to the `<username>` you provided in the [Create Database and User](#create-database-and-user) section above.

  * `db-password`:  Set this to the `<password>` you provided in the [Create Database and User](#create-database-and-user) section above. If you have special characters in the password, you should place the value inside of double quotes.

* Save the `secrets.yml` file. You need to ensure this file IS NOT checked into source control. If you are using git, you should add an entry to your [.gitignore](https://git-scm.com/docs/gitignore) file.

#### Checking Your Configuration

Your manifest should look similar to (values above the properties you added to the `env` section may vary):

```
# Copyright the Service Broker Project Authors. All rights reserved.
... cut for brevity...
# This file is AUTOGENERATED by ./gcp-service-broker generate, DO NOT EDIT IT.

---
applications:
  - name: gcp-service-broker
    product_version: "4.2.0"
    metadata_version: "1.0"
    label: 'GCP Service Broker'
    description: 'A service broker for Google Cloud Platform services.'
    memory: 1G
    buildpack: go_buildpack
    env:
      GOPACKAGENAME: github.com/GoogleCloudPlatform/gcp-service-broker
      GOVERSION: go1.10
      ROOT_SERVICE_ACCOUNT_JSON: ((root-service-account-json))
      SECURITY_USER_NAME: ((security-user-name))
      SECURITY_USER_PASSWORD: ((security-user-password))
      DB_HOST: ((db-host))
      DB_USERNAME: ((db-username))
      DB_PASSWORD: ((db-password))
```

You should have a `secrets.yml` file that looks similar to the following (note that we changed sensitive information):

```
root-service-account-json: '{
  "type": "service_account",
  "project_id": "someproject",
  "private_key_id": "REMOVEDSOMESTUFFHEREFORSAFETYANDSANITY",
  "private_key": "-----BEGIN PRIVATE KEY-----\LETSMESSTHISVALUEUPTOINTHENAMEOFSAFETYANDSECURITYLETSMESSTHISVALUEUPTOINTHENAMEOFSAFETYANDSECURITY...REMOVED...\n-----END PRIVATE KEY-----\n",
  "client_email": "something@some-project.iam.gserviceaccount.com",
  "client_id": "8675309867530986753098675309",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/something%40someproject.iam.gserviceaccount.com"
}'
security-user-name: broker-user
security-user-password: broker-pwd
db-host: 8.67.53.09
db-username: db-user
db-password: db-pwd
```

### Pushing

Now that the manifest and secrets are ready, it is time to push the application to Cloud Foundry.

* From inside the broker source directory (same directory as your manifest):

  ```
  $ cf push --vars-file secrets.yml
  ```

  > NOTE: You may have to add the `--hostname` flag and specify a unique hostname to avoid route collisions.

If everything is successful you should see output similar to:

  ```
  Waiting for app to start...

  name:              gcp-service-broker
  requested state:   started
  routes:            gcp-service-broker.app.cloud.gov
  last uploaded:     Wed 23 Jan 17:29:21 MST 2019
  stack:             cflinuxfs2
  buildpacks:        go

  type:            web
  instances:       1/1
  memory usage:    1G
  start command:   gcp-service-broker
       state     since                  cpu    memory        disk           details
  #0   running   2019-01-24T00:29:41Z   0.0%   44K of 1G   130.4M of 1G   
  ```

Make note of the route assigned to the app. You will need it in the next step.

### Registering

Now that our broker is available as an app, we can register it with Cloud Foundry.

* Register your broker using `cf create-service-broker`:

  ```
  $ cf create-service-broker gcp-service-broker <username> <password> https://<route> --space-scoped
  ```

  Be sure to provide the correct values for:

  * `<username>`: This should be the same value as you provided in `secrets.yml` for the `security-user-name` property.
  * `<password>`: This should be the same value as you provided in `secrets.yml` for the `security-user-password` property.
  * `<route>`: This is the route assigned to your service broker application above.

If everything is successful you should see output similar to:

  ```
  Creating service broker gcp-service-broker in org 18f / space development as someuser@cloug.gov...
  OK
  ```

### The Marketplace

Once the broker is registered, the services offerings will be available in the marketplace.

  * Use `cf marketplace` to list the service offerings. You will see a large number of service offerings prefixed by `google-` which are advertised by the broker.

> NOTE: We only enabled the GCP APIs for Google Spanner. Therefore, trying to provision a different service will result in an error. You can learn about enabling additional services in the broker repository: https://github.com/GoogleCloudPlatform/gcp-service-broker.

## Using Spanner with a Sample Application

At this point, the broker is ready to provision Spanner instances. We have included a sample application that uses Spanner to test this.

### Deploying the Trades Application

The Trades application demonstrates how to read and write POJOs from Google Cloud Spanner using the Spring framework. We can use it to test our GCP broker.

* Download the latest `trades.zip` release: https://github.com/primetimesoftware/trades/releases/download/latest/trades.zip

* Unzip the trades.zip, change to the trades directory in preparation for deploying the application.

  ```
  $ unzip trades.zip
  $ cd trades
  ```

* Deploy the application without starting it:

  ```
  $ cf push -p trades*.jar --no-start
  ```

  > NOTE: You may need to use `--random-route` or specify a hostname via `--hostname` to avoid route collisions.

### Creating and Binding

* Create the Spanner service instance that will be used by the `trades` application:

  ```
  $ cf create-service google-spanner sandbox trades-spanner -c '{"name":"auth-database"}'
  ```

* Bind the instance to the trades app:

  ```
  $ cf bs trades trades-spanner -c '{"role":"spanner.databaseAdmin"}'
  ```

### Accessing the Trades App

You can now start the trades app and see it serving content it placed in Spanner.

* Start the trades app:

  ```
  $ cf start trades
  ```

* Access the `trades` endpoint from a browser at: https://<trades-route>/trades. You should see a json reponse similar to:

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

The trades app is adding entries to Spanner and serving results from it.


## Conclusion

Congratulations on finishing the tutorial! You should have a functional GCP broker configured to work with Spanner. As we mentioned above, you can find more information on configuring additional GCP APIs here: https://github.com/GoogleCloudPlatform/gcp-service-broker.

### Cleaning Up

If you would like to clean up everything created in this tutorial, you can do the following:

* Delete the Trades application.

$ `cf delete -f -r trades`

* Delete the service instance.

$ `cf delete-service -f trades-spanner`

* Delete the service broker.

$ `cf delete-service-broker -f gcp-service-broker`

* Delete the GCP Service Broker application.

$ `cf delete -f -r gcp-service-broker`

* You can also delete your GCP project via the console by going to the project settings and selecting `Shut Down`.
