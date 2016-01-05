#!/bin/bash

d="/home.westgrid/thea/watershed/HiSeq.GSC.20140506-all/VcDNA/clustering/VcDNAclusters_95/clusters95_min1000"
prefix="VcDNA-CDHIT-95"

for f in $d/*.fa
do
grep ">" $f | sed 's/_.*//g' | sed 's/>//g' | sort | uniq -c > $f.sampleCounts

done;

cd $d

sed -i 's/^ [ ]*\([0-9][0-9]*\) [ ]*\([A-Za-z0-9_-][A-Za-z0-9_-]*\)/\2 \1/g' *.sampleCounts
sed -i 's/ /\t/g'  *.sampleCounts
~/programs/metaphlan/utils/merge_metaphlan_tables.py *.sampleCounts > counts.txt


# sample IDs to numbers
sed '2,$s/[A-Za-z-]//g' counts.txt > counts_forR.txt
sed -i 's/^0//g' counts_forR.txt
sed -i 's/^0//g' counts_forR.txt
sed -i 's/\.//g' counts_forR.txt
sed -i '1s/^/SampleNumber/' counts_forR.txt

#cluster file names to  IDs
bash ~/scripts/transpose.sh counts_forR.txt > tmp
#sed -i '2,$s/^[A-Za-z-]/CDH_/' tmp
mv tmp counts_forR.txt


mv counts_forR.txt $prefix"_counts_forR.txt"
mv counts.txt $prefix"_counts.txt"
rm *.fa.sampleCounts