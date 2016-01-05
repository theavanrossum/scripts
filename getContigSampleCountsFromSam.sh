
samFile="VDNA_HQ.min70_assembly.sam"
grep -v "^@" $samFile | cut -f 1 -d "_" > $samFile.sampleIds
grep -v "^@" $samFile | cut -f 3 > $samFile.contigIds 

paste $samFile.contigIds $samFile.sampleIds | sort | uniq -c | sed -r "s,\s\s*,\t,g" | awk '{print $2 "\t" $3 "\t" $1}' > $samFile.contigSampleCounts.tsv
