#!/bin/bash

mkdir simple-service-broker

ls broker-source

cp -R broker-source/* simple-service-broker

ls simple-service-broker

zip -r simple-service-broker simple-service-broker

mv simple-service-broker.zip output
