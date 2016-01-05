#!/bin/bash

#fastq
awk '{if(NR%4==2) print length}' $1 | sort -g | uniq -c | sed 's/^[ ]*//g' | awk '{ t=$1 ; $1=$2; $2=t; print }' | sed 's/ /\t/g' > $1.counts

#fasta - assumes each read on one line (i.e. read isn't split across lines)
#cat $1 | grep -A1 "^>" | grep -v "^>" | sed '/--/d' | grep -v '^$' | awk '{print length}' | sort -g -k2 | uniq -c | sed 's/^[ ]*//g' | awk '{ t=$1 ; $1=$2; $2=t; print }' | sed 's/ /\t/g' > $1.counts

#run this with results
#python ~/programs/metaphlan/utils/merge_metaphlan_tables.py *.counts > test


#cat $1 | grep -A1 "@M" | grep -v "@M" | sed '/--/d' | grep -v '^$' | awk '{if (length($0) > 10 )} END {print length}' | sort | uniq -c > $1.counts