#!/usr/bin/perl
use strict;
use warnings;

if ($#ARGV == -1) {
    &usage;
}

my $in_file1 = "";
my $in_file2 = "";
my $sampleID = "";
my $r1pairFq = "";
my $r1unpairFq = "";
my $r2pairFq = "";
my $r2unpairFq = "";

my %my_args = @ARGV;
for my $i (sort keys %my_args) {
    if ($i eq "-f") {
        $in_file1 = $my_args{$i};
    }
    elsif ($i eq "-r") {
        $in_file2 = $my_args{$i};
    }
    elsif ($i eq "-a") {
        $r1pairFq = $my_args{$i};
    }
    elsif ($i eq "-b") {
        $r1unpairFq = $my_args{$i};
    }
    elsif ($i eq "-c") {
        $r2pairFq = $my_args{$i};
    }
    elsif ($i eq "-d") {
        $r2unpairFq = $my_args{$i};
    }
    elsif ($i eq "-s") {
        $sampleID = $my_args{$i};
    }else {
        print "\nUnrecognized argument: $i\n\n";
        &usage;
    }
}
sub usage {
    print "\nUSAGE: ./splitIntoPairedUnpaired.pl\n\n";
    print "Parameters:\n";
    print "-f <input file>\t\tA fastq file R1 (forward)\n";
    print "-r <input file>\t\tA fastq file R2 (reverse)\n";
    print "-s <prefix>\t prefix for read names (ex sampleID)\n";
    print "-a <output file>\t name for fastq output file: paired R1\n";
    print "-b <output file>\t name for fastq output file: unpaired R2\n";
    print "-c <output file>\t name for fastq output file: paired R2\n";
    print "-d <output file>\t name for fastq output file: unpaired R2\n";
    exit;
}

print "Splitting R1 & R2 files into paired and unpaired.  Parameters:\ninput file 1= $in_file1\ninput file 2= $in_file2\n\n\n";

# read inputs
open R1, $in_file1 or die $!;
open R2, $in_file2 or die $!;

#out file names
my $r1pairIds = $sampleID."_R1_pair_ids.txt";
my $r1unpairIds = $sampleID."_R1_unpair_ids.txt";
my $r2pairIds = $sampleID."_R2_pair_ids.txt";
my $r2unpairIds = $sampleID."_R2_unpair_ids.txt";

open (R1PAIR, ">".$r1pairIds);
open (R2PAIR, ">".$r2pairIds);
open (R1UNPAIR, ">".$r1unpairIds);
open (R2UNPAIR, ">".$r2unpairIds);

# data shouldn't be sparse, so array is fine
# also, I don't want to hold all the data from both files in memory so I'll fetch the sequences by name with biopieces
my @idArr = ();

while(<R1>){
    if( $. % 4){
	chomp;
	my $line = $_;
	#just double check, phred lines could also start with this
	if($line =~ /^\@(.*)$/){
	    my $id = $1;
	    my $idNum = $id;
	    $idNum =~ /\D*(\d+)\.\d+/;
	    $idNum = $1;
	    $idArr[$idNum][1] = $id;
	}
    }
}

while(<R2>)  {
    if( $. % 4){
	chomp;
	my $line = $_;
	if($line =~ /^\@(.*)$/){
	    my $id = $1;
	    my $idNum = $id;
	    $idNum =~ /\D*(\d+)\.\d+/;
	    $idNum = $1;
	    $idArr[$idNum][2] = $id;
	}
    }
}

for(my $i = 0; $i<=$#idArr; $i++){
    if(defined $idArr[$i]){
	if(defined $idArr[$i][1] && defined $idArr[$i][2]){
	    print R1PAIR "$idArr[$i][1]\n";
            print R2PAIR "$idArr[$i][2]\n";
	}elsif(defined $idArr[$i][1]){
	    print R1UNPAIR "$idArr[$i][1]\n";
	}elsif(defined $idArr[$i][2]){
            print R2UNPAIR "$idArr[$i][2]\n";
        }
    }
}

# use seqtk to grab the sequences using their ids (biopieces is way too slow)
`/home/tva4/programs/seqtk/seqtk subseq $in_file1 $r1pairIds > $r1pairFq;`;
`/home/tva4/programs/seqtk/seqtk subseq $in_file2 $r2pairIds > $r2pairFq;`;
`/home/tva4/programs/seqtk/seqtk subseq $in_file1 $r1unpairIds > $r1unpairFq;`;
`/home/tva4/programs/seqtk/seqtk subseq $in_file2 $r2unpairIds > $r2unpairFq;`;

# delete the id files
#`rm $r1pairIds $r1unpairIds $r2pairIds $r2unpairIds`;
