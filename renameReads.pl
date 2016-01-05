#!/usr/bin/perl -w


use warnings;
use strict;
use Bio::SeqIO;

#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}


my $in_file1 = "";
my $in_file2 = "";
my $out_file1 = "updated1.fasta";
my $out_file2 = "updated2.fasta";
my $sampleID = "";

my %my_args = @ARGV;
for my $i (sort keys %my_args) {
    if ($i eq "-i") {
	$in_file1 = $my_args{$i};
    }
    elsif ($i eq "-j") {
        $in_file2 = $my_args{$i};
    }
    elsif ($i eq "-o") {
	$out_file1 = $my_args{$i};
    }
    elsif ($i eq "-p") {
        $out_file2 = $my_args{$i};
    }
    elsif ($i eq "-s") {
        $sampleID = $my_args{$i};
    }

    else {
	print "\nUnrecognized argument: $i\n\n";
	&usage;
    }
}


print "Parameters:\ninput file 1= $in_file1\ninput file 2= $in_file2\noutput file 1 = $out_file1\noutput file 2 = $out_file2\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------

my $newOut1 = Bio::SeqIO->new(-file => '>'.$out_file1, -format => 'fastq');
my $newOut2 = Bio::SeqIO->new(-file => '>'.$out_file2, -format => 'fastq');
my $seq_in1  = Bio::SeqIO->new( -format => 'fastq',-file => $in_file1);
my $seq_in2  = Bio::SeqIO->new( -format => 'fastq',-file => $in_file2);
#$newOut1->width(300);
#$newOut2->width(300);

my $counter = 1;
while( my $seqObj1 = $seq_in1->next_seq() ) {
    my $seqObj2 = $seq_in2->next_seq();
       my $seqID1 = $seqObj1->display_id .' '. $seqObj1->desc;
	my $seqID2 = $seqObj2->display_id .' '. $seqObj2->desc;
	
	my $seqID2tmp = $seqID2;
	$seqID2tmp =~ s/2:N:0/1:N:0/;
#       $seqID2tmp =~ s/\/2/\/1/;

	if($seqID2tmp eq $seqID1){
	    $seqObj1->display_id($sampleID.'_'.$counter.'.1');
	    $seqObj1->desc("");
	    $seqObj2->display_id($sampleID.'_'.$counter.'.2');
            $seqObj2->desc("");
       	    $newOut1->write_seq($seqObj1);
	    $newOut2->write_seq($seqObj2);
	}
	else{
	    print "ERROR unmatched reads: $seqID1 & $seqID2 \n"
	    }
    $counter++;
}
while(my $seqObj2 = $seq_in2->next_seq()){
    my $t = $seqObj2->display_id .' '. $seqObj2->desc;
    print "ERROR left over reads: $t \n"
}

#-----------------------------------------------------------------------
sub usage {
    print "\nUSAGE: ./renamePairs.pl\n\n";
    print "Parameters:\n";
    print "-i <input file>\t\tA fastq file 1\n";
    print "-j <input file>\t\tA fastq file 2\n";
    print "-o <output file>\tThe new fastq 1 file to create\n";
    print "-p <output file>\tThe new fastq 2 file to create\n";
    print "-s <prefix>\t prefix for read names (ex sampleID)\n";
    exit;
}
