#!/bin/bash
set -e
set -o pipefail

. chapters.sh

for c in ${chapters[@]} ; do
    (cd "$c"; [ -x ./export.sh ] && ./export.sh)
done
