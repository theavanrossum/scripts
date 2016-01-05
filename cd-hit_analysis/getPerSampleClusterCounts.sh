#!/bin/bash

# count the number of clusters in each sample (trying to get at alpha diversity...)

clstBak="all.VcDNA.rmRRNA.min100.45k.c95.clstr.bak.clstr"
sampleIDsFile="sampleIDs.txt"
outFile="all.VcDNA.rmRRNA.min100.45k.c95.sampleClusterCounts.txt"

#139878  100nt, >001-UPL-VcDNA_3506024.1... at -/98.00%
#446195  128nt, >001-UPL-VcDNA_6787000.1-2... *
cut -f 2 -d">" $clstBak | cut -f 1 -d"_" | sort | uniq > $sampleIDsFile

cat $clstBak | cut -f 1 |sort | uniq -d > $clstBak.minSize2ClusterIDs
#sed -i 's/^/^/' $clstBak.minSize2ClusterIDs
#grep -w -f $clstBak.minSize2ClusterIDs $clstBak > $clstBak.noSingletons

echo -e "SampleID\tcountAll\tcountNoSingle" > $outFile
while read sampleID
do

countAll=$(cat $clstBak | grep -F $sampleID | cut -f 1 | sort | uniq | wc -l)
#countNoSingle=$(cat $clstBak.noSingletons | grep -F $sampleID | cut -f 1 | sort | uniq | wc -l)
countNoSingle=$(cat $clstBak | grep -F $sampleID | cut -f 1 | grep -Fx -f $clstBak.minSize2ClusterIDs | sort | uniq | wc -l)

echo -e "$sampleID\t$countAll\t$countNoSingle" >> $outFile

done < $sampleIDsFile

rm $sampleIDsFile