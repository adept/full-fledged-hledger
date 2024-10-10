#!/bin/bash
set -e -o pipefail
[ -z "$1" -o -z "$2" ] && ( echo "usage: $0 YEAR COMMODITY"; exit 1; )
year="$1"
sym="$2"
dir=$(dirname $0)

query="cur:${sym}"
if [ "${sym}" = "USD" ] ; then
    sym="$"
    query="cur:\\$"
fi

hledger -f "${dir}/../${year}.journal" print "${query}" -Ocsv | sed -n -e "1p;/,\"${sym}\",/p" | csvtool namedcol date - | sed -e '/date/d' | sort -u

