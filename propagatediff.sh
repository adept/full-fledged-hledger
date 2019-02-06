#!/bin/bash
set -e
set -o pipefail

storydir="${1}"
diffdir="${2}"
startidx="${3}"

: ${storydir:="./story"}
: ${diffdir:="./diffs"}
: ${startidx:=0}

chapters=($(ls -1 "${storydir}/[0-9]*"))

for c in $(seq $startidx $(( ${#chapters[@]} - 2)) ) ; do
    n=$(( $c + 1 ))
    curr=${chapters[$c]}
    next=${chapters[$n]}
    
    echo "$curr -> $next"
    git diff ${storydir}/${curr} | patch -d ${storydir}/${next} -p3 --merge=diff3 -V never || \
        {
        sed -i -e 's#<<<<$#<<<< MINE#; s#>>>>$#>>>> OTHER#; s#||||$#|||| ANCESTOR#' \
            $(ag -l '<<<<|>>>>' ${storydir}/${next})
        echo 
        echo "Resolve conflicts in ${storydir}/${next}"
        echo "Restart with $0 $storydir $diffdir $n"
        exit 1
        }
done
