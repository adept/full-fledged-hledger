#!/bin/bash
function report() {
    asset="$1"
    shift
    hledger roi -f ../all.journal \
            --investment "acct:assets:${asset} not:acct:equity" \
            --pnl 'acct:virtual:unrealized not:acct:equity' "$@"
}

echo "Pension"
echo
report "pension"
report "pension" -Y
