#!/bin/bash
set -e -o pipefail
[ -z "$1" -o -z "$2" -o -z "$3" ] && ( echo "usage: $0 DATES_FILE COMMODITY BASE"; exit 1; )
dates=$(readlink -f "$1")
sym="$2"
quot="$3"
dir=$(readlink -f $(dirname $0))

extra=""
case "${sym}" in
    EUR|USD)
        source="yahoo"
        symbol="${sym}${quot}=X"
        extra="--quantize=5"
        sym="$" # rewrite USD to $ in the output
        ;;
    *)
        echo "Define price source for ${sym} first"; exit 1 ;;
esac

first=$(head -n1 $dates)
last=$(tail -n1 $dates)

# Grab all prices between first and last date, filter just to the dates we need
pricehist fetch ${source} "${symbol}" \
       -s $first -e $last \
       $extra \
       -o ledger --fmt-time '' --fmt-base "${sym}" --fmt-quote £ --fmt-symbol left \
  | fgrep -f $dates
