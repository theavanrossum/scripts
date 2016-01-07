#!/bin/bash

#for f in 34 42 50 85; do cp AGS_"$f"k/topResults/topResults.txt topResults/topResults_AGS"$f"k.txt; done
mkdir /home/tva4/watershedMetagenomics/analysis/viral/VDNA/phaccs/topResults

for ags in 15 34 42 50 85;
do 
cd /home/tva4/watershedMetagenomics/analysis/viral/VDNA/phaccs/AGS_"$ags"k_1G
mkdir topResults
cp *-VDNA/phaccs*.txt topResults
cd topResults

outName="topResults_"$ags"k_1G.txt"
errName="modelNotFound_"$ags"k_1G.txt"
echo "" >  $outName; 
echo "" >  header.txt ; 
grep -L "Optimal model not found" phaccs_*.txt > okFiles.txt

while read f
do 
  rand=$RANDOM
  paste $outName <(sed '1,11d' $f) > tmp$rand; 
  mv tmp$rand $outName; 
  paste header.txt <(echo "$f") > tmp$rand; 
  mv tmp$rand header.txt ;
done < okFiles.txt

#rm okFiles.txt
echo "Optimal model not found: please increase the maximum number of genotypes to search!" > $errName
grep -l "Optimal model not found" phaccs_*.txt >> $errName

cat header.txt $outName > tmp$rand; 
mv tmp$rand $outName

ln -s `pwd`/$outName /home/tva4/watershedMetagenomics/analysis/viral/VDNA/phaccs/topResults
ln -s `pwd`/$errName /home/tva4/watershedMetagenomics/analysis/viral/VDNA/phaccs/topResults
done

