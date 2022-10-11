#!/bin/bash
year="$1"

dir=$(dirname $0)

function gen_input(){
    echo "include ${dir}/../budget.journal"

    # make sure that all postings are fully expanded to avoid
    # "Balance assignments may not be used on accounts affected by auto posting rules"
    hledger print -f "${dir}/../${year}.journal" -x
}

gen_input | hledger balance -f - balance -I --auto --tree -H -p monthly budget not:equity:opening
