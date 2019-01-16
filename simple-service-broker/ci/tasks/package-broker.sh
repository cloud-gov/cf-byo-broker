#!/bin/bash

mkdir simple-service-broker

cp -R broker-source/* simple-service-broker/*

zip -r simple-service-broker simple-service-broker

mv simple-service-broker.zip output
