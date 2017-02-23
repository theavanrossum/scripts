#!/bin/bash

outPrefix="vdnaDeNovo_filteredDNAviralGenomes"
#outPrefix="vdnaDeNovo_filteredDNAviral"
topdir=/home.westgrid/thea/watershed/viralShotgunHiSeq/VDNA/proteinClusters/deNovo/alnReadsVsRepSeqs/onlyDNAviralFromRAPSearchVsViralGenomes
#topdir=/home.westgrid/thea/watershed/viralShotgunHiSeq/VDNA/proteinClusters/deNovo/alnReadsVsRepSeqs/onlyDNAviral
repSeqs=/home.westgrid/thea/watershed/viralShotgunHiSeq/VDNA/proteinClusters/deNovo/clusterReferenceSeqs/rapsearchVsViralGenomes/VDNA_deNovo.clstr.repSeqs.dnaViral.origNames.fa
#repSeqs=/home.westgrid/thea/watershed/viralShotgunHiSeq/VDNA/proteinClusters/deNovo/clusterReferenceSeqs/VDNA_deNovo.clstr.repSeqs.dnaViral.renamed.fa
diamondResultsDir=$topdir/diamondResults/
m8suffix="statAndMultiFiltered.m8.dnaViralVsGenomes"
#m8suffix="statAndMultiFiltered.m8.dnaViral"

cd $topdir
allContigLengths=$repSeqs.lengths.txt

echo "getting rep seq lengths"
if [ ! -r $allContigLengths ]; then
python ~/scripts/getSequenceLengthsFromFasta.py -f $repSeqs
fi


for f in $diamondResultsDir/{035,087}*.$m8suffix
do 
echo $f
samp=$(basename $f | cut -f 2| cut -d"." -f1)
#cut -f 2 $f | sort | uniq -c | sed 's/[ ][ ]*/\t/g'| awk  -v sample="$samp" 'BEGIN{ OFS=","}{print sample,$2,$1}' > $f.contigAbund.csv ; 

awk 'BEGIN{OFS="\t"} NR==FNR{arr[$1]++; next} {print $0,arr[$1]}' $f $f |  cut -f 2,13 | sort | awk  -v sample="$samp" 'BEGIN{ OFS="\t"} {arr[$1]+=$2} END {for(var in arr) print var,sample,arr[var]}' > $f.contigAbund.tsv

awk 'BEGIN{OFS="\t"} NR==FNR{arr[$1]++; next} {print $0,arr[$1]*$4}' $f $f |  cut -f 2,13 | sort | awk  -v sample="$samp" 'BEGIN{ OFS="\t"} {arr[$1]+=$2} END {for(var in arr) print var,sample,arr[var]}' > $f.contigAbundAlnLen.tsv

# get number of times read hits to contigs so its weight can be split among hits
# get weighted contig abundance

awk 'BEGIN{OFS="\t"} NR==FNR{arr[$1]++; next} {print $0,1/arr[$1]}' $f $f |  cut -f 2,13 | sort | awk  -v sample="$samp" 'BEGIN{ OFS="\t"} {arr[$1]+=$2} END {for(var in arr) print var,sample,arr[var]}' > $f.contigAbundSplitReads.tsv

awk 'BEGIN{OFS="\t"} NR==FNR{arr[$1]++; next} {print $0,1/arr[$1]*$4}' $f $f |  cut -f 2,13 | sort | awk  -v sample="$samp" 'BEGIN{ OFS="\t"} {arr[$1]+=$2} END {for(var in arr) print var,sample,arr[var]}' > $f.contigAbundSplitReadsAlnLen.tsv

done



echo "concatenating"

mkdir $topdir/abundTables
mkdir $topdir/abundTables/multiCountMultiHits
mkdir $topdir/abundTables/splitCountMultiHits

cat $diamondResultsDir/*.contigAbund.tsv > abundTables/multiCountMultiHits/"$outPrefix"ContigAbund.tsv
cat $diamondResultsDir/*.contigAbundAlnLen.tsv > abundTables/multiCountMultiHits/"$outPrefix"ContigAbundAlnLen.tsv
cat $diamondResultsDir/*.contigAbundSplitReads.tsv > abundTables/splitCountMultiHits/"$outPrefix"ContigAbundSplitReads.tsv
cat $diamondResultsDir/*.contigAbundSplitReadsAlnLen.tsv > abundTables/splitCountMultiHits/"$outPrefix"ContigAbundSplitReadsAlnLen.tsv




for inputFile in $topdir/abundTables/*/"$outPrefix"ContigAbund*.tsv
do
    cd $(dirname $inputFile)

    echo "in $(pwd)"
    echo "processing $inputFile"
#vcdnaDeNovoProtClust_filteredContigAbundSplitReads.tsv
#inputFile="vdnaProtClust_filteredContigAbundSplitReadsAlnLen.tsv"

    echo "table-ifying"
    /home.westgrid/thea/programs/R/R-3.2.1/bin/Rscript ~/scripts/samToNormalisedAbundanceTable/longToWide_cast.R $inputFile




#echo "getting contig lengths"
# use python script 
#allContigLengths=/home.westgrid/thea/watershed/HiSeq.GSC.20140506-all/VcDNA/proteinClusters/deNovo/VcDNA_deNovo.repSeqs.fa.lengths.txt

    echo "normalising unrarefied by contig length"
    /home.westgrid/thea/programs/R/R-3.2.1/bin/Rscript ~/scripts/samToNormalisedAbundanceTable/normaliseAbundanceByContigLength.R ${inputFile}_wide.tsv $allContigLengths


#################
### NOT RAREFYING
#################
    if false; then

	echo "rarefying"
	/home.westgrid/thea/programs/R/R-3.2.1/bin/Rscript ~/scripts/samToNormalisedAbundanceTable/rarefactionRepeated.R ${inputFile}_wide.tsv
	rarefiedFile=${inputFile}_wide.tsv-rarefied[0-9][0-9*].csv

	echo "normalising rarefied by contig length"
	/home.westgrid/thea/programs/R/R-3.2.1/bin/Rscript ~/scripts/samToNormalisedAbundanceTable/normaliseAbundanceByContigLength.R $rarefiedFile $allContigLengths

    fi

done

echo "Finished gettting abundances"