#!/bin/bash
docker build . --tag dastapov/full-fledged-hledger:latest
docker image push dastapov/full-fledged-hledger:latest
