#!/bin/bash
set -e
set -o pipefail

. chapters.sh

function do_one() {
    c="$1"
    shift
    echo "Exporting in $c"
    (cd "$c"; if [ -x ./export.sh ] ; then ./export.sh "$@"; fi)
}
export -f do_one

parallel -k do_one {} "$@" ::: ${chapters[@]} 

