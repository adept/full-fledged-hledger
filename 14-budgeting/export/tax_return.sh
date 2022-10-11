#!/bin/bash
year="$1"
year2="$2"

dir=$(dirname $0)

function gen_input(){
    echo "include ${dir}/../${year}.journal"
    echo "include ${dir}/${year}-closing.journal"
    echo "include ${dir}/../${year2}.journal"
}

echo "INCOME TOTALS"
echo "============="

gen_input | hledger balance -f - --tree \
    "income" "not:income:employer" \
    -b $year-04-06 -e $year2-04-06 # end date is not inclusive
echo

echo "PAYSLIPS CHECK"
echo "=============="

gen_input | hledger balance -f - --tree \
                    'income:employer' 'p60:gross pay' \
                    'p60:tax paid' 'p60:national' \
    -b $year-04-06 -e $year2-04-06 # end date is not inclusive
echo

