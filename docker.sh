#!/bin/bash
docker container run --rm -it -v $(pwd):/full-fledged-hledger dastapov/full-fledged-hledger:latest 
