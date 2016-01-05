#!/bin/bash

ident="95"
minSize="1000"

inputReads="/home.westgrid/thea/watershed/viralShotgunHiSeq/VcDNA/reads/postQC-RemovedRRNA/subset590k/subsample-45k/all.VcDNA.rmRRNA.min100.45k.fa"
homeDir="/home.westgrid/thea/watershed/viralShotgunHiSeq/VcDNA/clustering/VcDNAclusters_95"

clustersSorted=$homeDir"/all.VcDNA.rmRRNA.min100.45k.c"$ident".clstr.clstr.sorted"
outDir=$homeDir"/clusters"$ident"_min"$minSize

cd $homeDir

/home.westgrid/thea/programs/cd-hit/cd-hit-v4.6.4-2015-0603/make_multi_seq.pl $inputReads $clustersSorted $outDir $minSize

cd $outDir
rename "s/^/VcDNAc$ident-/" [0-9]*
rename 's/$/.fa/' VcDNAc*