#!/bin/bash
set -e -o pipefail

cat ./export/*-accounts.txt | sort -u > /tmp/accounts.txt

while true ; do
    # Choose one of the unknown transactions' description
    description_account=$(cat ./export/*unknown.journal \
                      | hledger -f - register -I -O csv \
                      | grep -v ":unknown" \
                      | grep -v -f <(cat ./import/*/rules.psv | cut -d'|' -f1 ) \
                      | csvtool col -u '|' 2,4-6 -  \
                      | sk --header="Choose transaction" --tac -d '\|' --header-lines=1 --nth 2 \
                      | csvtool col -t '|' 2,3 - \
                      | sed -e 's/[*]/./')

    # Description_account is "<description>,<source account that money came from>"
    # We can use account to figure out which rules file we need to modify
    account=$(echo "${description_account}" | csvtool col 2 -)
    description=$(echo "${description_account}" | csvtool col 1 -)
    case "${account}" in
        assets:Lloyds*)
            dir="./import/lloyds/" ;;
        expenses:amazon)
            dir="./import/amazon/" ;;
        assets:temp:Paypal*)
            dir="./import/paypal/" ;;
        *)
            echo "Unknown source dir for ${account}"; exit 1 ;;
    esac   

    # Description as it is often can't be used as regexp.
    # It could contain special character or can match too many lines.
    # This step allow us to fine-tune it, by seeing what it matches in real time
    regexp=$(sk --header="Fine-tune regexp. Searching in ${dir}/*.rules and ${dir}/csv" \
                --cmd-query="${description}" --print-cmd --ansi -i \
                --bind 'ctrl-d:delete-char' \
                -c "rg -i --color=always --line-number \"{}\" $(ls ${dir}/*.rules | paste -s -d' ') ${dir}/rules.psv ${dir}/csv" | head -n1)

    # Now lets choose account
    account=$(cat /tmp/accounts.txt | sort -u | sk --header="Choose account")

    cat ${dir}/rules.psv | cut -d '|' -f3 | sort -u > /tmp/comments.txt

    # ... and comment. Comment could be either selected from existing comments
    # or just entered. When entered comment is a substring match of one of the existing comments,
    # you can prepend your comment with ":" to prevent the match from being selected
    comment=$((sk --header="Enter comment (prepend : to inhibit selection)" --print-cmd --ansi -i \
                  -c "rg --color=always --line-number \"{}\" /tmp/comments.txt" || true) | tail -n1 | sed -e 's/^[0-9]*://')
    
    echo "${regexp}|${account}|${comment}" >> "${dir}/rules.psv"
done
