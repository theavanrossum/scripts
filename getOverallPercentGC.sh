#!/usr/bin/bash

# takes location of fasta files as input
# print to stdout a tab delimited list with the first column as the names of files 
# and the second as the %GC in the file

#inputDir="/home.westgrid/thea/watershed/viralShotgunHiSeq/VDNA/reads/postqc_sub515k"
inputDir=$1

for f in `ls $inputDir/*.f*a`
do
    echo -n $(basename $f)
    gc=$(grep -v ">" $f | tr -cd [GC] | wc -c)
    all=$(grep -v ">" $f | wc -c)
    pGC=$(awk "BEGIN { print $gc/$all}" )
#    echo $gc
#    echo $all
    echo -e "\t"$pGC
done

