#!/bin/bash

# ls /home.westgrid/thea/watershed/MiSeq.BCCDC.2014_bacShot/reads/postqc/subsample/*_HQ.min100.sub418.fasta > inputFiles.txt
# nohup bash cmd.sh inputFiles.txt 6  /home.westgrid/thea/watershed/viralShotgunHiSeq/VDNA/kmerJellyfish/k6mer_VDNA_515k& 

inputFiles=$1
merD=$2
outDir=$3

mer=$merD"mers"
threads=16


mkdir $outDir

while read inputReads
do

    jellyfish count -m $merD -s 100M -t $threads -C $inputReads -o $inputReads.$mer.jf
    jellyfish dump $inputReads.$mer.jf > $inputReads.$mer.Counts.fa

    mv $inputReads.$mer* $outDir

# use bloom filter to avoid reporting kmers that only occur once -- likely sequencing errors
#jellyfish bc -m $merD -s 40G -t 16 -o $inputReads.$mer.bc -C $inputReads
#jellyfish count -m $merD -s 4G -t 16 --bc $inputReads.$mer.bc  -C $inputReads 

done < $inputFiles

cd $outDir

for f in *.$mer.Counts.fa; do cat $f | paste - - | sed 's/>//g' | awk '{print $2,$1}' > $f.txt; done

sed -i "s/ /\t/g" *.$mer.Counts.fa.txt

