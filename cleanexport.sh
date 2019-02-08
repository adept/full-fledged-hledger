#!/bin/bash
set -e
set -o pipefail

. chapters.sh

for c in ${chapters[@]} ; do
    echo "Cleaning in $c"
    (cd "$c"; rm -f ./export/*.{journal,txt})
done
