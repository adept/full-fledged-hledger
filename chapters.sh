storydir="${1}"
diffdir="${2}"

: ${storydir:="."}
: ${diffdir:="./diffs"}

chapters=($(ls -1dH "${storydir}"/[0-9]*))
