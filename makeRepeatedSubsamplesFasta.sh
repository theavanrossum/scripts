#!/bin/bash

numIter=25
homeDir=/home.westgrid/thea/watershed/HiSeq.GSC.20140506-all/VcDNA/reads/postQC-RemovedRRNA/fromSubset590k/subsample-45k/

fileSuffix="45k.fa"
subSize=10
subSizeStr=10 #10k
inputFiles=$homeDir/*-VcDNA_HQ.min100*$fileSuffix


outDir=$homeDir/sub$subSize
mkdir $outDir

for i in $(seq $numIter)
do

    echo $i 
    seed=$RANDOM
#    seed=11
    mkdir $outDir/iter$i

    for f in $inputFiles
    do
	~/programs/seqtk/seqtk sample -s $seed $f $subSize > $outDir/iter$i/$(basename $f | sed "s/.$fileSuffix/.$subSizeStr.fa/" )

    done

done

echo "Files created in " $outDir