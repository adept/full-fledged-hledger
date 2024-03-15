#!/bin/bash

cd $(dirname $0)

parallel -k :::: <<EOF
echo "PENSION CONTRIBUTIONS"
echo "====================="
hledger -f ../all.journal balance "assets:pension:aviva" "virtual:pension:input" -b "2013-04-06" -p "every year" --transpose --depth 3
echo

echo "PENSION ALLOWANCE TRACKING"
echo "=========================="
hledger  -f ../all.journal balance virtual:pension -b '2013-04-06' -p 'every year' --no-elide --tree --cumulative -H
echo

echo "UNUSED PENSION ALLOWANCE"
echo "========================"
hledger  -f ../all.journal register virtual:pension:allowance:unused -b '2013-04-06' --depth 4
EOF
