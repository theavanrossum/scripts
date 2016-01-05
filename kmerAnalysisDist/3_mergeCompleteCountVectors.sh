#!/bin/bash

for f in *.complete
do
    sampleName=$(basename $f | sed 's/\..*//')
    echo $sampleName
    cat <(echo $sampleName) <(cut -f 2 $f) > $f.counts
done

echo "Creating merged file of all samples"
paste *.counts > all.Counts.min2.txt
echo "Creating subset file with only kmers with at least 10 counts across all samples (row sums > 10)"
awk '{s=0; for (i=1;i<=NF;i++) s+=$i; if (s>=10)print}' all.Counts.min2.txt > all.Counts.min2.minSum10.txt

