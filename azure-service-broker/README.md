# Open Service Broker™ for Azure on Cloud Foundry
# Open Service Broker™ for Azure on Cloud Foundry Container Runtime (CFCR) Managed Cluster


This tutorial walks us through how to deploy the Azure open service broker (OSBA) to a scoped space on Cloud Foundry. We also illustrate leveraging `terraform` and concourse.ci pipelines, providing creation of the Azure service broker both manually and programmatically.

**Table of Contents**

* [Prerequisites](#prerequisites)
* [Azure Quickstart](#azure-setup)
    * [Configure your Azure account](#configure-your-azure-account)
    * [Create a Resource Group](#create-a-resource-group-for-aks)
    * [Create a service principal](#create-a-service-principal)
* [Deploying the Broker](#deploying-the-broker)
    * [Cloning](#cloning)
    * [Configuring](#configuring)
    * [Pushing]()
    * [Registering]()
        * [The Marketplace]()
    * [Automating Deployment via Terraform]()
    

## Prerequisites

In order to complete the tutorial, please be sure you have:

* A [Microsoft Azure account](https://portal.azure.com).
* A working knowledge of **Azure [CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)** or use of the [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview?view=azure-cli-latest)
* A working knowledge of **Cloud Foundry** with experience using the [CLI](https://docs.cloudfoundry.org/cf-cli/).
* A working knowledge of space-scoped service brokers. For an  introduction, see the [Simple Service Broker Quickstart Tutorial](../simple-service-broker).
* A Cloud Foundry account and a space to deploy apps.
* A working knowledge of [terraform](https://portal.azure.com) and use of [terraform providers](https://www.terraform.io/docs/providers/).

## Azure Setup

### Configure your Azure account

First let's identify your Azure subscription and save it for use later on in the quickstart.

1. Run `az login` and follow the instructions in the command output to authorize `az` to use your account
1. List your Azure subscriptions:
    ```console
    az account list -o table
    ```
1. Copy your subscription ID and save it in an environment variable:

    **Bash**
    ```console
    export AZURE_SUBSCRIPTION_ID="<SubscriptionId>"
    ```

    **PowerShell**
    ```console
    $env:AZURE_SUBSCRIPTION_ID = "<SubscriptionId>"
    ```

### Create a Resource Group

sCreate one with the az cli using the following command.

```console
az group create --name <CHANGEME> --location eastus
```

### Create a service principal

Open Service Broker for Azure uses a service principal to provision Azure resources on your behalf or if you're using AKS, on behalf of Kubernetes.

1. Create a service principal with RBAC enabled:
    ```console
    az ad sp create-for-rbac --name osba -o table
    ```
1. Save the values from the command output in environment variables:

    **Bash**
    ```console
    export AZURE_TENANT_ID=<Tenant>
    export AZURE_CLIENT_ID=<AppId>
    export AZURE_CLIENT_SECRET=<Password>
    ```

    **PowerShell**
    ```console
    $env:AZURE_TENANT_ID = "<Tenant>"
    $env:AZURE_CLIENT_ID = "<AppId>"
    $env:AZURE_CLIENT_SECRET = "<Password>"
    ```

## Deploying the Broker

### Cloning

We will start by cloning the latest broker source from OSBA's offfcial github repository. If you don't have `git` installed, you can also download a zip file of the broker source.

**Option 1: Cloning**

If you are a git user, you can clone the repository and change to it.

  ```
  $ git clone https://github.com/Azure/open-service-broker-azure.git
  $ cd open-service-broker-azure
  ```

**Option 2: Downloading a Zip**

If you are not a git user, you can download a zip of the repository.

  * Download the zip: https://github.com/Azure/open-service-broker-azure/archive/master.zip
  * Unzip the downloaded file
  * In a terminal window, change to the unzipped directory.

### Configuring

OSBA repository directory heirarchy 

```sh
.
├── Dockerfile
├── Gopkg.lock
├── Gopkg.toml
├── LICENSE
├── Makefile
├── README.md
├── cmd
│   ├── broker
│   └── compliance-test-broker
├── contrib
│   ├── cf
│   │   ├── README.md
│   │   ├── manifest.yml
│   │   └── pcf-tile
│   ├── cmd
│   │   └── cli
│   ├── doc-templates
│   │   └── module.md
│   ├── k8s
│   │   ├── charts
│   │   └── examples
│   └── openshift
│       └── osba-os-template.yaml
├── ...
```

Open `contrib/cf/manifest.yml` and enter the values obtained in the earlier steps:

```yaml
---
  applications:
    - name: osba
      buildpack: 
        - go_buildpack
      command: broker
      env:
        AZURE_SUBSCRIPTION_ID: <YOUR SUBSCRIPTION ID>
        AZURE_TENANT_ID: <TENANT ID FROM SERVICE PRINCIPAL>
        AZURE_CLIENT_ID: <APPID FROM SERVICE PRINCIPAL>
        AZURE_CLIENT_SECRET: <PASSWORD FROM SERVICE PRINCIPAL>
        LOG_LEVEL: DEBUG
        MIN_STABILITY: PREVIEW
        ENABLE_MIGRATION_SERVICES: false
        REDIS_PREFIX:
        STORAGE_REDIS_HOST: <HOSTNAME FROM AZURE REDIS CACHE>
        STORAGE_REDIS_PASSWORD: <PRIMARYKEY FROM AZURE REDIS CACHE>
        STORAGE_REDIS_PORT: 6380
        STORAGE_REDIS_DB: 0
        STORAGE_REDIS_ENABLE_TLS: true
        CRYPTO_ENCRYPTION_SCHEME: AES256
        CRYPTO_AES256_KEY: AES256Key-32Characters1234567890
        ASYNC_REDIS_HOST: <HOSTNAME FROM AZURE REDIS CACHE>
        ASYNC_REDIS_PASSWORD: <PRIMARYKEY FROM AZURE REDIS CACHE>
        ASYNC_REDIS_PORT: 6380
        ASYNC_REDIS_DB: 1
        ASYNC_REDIS_ENABLE_TLS: true
        BASIC_AUTH_USERNAME: username
        BASIC_AUTH_PASSWORD: password
        GOPACKAGENAME: github.com/Azure/open-service-broker-azure
        GO_INSTALL_PACKAGE_SPEC: github.com/Azure/open-service-broker-azure/cmd/broker
```

_In a production environment, we would recommend using CREDHUB to store these values._

### Pusing

Once you have added the necessary environment variables to the CF manifest, you can simply push the broker:

```console
cf push -f contrib/cf/manifest.yml
```

### Registering

Now that our broker is available as an app, we can register it with Cloud Foundry.

* Register your broker using `cf create-service-broker`:

  ```sh
  $ cf csb open-service-broker-azure  <username> <password> https://<route> --space-scoped
  ```

### Marketplace

![alt text](../.media/marketplace.png)

### Automating Deployment with `terraform` AzureRM Provider

### Automating Deployment with Concourse.ci Pipeline(s)



