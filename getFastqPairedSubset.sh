#!/bin/bash

sub=10000
suffix="10k"

for f1 in *_R1_*.fastq;
do
seed=$((RANDOM%200+100))
f2=$(echo $f1 | sed 's/_R1_/_R2_/')
~/programs/seqtk/seqtk sample -s$seed $f1 $sub > $f1.$suffix.fq
~/programs/seqtk/seqtk sample -s$seed $f2 $sub > $f2.$suffix.fq
done


