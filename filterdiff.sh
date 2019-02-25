#!/bin/bash
filterdiff -x '*/export/*.txt' -x '*/export/*.journal' \
           -x '*/import/*/csv/*' -x '*/import/*/journal/*.journal' \
           -x '*/import/*/generated.rules' \
           --remove-timestamps
