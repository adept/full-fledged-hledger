#!/bin/bash
set -e
set -o pipefail

. chapters.sh

startidx="${3}"
: ${startidx:=0}

for c in $(seq $startidx $(( ${#chapters[@]} - 2)) ) ; do
    n=$(( $c + 1 ))
    curr=${chapters[$c]}
    next=${chapters[$n]}
    
    echo "$curr -> $next"
    git add -N ${storydir}/${curr}
    git diff ${storydir}/${curr} | patch -d ${storydir}/${next} -p2 --merge=diff3 -V never || \
        {
        sed -i -e 's#<<<<$#<<<< MINE#; s#>>>>$#>>>> OTHER#; s#||||$#|||| ANCESTOR#' \
            $(ag -l '<<<<|>>>>' ${storydir}/${next})
        echo 
        echo "Resolve conflicts in ${storydir}/${next}"
        echo "Restart with $0 $storydir $diffdir $n"
        exit 1
        }
    git add -N ${storydir}/${next}
done
echo "DONE"
