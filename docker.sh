#!/bin/bash

# check if started in WSL
if [[ $(uname -r) =~ Microsoft$ ]]; then
    #  if WSL
    docker container run --rm -it --user $(id --user):$(id --group) -v "$(wslpath -a -m .)":/full-fledged-hledger dastapov/full-fledged-hledger:latest
else
    # otherwise
    docker container run --rm -it --user $(id --user):$(id --group) -v "$(pwd)":/full-fledged-hledger dastapov/full-fledged-hledger:latest
fi
