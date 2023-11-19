#!/usr/bin/env python3
import sys
import re

def main(rules_file, csv_file):
    with open(rules_file, 'r') as file:
        rules = [
            (line.split('|')[0], line)
            for line in file.read().splitlines()
        ]

    with open(csv_file, 'r') as file:
        contents = file.read()

    for re_pattern, full_rule in rules:
        rex = re.compile(re_pattern)
        if rex.search(contents):
            print(full_rule)

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
