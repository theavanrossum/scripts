#!/bin/bash

d="/home.westgrid/thea/watershed/viralShotgunHiSeq/VcDNA/clustering/VcDNAclusters_95/clusters95_min1000";

rm $d/*.siteCounts
rm $d/siteCounts.txt
rm siteNames.txt

echo "ADS" >> siteNames.txt
echo "APL" >> siteNames.txt
echo "AUP" >> siteNames.txt
echo "UDS" >> siteNames.txt
echo "UPL" >> siteNames.txt
echo "PUP" >> siteNames.txt
echo "PDS" >> siteNames.txt
echo "PWS" >> siteNames.txt
echo "NEG" >> siteNames.txt
echo "PC1" >> siteNames.txt
echo "Total" >> siteNames.txt



for f in $d/*.fa;
do
echo -n "" > $f.siteCounts
grep ">" $f | grep -c "ADS" >> $f.siteCounts
grep ">" $f | grep -c "APL" >> $f.siteCounts
#grep ">" $f | grep -v "047" $f | grep -c "AUP" >> $f.siteCounts
grep ">" $f | grep -c "AUP" >> $f.siteCounts
grep ">" $f | grep -c "UDS" >> $f.siteCounts
grep ">" $f | grep -c "UPL" >> $f.siteCounts
grep ">" $f | grep -c "PUP" >> $f.siteCounts
grep ">" $f | grep -c "PDS" >> $f.siteCounts
grep ">" $f | grep -c "PWS" >> $f.siteCounts
grep ">" $f | grep -c "NEG" >> $f.siteCounts
grep ">" $f | grep -c "PC1" >> $f.siteCounts
grep -c ">" $f >> $f.siteCounts

done;

paste siteNames.txt $d/*.siteCounts > $d/siteCounts.txt

rm $d/*.siteCounts