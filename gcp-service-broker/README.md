# Table of Contents
[Adding a Space Scoped GCP Service Broker](#space-scoped-broker) 

 <a name="space-scoped-broker"></a>
# Adding a Space Scoped GCP Service Broker <a name="space-scoped-broker"></a>

This tutorial walks you through the steps of adding the GCP Service Broker to a Cloud Foundry space as an application and then deploys an application to demonstrate how to use the Broker to access the GCP Spanner service.

## [Broker Installation](#broker-installation)

Installing a GCP Service Broker involves setting up 

### [Setup GCP Project](#project)

1. Go to the [Google Cloud Console](https://console.cloud.google.com) and sign up, walking through the setup wizard.
1. Next to the Google Cloud Platform logo in the upper left-hand corner, click the dropdown. In the popup, select "New Project"
in the upper right.
1. Give your project a name and click "Create".
1. A notification in the upper right indicates when the project is created. Refresh the page.
1. You may need to select the newly created project from the project drop down in the upper left.

### [Enable APIs](#apis)

Enable the following services in **[APIs & Services > Library](https://console.cloud.google.com/apis/library)**.

1. Enable the [Google Cloud Resource Manager API](https://console.cloud.google.com/apis/api/cloudresourcemanager.googleapis.com/overview)
1. Enable the [Google Identity and Access Management (IAM) API](https://console.cloud.google.com/apis/api/iam.googleapis.com/overview)
1. Enable the [Cloud Spanner API](https://console.cloud.google.com/apis/library/spanner.googleapis.com?q=spanner)

### [Create Root Service Account](#service-account)

1. From the GCP console, navigate to **IAM & Admin > Service accounts** and click **Create Service Account**.
1. Enter a **Service account name**.
1. In the **Project Role** dropdown, choose **Project > Owner**.
1. Select the checkbox to **Furnish a new Private Key**, make sure the **JSON** key type is specified.
1. Click **Save** to create the account, key and grant it the owner permission.
1. Save the automatically downloaded key file to a secure location.

### [Setup Backing Database](#database-setup)

The GCP Service Broker stores the state of provisioned resources in a MySQL database. This will be done
by creating a CloudSQL, MySQL instance.

#### Create MySQL Instance

1. Select "Marketplace" from the dropdown in the upper right.
1. Enter "MySQL" in the search box.
1. Select "Cloud SQL" in the results.
1. Select the "GO TO CLOUD SQL" button.
1. Select the "Create Instance" button.
1. Select the "MySQL" radio button.
1. Select the "Choose Second Generation" button.
1. Give you instance a name and root password.
1. Select the "Create" button.
1. Select the "Next" button.

#### [Allow Access Externally](#external-db-access)

By default the database cannot be accessed by external IPs. These next steps open the database to external access.

1. Select the newly created instance from the list, which brings you to the "Instance details".
1. Select the "Connections" tab.
1. Select the "+ Add network" push button.
1. For "Network" enter, `0.0.0.0/0`
1. Select the "Done" button.

#### [Create Database](#create-db)

Now that the instance has been created, it's time to the Service Broker database within the instance. The following 
use Google's Cloud Shell to connect to the MySQL instance and creates the required database and user that the
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

### [Service Broker Application Deployment](#deploy-db)

Now that the database is setup, you are ready to deploy the Service Broker as an application to Cloud Foundry.

### Clone the GCP Service Broker Repository

/> git clone https://github.com/GoogleCloudPlatform/gcp-service-broker.git

### [Set required environment variables](#required-env)

Add these to the `env` section of `manifest.yml`

* `ROOT_SERVICE_ACCOUNT_JSON` - the string version of the credentials file created for the Owner level Service Account.
* `SECURITY_USER_NAME` - the username to authenticate broker requests - the same one used in `cf create-service-broker`.
* `SECURITY_USER_PASSWORD` - the password to authenticate broker requests - the same one used in `cf create-service-broker`.
* `DB_HOST` - the host for the database to back the service broker.
* `DB_USERNAME` - the database username for the service broker to use.
* `DB_PASSWORD` - the database password for the service broker to use.

#### [Push Service Broker to CF](#push)
1. `cf push gcp-service-broker`
1. `cf create-service-broker <service broker name> <username> <password> <service broker url> --space-scoped`

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

### [Create a Spanner Service](#create-spanner-service)

\> `cf create-servcie <service broker name> sandbox gcpspanner -c '{"name":"auth-database"}'`

<b>Checking your work</b>
Once the service has been create, executing the `services` command shows it as an available service in the space.

\> `cf services`

```$ cf services
Getting services in org 18f / space development as steve.wall@primetimesoftware.com...

name         service                 plan                bound apps           last operation
gcpspanner   google-spanner          sandbox             spanner-sample-sjw   create succeeded
```

### [Deploy Spanner Application](#deploy-spanner-app)

Now it is time to deploy an application to use the Spanner service. The first step is to copy the example application and associated manifest.yml from ???Need to determine where the artifact will be housed. For now it can be built by executing `mvn clean package` in the `trades` directory???

The next step is to deploy the application. Do not start the application yet. You'll need to bind the service to the application and then it'll be ready to start.

\> `cf p --nostart`

Now you are ready to bind the service to the application. Binding the service adds the required connection information to the application `VCAP_SERVICES` environment variable.

\> `cf bs spanner-sample-<unique id> gcpspanner -c '{"role":"spanner.databaseAdmin"}'`

<b>Checking your work</b>

\> `$ cf env spanner-sample-sjw`

```
Getting env variables for app spanner-sample-sjw in org 18f / space development as steve.wall@primetimesoftware.com...
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

\> `cf start spanner-sample-<unique id>`

<b>Checking your work</b>
To check the application deployed correctly, access the `trader` endpoint from a browers.

https://<app url>/traders

This should return the following json document.

```
{
  "_embedded" : {
    "traders" : [ {
      "traderId" : "demo_trader1",
      "firstName" : "John",
      "lastName" : "Doe",
      "_links" : {
        "self" : {
          "href" : "https://spanner-sample-sjw.cfapps.io/traders/demo_trader1"
        },
        "trader" : {
          "href" : "https://spanner-sample-sjw.cfapps.io/traders/demo_trader1"
        }
      }
    }, {
      "traderId" : "demo_trader2",
      "firstName" : "Mary",
      "lastName" : "Jane",
      "_links" : {
        "self" : {
          "href" : "https://spanner-sample-sjw.cfapps.io/traders/demo_trader2"
        },
        "trader" : {
          "href" : "https://spanner-sample-sjw.cfapps.io/traders/demo_trader2"
        }
      }
    }, {
      "traderId" : "demo_trader3",
      "firstName" : "Scott",
      "lastName" : "Smith",
      "_links" : {
        "self" : {
          "href" : "https://spanner-sample-sjw.cfapps.io/traders/demo_trader3"
        },
        "trader" : {
          "href" : "https://spanner-sample-sjw.cfapps.io/traders/demo_trader3"
        }
      }
    } ]
  },
  "_links" : {
    "self" : {
      "href" : "https://spanner-sample-sjw.cfapps.io/traders{?page,size,sort}",
      "templated" : true
    },
    "profile" : {
      "href" : "https://spanner-sample-sjw.cfapps.io/profile/traders"
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

## [Cleanup](#cleanup)

Through the course of the tutorial, there were several things created in your CF space. We don't have to leave things
hanging around consuming resources, so now it's time to cleanup! This essentially involves deleting the items that were
created in reverse order.


