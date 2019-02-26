# Read pipe-separated file of "regex|account|comment" lines,
# collate regexps together by (account,comment) and print result
# as a file of hledger rules:
#
# if
# regex1
# regex2
# ...
# regexN
#   account2 <account>
#   comment  <comment>
#
function add_regex(account,comment,rex){
    if(regexs[account,comment]=="") {
        regexs[account,comment]=rex
    } else {
        regexs[account,comment]=regexs[account,comment] "\n" rex
    }
}
/^[^# ]/{add_regex($2,$3,$1)}
END {
    for(key in regexs) {
        split(key,parts,/\034/);
        account=parts[1];
        comment=parts[2];
        print "\nif\n" regexs[key];
        if (account!="") {print "  account2  " account}
        if (comment!="") {print "  comment   " comment}        
    }
}
