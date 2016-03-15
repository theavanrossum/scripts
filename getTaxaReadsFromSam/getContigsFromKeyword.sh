meganContigToTaxPath=$2
keyword=$1 #"Oat.chlorotic.stunt.virus"
assemblyFasta=$3

mkdir target_$keyword
cd target_$keyword
grep "$keyword" $meganContigToTaxPath | cut -f 2 | sort | uniq > $keyword.matches.txt
grep "$keyword" $meganContigToTaxPath | cut -f 1  > $keyword.contigIds.txt 
~/programs/seqtk/seqtk subseq $assemblyFasta <(cat  $keyword.contigIds.txt | sed 's/contig/_contig_/') > $keyword.contigs.fa