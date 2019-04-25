# cf-byo-broker

This repository houses tutorials showing users how to bring their own service brokers to use in their spaces in Cloud Foundry. This effort was [funded by the cloud.gov team at 18F](https://github.com/18F/cg-product/issues/876), though the content should be applicable to any Cloud Foundry deployment.  

* [Simple Service Broker Tutorial](simple-service-broker): We recommend you start here. In this tutorial, we will show you how to deploy a simple service broker to a space in Cloud Foundry and make it available for use via the marketplace. We also show you how to interact with the broker and clean up when things go wrong.

* [GCP Spanner Service Broker](gcp-service-broker): This tutorial shows you how to deploy the Google Cloud Platform (GCP) service broker to a space in Cloud Foundry and configure it to provision Spanner instances. It includes a sample application that will connect to a Google Spanner instance provisioned by the broker.

* [Azure Service Broker Tutorial](azure-service-broker): This tutorial walks us through how to steps required to deploy the Azure open service broker (OSBA) to a scoped space on Cloud Foundry. We will also illustrate leveraging terraform and Concourse.ci pipelines, outlining how to deploy the Azure open service broker (OBSA) both manually and programmatically.

    At the end of this tutorial, you will know how to provision OSBA either manually or via automation and you will be able to find the Azure services available via the CF marketplace

## Contributing

Contributions to this repository are welcome. If you have a tutorial for a specific broker that you would like to contribute, please open a pull request. 
