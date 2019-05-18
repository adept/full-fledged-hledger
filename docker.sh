#!/bin/bash

# check if started in WSL
if [[ $(uname -r) =~ Microsoft$ ]]; then
    #  if WSL
    docker container run --rm -it -v "$(wslpath -a -m .)":/full-fledged-hledger dastapov/full-fledged-hledger:latest
else
    # otherwise
    docker container run --rm -it -v "$(pwd)":/full-fledged-hledger dastapov/full-fledged-hledger:latest
fi