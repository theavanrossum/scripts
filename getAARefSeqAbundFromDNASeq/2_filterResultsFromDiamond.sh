#!/bin/bash

for m8File in /home.westgrid/thea/watershed/viralShotgunHiSeq/VDNA/proteinClusters/deNovo/alnReadsVsRepSeqs/diamondResults/*-VDNA.m8
do
cd /home.westgrid/thea/watershed/viralShotgunHiSeq/VDNA/proteinClusters/deNovo/alnReadsVsRepSeqs/diamondResults/
echo "$m8File"
# percent identity needs to be at least 60%

# length of alignment has to be at least 80% of read, 
# assuming shortest read length (=100bp) then 80% is 26.6 aa
# aln needs to be >= 26 aa

awk '{ if( $3 >= 60 && $4 >= 26 ) print $0}' $m8File > $(basename $m8File).statFiltered.m8

# NOT USING
## if it's the first row or the top hit, just print it
## otherwise print it if it's within 50% of the top hit's evalue
#awk '{ if(qID!=$1){topHitEval=$11; print $0;}else{ if( $11 < topHitEval+(topHitEval*0.5) ){ print $0} }; qID=$1; }' $m8File.statFiltered.m8 > $m8File.statAndEvalFiltered.m8

# USING
## use bit score
## only keep 1 hit per read-contig pair
## print it if it's within 10% of the top hit's bit score
awk '{ if(NR ==1 || qID!=$1){topHitBitScore=$12; print $0;}else{ if( $2 != cID &&  $12 > topHitBitScore-(topHitBitScore*0.1) ){ print $0} }; qID=$1; cID=$2 }'  $(basename $m8File).statFiltered.m8 >  $(basename $m8File).statAndMultiFiltered.m8

done
echo "Done!"


# example why I'm using bit score
#014-NEG-VcDNA_160.1-2   001-UPL-VcDNA_HQ.min100_contig_488675_1 69.7    33      2       1       7       105     1       25      3.5e-06 48.9
#014-NEG-VcDNA_160.1-2   001-UPL-VcDNA_HQ.min100_contig_107444_1 57.5    40      5       1       86      3       61      100     7.9e-06 47.8
#014-NEG-VcDNA_160.1-2   001-UPL-VcDNA_HQ.min100_contig_495924_1 73.1    26      6       1       98      24      12      37      1.1e-04 43.9
#014-NEG-VcDNA_160.1-2   001-UPL-VcDNA_HQ.min100_contig_13871_1  66.7    27      9       0       125     45      52      78      7.4e-04 41.2
#014-NEG-VcDNA_160.1-2   001-UPL-VcDNA_HQ.min100_contig_765755_1 81.0    21      4       0       107     45      70      90      7.4e-04 41.2
