#!/bin/bash

keyword=$1 #"DNAViruses"
readIDFile=$2 #$keyword-ReadIds.txt"
fastaPaths=$3 #"/home.westgrid/thea/watershed/viralShotgunHiSeq/VDNA/reads/postqc_min70/*_HQ.min70.fasta"

outDir="target_$keyword/reads_$keyword"
mkdir $outDir

while read fasta
do
    sampleID=$( basename $fasta | cut -f 1 -d"_" )
#    echo $sampleID" " $(grep -cF $sampleID $readIDFile) " " $fasta
    ~/programs/seqtk/seqtk subseq $fasta <(grep -F $sampleID $readIDFile) > $outDir"/"$sampleID"_"$keyword".fasta"

done < $fastaPaths
