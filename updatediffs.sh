#!/bin/bash
set -e
set -o pipefail

. chapters.sh

for c in $(seq 1 $(( ${#chapters[@]} - 1)) ) ; do
    p=$(( $c - 1 ))
    curr=${chapters[$c]}
    prev=${chapters[$p]}
    echo "$prev -> $curr"
    d=$(printf "%02d-to-%02d" $p $c)
    diff -X .gitignore -Naurb \
         ${storydir}/${prev} ${storydir}/${curr} \
        | ./filterdiff.sh \
          > ${diffdir}/"${d}.diff" \
        || true
done
