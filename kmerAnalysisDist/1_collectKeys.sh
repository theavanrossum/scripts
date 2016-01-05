#!/bin/bash

echo -n "" > kmers.txt
START=$(date +%s.%N)
for f in *.Counts.fa.txt.min2.txt
do
    STARTF=$(date +%s.%N)
    echo -n $f
    sort --merge kmers.txt <( cut -f 1 $f | sort ) | uniq > kmers.tmp
    mv kmers.tmp kmers.txt
    ENDF=$(date +%s.%N)
    DIFFF=$(echo "$ENDF - $STARTF" | bc)
    echo -e "\t" $DIFFF
done
END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo $DIFF