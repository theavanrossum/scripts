#!/bin/bash

NUM_FIELDS=9
MEGAN_FILE=/home.westgrid/thea//watershed/viralShotgunHiSeq/VDNA/megan/002/002-UDS-VDNA.rap.0001.out-all.txt

#cut -f1 $MEGAN_FILE | awk 'BEGIN{print "Contigs"}{print $0}' > $MEGAN_FILE.contigs.txt
cat $MEGAN_FILE | cut -f 2 | sed 's/"//g'| sed 's/;$//' | awk '
BEGIN{ OFS="";
       ORS="";
       FS=";"; 
       print "LowestClassification\tSuperKingdom\tKingdom\tGenome\tBaltimore\tOrder\tFamily\tSubfamily\tGenus\tSpecies\t\n";
       NUM_FIELDS='$NUM_FIELDS'} 
{ print $NF "\t"
       for(i=1;i<=NUM_FIELDS;++i){
          if( length($i) >0 ) print $i "\t"
          else print "Unclassified" "\t"
       }
  print "\n"
}' |sed 's/\t$//' | paste - <(cut -f1 $MEGAN_FILE | awk 'BEGIN{print "Contig"}{print $0}') > $MEGAN_FILE.formatted.txt

#> $MEGAN_FILE.taxa.txt
#paste -d"" $MEGAN_FILE.taxa.txt $MEGAN_FILE.contigs.txt > $MEGAN_FILE.formatted.txt