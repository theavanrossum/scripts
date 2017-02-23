
#dataType=VDNA
dataType="Bac"

#str=assDNA-PCvsViralGenomes_sub33k_min70bp
str=sub418k_exact100bp

# viral
#homeDir=/home.westgrid/thea/watershed/viralShotgunHiSeq/$dataType/mash/$str
#inputFiles=/home.westgrid/thea/watershed/viralShotgunHiSeq/$dataType/mash/$str/inputFastaFiles.txt

##inputFiles=/home.westgrid/thea/watershed/viralShotgunHiSeq/$dataType/mash/$str/inputFastaFiles_sub45kExact100bp.txt
##inputFiles=/home.westgrid/thea/watershed/viralShotgunHiSeq/$dataType/mash/$str/inputFastaFiles_$str.txt

# bacterial
homeDir=/home.westgrid/thea/watershed/bacterialShotgunMiSeq/mash/$str
inputFiles=/home.westgrid/thea/watershed/bacterialShotgunMiSeq/mash/$str/inputFastaFiles_$str.txt

sketchSize=1000000
sketchStr="s1G" #"s1G_min2" -u
kmer=21
refName=$dataType"_"$str"_"k$kmer"_"$sketchStr"_min2"




outdir=k$kmer"_s"$sketchSize

mkdir $homeDir
cd $homeDir
mkdir $outdir
cd $outdir

echo "sketch size = $sketchSize; kmer length = $kmer" > $outdir.out
#~/programs/mash/mash sketch -l $inputFiles -o $refName -s $sketchSize -k $kmer >> $outdir.out
~/programs/mash/mash sketch -m 2 -l $inputFiles -o $refName -s $sketchSize -k $kmer >> $outdir.out

#rm $refName-distances.txt
~/programs/mash/mash dist $refName.msh $refName.msh > $refName-distances.txt

#while read fasta
#do
#
#    ~/programs/mash/mash dist $refName.msh $fasta >> $refName-distances.txt
#
#done < $inputFiles

echo "Done"  >> $outdir.out
