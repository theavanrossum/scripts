#!/bin/bash

for f in  *.*mers.Counts.fa.txt
do

#sed "/^[A-Z][A-Z]*\t1$/d" $f > $f.rm1.txt 
grep -v "^[ATGC][ATGC]*\s\s*1$" $f > $f.min2.txt #faster

done