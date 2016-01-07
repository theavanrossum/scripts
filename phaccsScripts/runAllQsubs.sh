



inputList="/home/tva4/watershedMetagenomics/analysis/viral/VcDNA/phaccs/infoForQsubRuns.txt"
homeDir="/home/tva4/watershedMetagenomics/analysis/viral/VcDNA/phaccs"

#genomeSizeK="15"
for genomeSizeK  in 15 34 42 50 85
do
resultsDir="$homeDir/AGS_"$genomeSizeK"k_1G"
genomeSize=$genomeSizeK"000"

mkdir $resultsDir
cd $resultsDir

while read sampleID cspFile;
do

echo "$sampleID $cspFile"

qsub -N phaccs$sampleID  -v SAMPLE_ID="$sampleID",CSP_FILE="$cspFile",GENOME_SIZE="$genomeSize",GENOME_SIZE_K="$genomeSizeK",RESULTS_DIR="$resultsDir" /home/tva4/scripts/phaccsScripts/phaccs.qsub 

done < $inputList

done #  ags loop