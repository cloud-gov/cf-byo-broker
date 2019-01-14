# Adding a Space Scoped GCP Service Broker 

This tutorial walks you through the steps of adding the GCP Service Broker to a Cloud Foundry space as an application and then deploys an application to demonstrate how to use the Broker to access the GCP Spanner service.

## Broker Installation

The first step is to install the Broker as an application to your space. To do this, you will follow the installation instructions in the GCP Service Broker github repository, with two notable exceptions. The repo describes creating a organization scoped service. You will create a space scoped service  by adding the `--space-level` option to the `create-service-broker` command.

ex. `cf create-service-broker <service broker name> <username> <password> <service broker url> --space-scoped`

The instructions also call for executing a command to enable specific services. This is unnessary for scoped spaced service brokers. That is, there is not need to execute the `cf enable-service-access` command. 

 Other that those 2 exceptions, follow the i [GCP Service Broker repo](https://github.com/GoogleCloudPlatform/gcp-service-broker/) installation instructions.

<b>Checking your work</b>
Once the broker is installed, the services will be available in the marketplace. Executing the marketplace command shows the GCP service are now available.

\> `cf marketplace`

```
google-bigquery                 default                                                                                                                                                                                                                                                                                                                                                                                                     A fast, economical and fully managed data warehouse for large-scale data analytics.
google-bigtable                 three-node-production-hdd, three-node-production-ssd                                                                                                                                                                                                                                                                                                                                                        A high performance NoSQL database service for large analytical and operational workloads.
google-cloudsql-mysql           mysql-db-f1-micro, mysql-db-g1-small, mysql-db-n1-standard-1, mysql-db-n1-standard-2, mysql-db-n1-standard-4, mysql-db-n1-standard-8, mysql-db-n1-standard-16, mysql-db-n1-standard-32, mysql-db-n1-standard-64, mysql-db-n1-highmem-2, mysql-db-n1-highmem-4, mysql-db-n1-highmem-8, mysql-db-n1-highmem-16, mysql-db-n1-highmem-32, mysql-db-n1-highmem-64                                                Google Cloud SQL is a fully-managed MySQL database service.
google-cloudsql-postgres        postgres-db-f1-micro, postgres-db-g1-small, postgres-db-n1-standard-1, postgres-db-n1-standard-2, postgres-db-n1-standard-4, postgres-db-n1-standard-8, postgres-db-n1-standard-16, postgres-db-n1-standard-32, postgres-db-n1-standard-64, postgres-db-n1-highmem-2, postgres-db-n1-highmem-4, postgres-db-n1-highmem-8, postgres-db-n1-highmem-16, postgres-db-n1-highmem-32, postgres-db-n1-highmem-64   Google Cloud SQL is a fully-managed PostgreSQL database service.
google-dataflow                 default                                                                                                                                                                                                                                                                                                                                                                                                     A managed service for executing a wide variety of data processing patterns built on Apache Beam.
google-datastore                default                                                                                                                                                                                                                                                                                                                                                                                                     Google Cloud Datastore is a NoSQL document database service.
google-dialogflow               default                                                                                                                                                                                                                                                                                                                                                                                                     Dialogflow is an end-to-end, build-once deploy-everywhere development suite for creating conversational interfaces for websites, mobile applications, popular messaging platforms, and IoT devices.
google-firestore                default                                                                                                                                                                                                                                                                                                                                                                                                     Cloud Firestore is a fast, fully managed, serverless, cloud-native NoSQL document database that simplifies storing, syncing, and querying data for your mobile, web, and IoT apps at global scale.
google-ml-apis                  default                                                                                                                                                                                                                                                                                                                                                                                                     Machine Learning APIs including Vision, Translate, Speech, and Natural Language.
google-pubsub                   default                                                                                                                                                                                                                                                                                                                                                                                                     A global service for real-time and reliable messaging and streaming data.
google-spanner                  sandbox, minimal-production                                                                                                                                                                                                                                                                                                                                                                                 The first horizontally scalable, globally consistent, relational database service.
google-stackdriver-debugger     default                                                                                                                                                                                                                                                                                                                                                                                                     Stackdriver Debugger
google-stackdriver-monitoring   default                                                                                                                                                                                                                                                                                                                                                                                                     Stackdriver Monitoring
google-stackdriver-profiler     default                                                                                                                                                                                                                                                                                                                                                                                                     Stackdriver Profiler
google-stackdriver-trace        default                                                                                                                                                                                                                                                                                                                                                                                                     Stackdriver Trace
google-storage                  standard, nearline, reduced-availability, coldline, regional, multiregional                                                                                                                                                                                                                                                                                                                                 Unified object storage for developers and enterprises. Cloud Storage allows world-wide storage and retrieval of any amount of data at any time.
google-bigquery                 default                                                                                                                                                                                                                                                                                                                                                                                                     A fast, economical and fully managed data warehouse for large-scale data analytics.
google-bigtable                 three-node-production-hdd, three-node-production-ssd                                                                                                                                                                                                                                                                                                                                                        A high performance NoSQL database service for large analytical and operational workloads.
google-cloudsql-mysql           mysql-db-f1-micro, mysql-db-g1-small, mysql-db-n1-standard-1, mysql-db-n1-standard-2, mysql-db-n1-standard-4, mysql-db-n1-standard-8, mysql-db-n1-standard-16, mysql-db-n1-standard-32, mysql-db-n1-standard-64, mysql-db-n1-highmem-2, mysql-db-n1-highmem-4, mysql-db-n1-highmem-8, mysql-db-n1-highmem-16, mysql-db-n1-highmem-32, mysql-db-n1-highmem-64                                                Google Cloud SQL is a fully-managed MySQL database service.
google-cloudsql-postgres        postgres-db-f1-micro, postgres-db-g1-small, postgres-db-n1-standard-1, postgres-db-n1-standard-2, postgres-db-n1-standard-4, postgres-db-n1-standard-8, postgres-db-n1-standard-16, postgres-db-n1-standard-32, postgres-db-n1-standard-64, postgres-db-n1-highmem-2, postgres-db-n1-highmem-4, postgres-db-n1-highmem-8, postgres-db-n1-highmem-16, postgres-db-n1-highmem-32, postgres-db-n1-highmem-64   Google Cloud SQL is a fully-managed PostgreSQL database service.
google-dataflow                 default                                                                                                                                                                                                                                                                                                                                                                                                     A managed service for executing a wide variety of data processing patterns built on Apache Beam.
google-datastore                default                                                                                                                                                                                                                                                                                                                                                                                                     Google Cloud Datastore is a NoSQL document database service.
google-dialogflow               default                                                                                                                                                                                                                                                                                                                                                                                                     Dialogflow is an end-to-end, build-once deploy-everywhere development suite for creating conversational interfaces for websites, mobile applications, popular messaging platforms, and IoT devices.
google-firestore                default                                                                                                                                                                                                                                                                                                                                                                                                     Cloud Firestore is a fast, fully managed, serverless, cloud-native NoSQL document database that simplifies storing, syncing, and querying data for your mobile, web, and IoT apps at global scale.
google-ml-apis                  default                                                                                                                                                                                                                                                                                                                                                                                                     Machine Learning APIs including Vision, Translate, Speech, and Natural Language.
google-pubsub                   default                                                                                                                                                                                                                                                                                                                                                                                                     A global service for real-time and reliable messaging and streaming data.
google-spanner                  sandbox, minimal-production                                                                                                                                                                                                                                                                                                                                                                                 The first horizontally scalable, globally consistent, relational database service.
google-stackdriver-debugger     default                                                                                                                                                                                                                                                                                                                                                                                                     Stackdriver Debugger
google-stackdriver-monitoring   default                                                                                                                                                                                                                                                                                                                                                                                                     Stackdriver Monitoring
google-stackdriver-profiler     default                                                                                                                                                                                                                                                                                                                                                                                                     Stackdriver Profiler
google-stackdriver-trace        default                                                                                                                                                                                                                                                                                                                                                                                                     Stackdriver Trace
google-storage                  standard, nearline, reduced-availability, coldline, regional, multiregional                                                                                                                                                                                                                                                                                                                                 Unified object storage for developers and enterprises. Cloud Storage allows world-wide storage and retrieval of any amount of data at any time.
simple-service                  simple-plan-1, simple-plan-2                                                                                                                                                                                                                                                                                                                                                                                This service is for demonstration purposes. The same broker could advertise more than one service.
```


### Create a Spanner Service

\> `cf create-servcie <service broker name> sandbox gcpspanner -c '{"name":"auth-database"}'`

<b>Checking your work</b>
Once the service has been create, executing the `services` command shows it as an available service in the space.

\> `cf services`

```$ cf services
Getting services in org 18f / space development as steve.wall@primetimesoftware.com...

name         service                 plan                bound apps           last operation
gcpspanner   google-spanner          sandbox             spanner-sample-sjw   create succeeded
```

### Deploy Spanner Application

Now it is time to deploy an application to use the Spanner service. The first step is to copy the example application and associated manifest.yml from ???Need to determine where the artifact will be housed. For now it can be built by executing `mvn clean package` in the `gcp-spanner-example` directory???

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
