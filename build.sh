#!/bin/bash
set -e
./reexport.sh --rebuild
./updatediffs.sh
