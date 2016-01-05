#!/bin/bash

for f in *.Counts.fa.txt.min2.txt
do
echo $f
# get those keys missing from the file and add them to the file with a zero count
sort --merge $f <(grep -Fwv -f <(cut -f1 $f) kmers.txt | sed 's/$/\t0/') > $f.complete

done