#!/usr/bin/perl -w


use warnings;
use strict;
use Bio::SeqIO;
use Bio::Index::Fastq;

#---------------------------------------------------------------------------------------------------------------------------
#Deal with passed parameters
#---------------------------------------------------------------------------------------------------------------------------
if ($#ARGV == -1) {
    &usage;
}


my $in_file1 = "";
my $in_file2 = "";
my $sampleID = "";

my %my_args = @ARGV;
for my $i (sort keys %my_args) {
    if ($i eq "-f") {
	$in_file1 = $my_args{$i};
    }
    elsif ($i eq "-r") {
        $in_file2 = $my_args{$i};
    }
    elsif ($i eq "-s") {
        $sampleID = $my_args{$i};
    }
    else {
	print "\nUnrecognized argument: $i\n\n";
	&usage;
    }
}


print "Parameters:\ninput file 1= $in_file1\ninput file 2= $in_file2\n\n\n";
#---------------------------------------------------------------------------------------------------------------------------
#The main event
#---------------------------------------------------------------------------------------------------------------------------

my $newOutPairedR1 = Bio::SeqIO->new(-file => '>'.$sampleID."_R1_HQ_pair.fastq", -format => 'fastq');
my $newOutPairedR2 = Bio::SeqIO->new(-file => '>'.$sampleID."_R2_HQ_pair.fastq", -format => 'fastq');
my $newOutUnpairedR1 = Bio::SeqIO->new(-file => '>'.$sampleID."_R1_HQ_unpair.fastq", -format => 'fastq');
my $newOutUnpairedR2 = Bio::SeqIO->new(-file => '>'.$sampleID."_R2_HQ_unpair.fastq", -format => 'fastq');

my $seq_in1  = Bio::SeqIO->new( -format => 'fastq',-file => $in_file1);
my $seq_in2  = Bio::SeqIO->new( -format => 'fastq',-file => $in_file2);
my $seq_index1  = Bio::Index::Fastq->new( '-filename' => $in_file1.".idx", -write_flag => 1 );
my $seq_index2  = Bio::Index::Fastq->new( '-filename' => $in_file2.".idx", -write_flag => 1 );
$seq_index1->make_index($in_file1);
$seq_index2->make_index($in_file2);
#$newOut1->width(300);
#$newOut2->width(300);

while( my $seqObj1 = $seq_in1->next_seq() ) {
    my $seqID1 = $seqObj1->display_id;
    my $seqID2 = $seqID1;
    $seqID2 =~ s/1$/2/;
    
    my @ids = $seq_index2->get_all_primary_ids();
    my $seqObj2 = $seq_index2->get_Seq_by_acc($seqID2);

    if( $seqObj2){
	$newOutPairedR1->write_seq($seqObj1);
	$newOutPairedR2->write_seq($seqObj2);
    }else{	
        $newOutUnpairedR1->write_seq($seqObj1);
    }
}
while( my $seqObj2 = $seq_in2->next_seq() ) {
    my $seqID2 = $seqObj2->display_id;
    my $seqID1 = $seqID2;
    $seqID1 =~ s/2$/1/;
    my $seqObj1 = $seq_index1->get_Seq_by_id($seqID1);

    if(! defined $seqObj1){
        $newOutUnpairedR2->write_seq($seqObj2);
    }
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
