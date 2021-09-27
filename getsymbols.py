#!/usr/bin/env python3
import re

with open("ewoz.lst", 'rt') as fh:
    marker = False

    for line in fh:
        if not marker:
                if re.search('Labels by address:', line):
                    marker = True
        else:
            tokens = line.split(" ")
            print("{}\t= ${}".format(tokens[1].strip(), tokens[0]))
fh.close()


