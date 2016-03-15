#!/bin/bash

type=$1 #"Coccolithovirus"
#samFile=$2 #"/home.westgrid/thea/watershed/viralShotgunHiSeq/VDNA/assembly/VDNA_HQ.min70_assembly.sam"
allReadsToContigs=$2
#fastaFile="/home.westgrid/thea/watershed/viralShotgunHiSeq/VDNA/megan/contigs_RNAViruses.fasta"
idFile=$4 #"/home.westgrid/thea/watershed/viralShotgunHiSeq/VDNA/assembly/meganFiltering/target_Coccolithovirus/Coccolithovirus.contigIds.txt"
#idFile="Contigs_$type-ids.txt"

headerFile=$3 #"~/watershed/viralShotgunHiSeq/VDNA/assembly/meganFiltering/header.txt"
cd target_$type

#filteredSamFile=$(basename $samFile)"_$type.sam"
readIdFile="$type-ReadIds.txt"
contigToReadsFile="ContigToReads_$type.txt"
contigToSamplesFile="ContigToSamples_$type.txt"
contigToSampleCountFile="ContigToSampleCounts_$type.txt"

echo "Prepping IDs..."
#grep ">" $fastaFile | sed 's/>//' | cut -f 1 -d " " > $idFile
sed -i 's/_contig_/contig/' $idFile 

echo "Filtering reads-to-contigs file..."
grep -Fwf $idFile $allReadsToContigs > $contigToReadsFile".TMP" #column order here is read, contig
awk '{print $2 "\t" $1}' $contigToReadsFile".TMP" > $contigToReadsFile
rm $contigToReadsFile".TMP"

cut -f 2 $contigToReadsFile > $readIdFile

echo "Calculating sample-count per contig..."
sed 's/_[0-9.-][0-9.-]*$//' $contigToReadsFile > $contigToSamplesFile

sort $contigToSamplesFile | uniq -c | sed "s/\s\s*/\t/g" | awk '{print $2 "\t" $3 "\t" $1}' > $contigToSampleCountFile

# Prep for R
sed -i 's/^.*contig/contig/' $contigToSampleCountFile
sed -i 's/-/\t/g' $contigToSampleCountFile
cat $headerFile $contigToSampleCountFile > $contigToSampleCountFile.TMP; mv $contigToSampleCountFile.TMP $contigToSampleCountFile