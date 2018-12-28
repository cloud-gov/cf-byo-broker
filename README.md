# cg-customer-broker
Delivery of https://github.com/18F/cg-product/blob/master/helpwanted/CustomBrokerDemo.md#user-stories

The goal of this effort is to delivery documentation and training which will show a cloud.gov user how to add a space scoped broker so it shows up in their marketplace.

## Persona Characteristics

* Cloud Foundry developer/user
* Has:
  * deployed/run apps
  * scaled
  * knows of envars
  * consumed services from the marketplace
* Little experience or knowledge of brokers and the api
* No knowledge of space scoped brokers
* Understands Fedramp impacts and responsibilities
* Gravitates towards GUIs vs command line

## Key Takeaways/Experiences

**Work in Progress**

*Unordered list of what is important*

Understand:
* broker scope (cf vs space) and related roles (CF Admin vs SpaceDeveloper)
* broker basic concepts explained: catalog/plans (marketplace), provisioning, binding
* broker implements an API (just an app)
* introduction to OSBAPI standard (awareness) and relation to CF
* where can a broker be deployed?
* automation for space scoped broker lifecycle
* how apps interact with service instances (broker is not involved)
* lifecycle interaction between user, broker, app, and service instances (diagram)

Experience:
* registering a space scoped broker w/ Cloud Controller
* make plans available
* viewing space scoped broker plans in the marketplace via CLI
* viewing space scoped broker plans in the marketplace via Stratos
* provision a svc instance
* bind a svc instance
* parsing VCAP_SERVICES
* unbind a svc instance
* deprovision a svc instance
* deploy a customer broker as an app
* enabling service access

Maybe:
* sharing services
* app sec groups
* writing your own broker (beyond)
* best practices on space management for brokers/apps

