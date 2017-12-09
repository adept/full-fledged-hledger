#!/bin/bash
set -e

function convert() {
    file="$1"
    rules="lloyds.rules"
    out=$(basename $file)
    csv=./csv/${out}
    out=./journal/${out%%.csv}.journal
    
    ./lloyds2csv.pl < $file > $csv
    hledger print --rules-file $rules -f $csv > $out
    hledger print -f $out unknown --ignore-assertions
}
export -f convert
parallel convert ::: in/*.csv
