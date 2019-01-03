# cg-customer-broker

Delivery of https://github.com/18F/cg-product/blob/master/helpwanted/CustomBrokerDemo.md#user-stories

The goal of this effort is to deliver documentation and training which will show a cloud.gov user how to add a space scoped broker so it shows up in their marketplace.

## Project Resources

**Concourse CI**: 18f team on https://ci.aws.rscale.io

**Pivotal Tracker**: https://www.pivotaltracker.com/projects/2233580

**Development Environment**: 18f (org) / development (space) on PWS *(not public)*

**Integration Test Environment**: 18f (org) / integration (space) on PWS *(not public)*


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
* you can purge service offerings and instances (useful in dev when the broker isn't functioning or available)

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

## Learning Path (WIP)

This is a rough outline/flow.  It is a work in progress (WIP)!

1. What is a broker?
  * Standardized API so you can see what is available, provision/deprovision, bind/unbind
  * Scope: system vs space
2. Deploy the broker as an app
  * Where can a broker live? And why is should be in CF if possible.
3. Register space-scoped broker & make plans available
  * SpaceDeveloper role vs. CF Admin
  * View in Marketplace CLI
  * View in Stratos
4. Provision an instance
5. Bind to an app
  * VCAP_SERVICES
  * Dashboards
6. Unbind
7. Deprovision
8. Remove the broker

### Beyond

1. Share svc instances

2. Best practices on space management

3. Automation

4. Custom brokers & OSBAPI
