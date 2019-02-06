#!/bin/bash
set -e
set -o pipefail

storydir="${1}"
diffdir="${2}"

: ${storydir:="./"}
: ${diffdir:="./diffs"}

chapters=($(ls -1 "${storydir}/[0-9]*"))

for c in $(seq 1 $(( ${#chapters[@]} - 1)) ) ; do
    p=$(( $c - 1 ))
    curr=${chapters[$c]}
    prev=${chapters[$p]}
    echo "$prev -> $curr"
    d=$(printf "%02d-to-%02d" $p $c)
    diff -Naurb ${storydir}/${prev} ${storydir}/${curr} > ${diffdir}/"${d}.diff" || true
    # patdiff -html < ${diffdir}/"${d}.diff" > ${diffdir}/"${d}.html" || true
done
