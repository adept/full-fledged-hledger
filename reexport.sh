#!/bin/bash
set -e
set -o pipefail

. chapters.sh

for c in ${chapters[@]} ; do
    echo "Exporting in $c"
    (cd "$c"; if [ -x ./export.sh ] ; then ./export.sh ; fi)
done
