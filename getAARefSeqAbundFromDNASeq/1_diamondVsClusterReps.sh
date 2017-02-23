
### align reads to reference cluster sequences

workDir=/home.westgrid/thea/watershed/HiSeq.GSC.20140506-all/VDNA/proteinClusters/deNovo/alnReadsVsRepSeqs
refDir=/home.westgrid/thea/watershed/HiSeq.GSC.20140506-all/VDNA/proteinClusters/deNovo/clusterReferenceSeqs

#fastaDir=/home.westgrid/thea/watershed/HiSeq.GSC.20140506-all/VcDNA/reads/postQC-RemovedRRNA/fromAll
fastaDir=/home.westgrid/thea/watershed/HiSeq.GSC.20140506-all/VDNA/reads/postqc_min70

nproc=12

inputFile=$refDir/VDNA_deNovo.clstr.repSeqs.dnaViral.fa
diamondDatabaseName=VDNA_deNovo.clstr.repSeqs.dnaViral
diamondDatabase=$refDir/$diamondDatabaseName.dmnd

#in1=$refDir/tovAllVsVDNA_min30_clusterMatches.repSeqs.fa
#in2=$refDir/tovAllVsVDNA_min30-deNovoLeftOver.repSeqs.fa
#diamondDatabaseName=VDNA_TOV_and_deNovoLeftOver.repSeqs


cd $refDir

echo "building diamond db"
#cat $in1 $in2 > $diamondDatabaseName.fa
/usr/local/bin/diamond makedb -p 4 --in $inputFile -d $diamondDatabaseName

cd $workDir

echo "staring searches"

for f in $fastaDir/*.fasta;
#for f in test.fa
do

samp=$(basename $f | cut -f1 -d "_")
echo "Searching with $samp..."
diamond blastx -d $diamondDatabase -q $f -a $samp -t ~/tmp --threads $nproc
echo "Viewing..."
diamond view -a $samp.daa -o $samp.m8 --threads $nproc

done
