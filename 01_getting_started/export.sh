#!/bin/bash
$(dirname $0)/export/export.hs -- -C $(dirname $0)/export -j --color "$@"
