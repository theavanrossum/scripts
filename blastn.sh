
queryFa="final.contigs.fa.longest10.fasta"
outFile="longest10.bn.out"


#only top hit, use: -num_alignments 1 -num_descriptions 1
~/programs/blast/ncbi-blast-2.2.29+/bin/blastn -db ~/databases/blast/2015-03-05/nt -query $queryFa -outfmt "6 qseqid qcovs sacc length pident stitle" -out $outFile -num_threads 8