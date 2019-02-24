#!/bin/bash
filterdiff -x '*/export/*.txt' -x '*/export/*.journal' \
           -x '*/import/*/csv/*' -x '*/import/*/journal/*.journal' \
           --remove-timestamps
