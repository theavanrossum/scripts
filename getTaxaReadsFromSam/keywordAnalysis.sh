
keyword="cellular"

#VDNA
homeDir=/home.westgrid/thea/watershed/viralShotgunHiSeq/VDNA/megan/completeish/meganFiltering/
samFile=/home.westgrid/thea/watershed/viralShotgunHiSeq/VDNA/assembly/VDNA_HQ.min70_assembly.sam
taxaFile=/home.westgrid/thea/watershed/viralShotgunHiSeq/VDNA/megan/completeish/002-UDS-VDNA.rap.0001.out-all.txt
assemblyFasta=/home.westgrid/thea/watershed/HiSeq.GSC.20140506-all/VDNA/assembly/VDNA_HQ.min70_assembly.fa
fastaPaths=$homeDir/fastaPaths$RANDOM.txt
ls /home.westgrid/thea/watershed/viralShotgunHiSeq/VDNA/reads/postqc_min70/*.fasta > $fastaPaths


## VcDNA
#homeDir=/home.westgrid/thea/watershed/viralShotgunHiSeq/VcDNA/assembly/meganFiltering/
#samFile=/home.westgrid/thea/watershed/viralShotgunHiSeq/VcDNA/assembly/VcDNA_HQ.min100_assembly.sam
#taxaFile=/home.westgrid/thea/watershed/viralShotgunHiSeq/VcDNA//assembly/meganFiltering/VcDNA.rap.ppp1.outv2-ex_readToTaxa.txt
#assemblyFasta=/home.westgrid/thea/watershed/HiSeq.GSC.20140506-all/VcDNA/assembly/VcDNA_HQ.min100_assembly.fa
#fastaPaths=$homeDir/fastaPaths$RANDOM.txt
#ls /home.westgrid/thea/watershed/viralShotgunHiSeq/VcDNA/reads/postQC-RemovedRRNA/fromAll/*cleaned.fasta > $fastaPaths


headerFile="/home.westgrid/thea/scripts/getTaxaReadsFromSam/header.txt"
scriptDir="/home.westgrid/thea/scripts/getTaxaReadsFromSam/"

cd $homeDir

idFile="$homeDir/target_$keyword/$keyword.contigIds.txt"
readIdsFile="$homeDir/target_$keyword/$keyword-ReadIds.txt"
samContigsToReads=$samFile"_readsToContigs.txt"

echo "Getting matching taxa for \"$keyword\"..."
bash $scriptDir/getContigsFromKeyword.sh $keyword $taxaFile $assemblyFasta

if [ -s "$idFile" ] #if the file is not empty - i.e. some contigs match the keyword
    then

    if [ ! -s $samContigsToReads ]
	then
	echo "Processing SAM file..."
	# just keep readIds and contig names from the sam file to make fetching reads faster
	cut -f1,3 $samFile | grep -v "^@" > $samContigsToReads
    fi
        echo "Getting read ids from SAM file..."
	bash $scriptDir/getReadIdsFromSAM_fromContigs.sh $keyword $samContigsToReads $headerFile $idFile
	echo "Getting read sequences from source fastas..."
	bash $scriptDir/getReadsFromFastaFiles.sh $keyword $readIdsFile $fastaPaths

    else
	echo "No matches for $keyword in $taxaFile : $idFile"
fi
echo "Done!"