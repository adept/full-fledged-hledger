#!/bin/bash
set -e -o pipefail
[ -z "$1" ] && ( echo "usage: $0 YEAR"; exit 1; )
year="$1"
dir=$(dirname $0)
echo ";; This is an auto-generated file, do not edit"
# 2% till 2015-05
hledger -f "${dir}/../${year}.journal" print 'not:desc:(interest for)' -I \
    | hledger print -f - -e 2015-05 \
    | hledger-interest -f - --source='expenses:mortgage interest' --target=liabilities:mortgage --annual=0.02 --act liabilities:mortgage -q --today -I \
    | hledger print -f - -p "${year}" \
    | hledger print -f - -e 2015-05

# 1.8% after 2015-05
hledger -f "${dir}/../${year}.journal" print 'not:desc:(interest for)' -I \
    | hledger print -f - -b 2015-05 \
    | hledger-interest -f - --source='expenses:mortgage interest' --target=liabilities:mortgage --annual=0.018 --act liabilities:mortgage -q --today -I \
    | hledger print -f - -p "${year}" \
    | hledger print -f - -b 2015-05
