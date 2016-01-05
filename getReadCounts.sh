#!/usr/bin/bash

matchStr="*-VDNA_HQ.min100.fasta"

grep -c \"">"\" $matchStr | sed 's/:/\t/' | sort -gr -k2 > readCounts_VDNA-min100_$RANDOM.txt