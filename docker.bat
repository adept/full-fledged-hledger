@ECHO off 
REM #!/bin/bash
REM
REM # check if started in WSL
REM if [[ $(uname -r) =~ Microsoft$ ]]; then
REM     #  if WSL
REM     docker container run --rm -it -v "$(wslpath -a -m .)":/full-fledged-hledger dastapov/full-fledged-hledger:latest
REM else
REM     # otherwise
REM     docker container run --rm -it -v "$(pwd)":/full-fledged-hledger dastapov/full-fledged-hledger:latest
REM fi

REM capture the path to $0 ie this script
SET mypath=%~dp0

REM strip last char
SET PREFIXPATH=%mypath:~0,-1%

REM swap \ for / in the path
REM because docker likes it that way in volume mounting
SET PPATH=%PREFIXPATH:\=/%

docker.exe container run --rm -it -v "%PPATH%":/full-fledged-hledger dastapov/full-fledged-hledger:latest