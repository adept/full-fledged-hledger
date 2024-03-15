#!/bin/bash

cd $(dirname $0)

parallel -k :::: <<EOF
echo "END OF YEAR VALUATIONS"
echo "======================"
hledger balance 'stock options:vested' -f ../all.journal -Y -b2014 --cumulative --transpose --value=end,USD --valuechange --no-total
echo

echo "VESTING HISTORY"
echo "==============="
hledger balance 'stock options:vest' -f ../all.journal -Y -b2014 --cumulative
echo
EOF
