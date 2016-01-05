#!/usr/bin/perl

#########################
# Thea Van Rossum
# 2014/05/05
# This script executes a QC pipeline. It calls tools to
# 0. rename reads according to their file name 
# 1. trim sequences based on quality 
# 2. trim adapter sequences
# 3. trim primer sequences
# 4. merge paired end reads
# 5. filter merged sequences based on length. 
# It assumes you have all your fastq raw files in one directory (default is `pwd`/reads/raw) and will create directories in the "project home" directory (default is `pwd`)
# The results of each step in the QC pipeline will be stored in the "work" subdirectory of each step-specific directory
# FastQC will be run after every step of the QC, the results an be found in the "QC" subdirectories
# Read length histogram files are generated after later steps in the pipeline, they are sotred in files with the suffix "count"
##########################



use strict;
use Cwd qw(abs_path getcwd);
use Getopt::Long;
use Data::Dumper;
use File::Find;
use File::Basename;

my $submit = 1; # set to 0 if you want to make the qsub files but not run them immediately
my $mkdir = 1; # if you're running this a 2nd time and the directories are all created, set this to 0

my $mgMem = '4000';
my $hrs = '72';
my $email = 'theajobreports@gmail.com';

my $minQualityForWindow = 20;
my $windowLength = 5;
my $minQualityLeading = 20;
# bacterial shotgun nexteraXT
my $adapterR1 = "TGTCTCTTATACACATCTCCGAGCCCACGAGAC";
my $adapterR2 = "CTGTCTCTTATACACATCTGACGCTGCCGACGA";
#viral
#my $adapterR1 = "AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC";
#my $adapterR2 = "AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTA";
# TruSeq
#my $adapterR1 = "GATCGGAAGAGCACACGTCTGAACTCCAGTCAC";
#my $adapterR2 = "AATGATACGGCGACCACCGAGATCTACAC";

my $trimPrimers=0; # set to 0 if not trimming primers
my $primerF = ""; 
my $primerR = "";
#my $primerF = "GTTTCCCACTGGAGGATA"; #uncomment if trimming primers
#my $primerR = "TATCCTCCAGTGGGAAAC";
#my $primerF = "AYTGGGYDTAAAGNG"
#my $primerR = "TACNVGGGTATCTAATCC"

my $minLength = 100;
my $isGzipped = 0;

my $runPrePrimerTrim = 1;
my $runPreMinLength = 1;
my $runMetaphlan1=1; # set to 0 if you don't want to run MetaPhlAn v1 on the QC results
my $runMetaphlan2=1;# set to 0 if you don't want to run MetaPhlAn v2 on the QC results
my $runRTM=1; # set to 0 if you don't want to run RTM on the QC results

my $renameReadsScript = "renameReads.pl"; # For MiSeq
#my $renameReadsScript = "renameReadsHiSeq.pl";

my $jobName;

# Find absolute path of script
#my($scriptname, $directory) = fileparse(abs_path($0));
my $directory = `pwd`;

sub usage {
    print "perl makeQsubs_QC-TrimLQ-TrimAdap-MergePairs-single_1.5.pl --homeDir  <home directory of project, default is current directory> --fasta <location of fastq files, default is reads/raw>  \n";
    exit;
}

my ($fastaDir, $workdir, $verbose, $homeDir, $trimLowQualDir, $trimAdapDir,  $minLengthDir, $mergePairsDir, $renameReadsDir,  $trimmoLowQualOutDir, $cutadaptOutDir, $metaphlanDir, $rtmDir, $trimPrimerOutDir, $trimPrimerDir);

MAIN: {
    my ($help);
    my $res = GetOptions(
	"verbose"  => \$verbose, 
	"help" => \$help,
	"submit" => \$submit,
	'homeDir:s' => \$homeDir,
	'fasta:s' => \$fastaDir,
	                 );
    if( !defined $homeDir ){
	$homeDir = $directory;
    } 
    if( !defined $fastaDir ){
        $fastaDir = $homeDir.'/reads/raw';
    }

    $workdir = $homeDir.'/work';
    $renameReadsDir = $homeDir.'/1_renameReads';
    $trimLowQualDir = $homeDir.'/2_trimLowQuality';
    $trimAdapDir = $homeDir.'/3_trimAdapters';
    $mergePairsDir = $homeDir.'/4_mergePairs';
    $minLengthDir = $homeDir.'/5_minLength';
    $metaphlanDir = $homeDir.'/metaphlan';
    $rtmDir = $homeDir.'/rtm';

    $trimmoLowQualOutDir = "$trimLowQualDir/work";
    $cutadaptOutDir = "$trimAdapDir/work";

    usage && exit 1 unless $res;

    # Display the help information if requested.
    usage && exit 0 if $help;

    # Check we have query files
    unless(-d  $homeDir && -r $homeDir) {
        die "Error, directory $homeDir doesn't seem to exist!";
    }
    unless(-d  $fastaDir && -r $fastaDir) {
	die "Error, directory $fastaDir doesn't seem to exist!";
    }

    if($mkdir){
	mkdir $homeDir.'/work';
	mkdir $renameReadsDir;
	mkdir $renameReadsDir.'/work';
        mkdir $renameReadsDir.'/results';
        mkdir $renameReadsDir.'/stats';
	mkdir $trimLowQualDir;
	mkdir $trimLowQualDir.'/work';
	mkdir $trimLowQualDir.'/results';
	mkdir $trimLowQualDir.'/stats';
	mkdir $trimAdapDir;
	mkdir $trimAdapDir.'/work';
	mkdir $trimAdapDir.'/results';
	mkdir $trimAdapDir.'/stats';
	mkdir $homeDir.'/QC';
	mkdir $homeDir.'/QC/raw';
	mkdir $homeDir.'/QC/2_trimLowQuality';
	mkdir $homeDir.'/QC/3_trimAdapters';
        mkdir $homeDir.'/QC/4_mergePairs';
        mkdir $homeDir.'/QC/5_minLength';
        mkdir $mergePairsDir;
        mkdir $mergePairsDir.'/work';
        mkdir $mergePairsDir.'/results';
        mkdir $mergePairsDir.'/stats';
        mkdir $minLengthDir;
        mkdir $minLengthDir.'/work';
        mkdir $minLengthDir.'/results';
        mkdir $minLengthDir.'/stats';
	mkdir $metaphlanDir;
	mkdir $rtmDir;
    }

    if($trimPrimers){

        $trimPrimerDir = $homeDir.'/3b_trimPrimers';
        if($mkdir){
            mkdir $trimPrimerDir;
            mkdir $trimPrimerDir.'/work';
            mkdir $trimPrimerDir.'/results';
            mkdir $trimPrimerDir.'/stats';
            mkdir $homeDir."/QC/3b_trimPrimers";
        }
        $trimPrimerOutDir = $trimPrimerDir."/work";
    }



    #  build the qsub files
    makeQsubs();

}

sub makeQsubs{
	
    # iterate through files and make qsub for each
    my $globStr = $fastaDir . '/*R1*.fastq';
    if($isGzipped){
        $globStr = $fastaDir . '/*R1*.fastq.gz';
    }
    my @fastaFiles = glob ($globStr);
    print $fastaDir."\n";
    foreach my $fasta ( @fastaFiles ){

	    writeQSub($fasta);
	}

}

sub writeQSub {

    my $fasta = $_[0];
	
    # get sampleID from fastq filename
    my $sampleID;

#B053-1X-CG_S11_L001_R2_001.fastq.gz
#081-ADS-VDNA_R1.fastq
    if($fasta =~ m/\/([A-Za-z0-9-]*)_[^\/]*R([1-2]+)[^\/]*\.fastq/) {

        $sampleID = $1;

    }else {
	print "Error processing file named: $fasta. Skipping.\n";
	return;
    }

    my $rawFastaR1gz = $fasta;
    my $rawFastaR2gz = $fasta;
    $rawFastaR2gz =~ s/R1/R2/g;

    my $rawFastaR1 = $fasta;
    $rawFastaR1 =~ s/\.gz//;
    my $rawFastaR2 = $rawFastaR1;
    $rawFastaR2 =~ s/R1/R2/g;

    $jobName = "proc".$sampleID;
      
    open(QSUB, ">$workdir/$jobName.qsub") 
	|| die "Error opening file $workdir/$jobName.qsub: $!";

    print "Writing QSUB file $workdir/$jobName.qsub\n" if($verbose);

    print QSUB "#!/bin/bash\n\n";
    print QSUB "#PBS -r n\n";
    print QSUB "#PBS -l walltime=".$hrs.":00:00\n";
    print QSUB "#PBS -l pmem=".$mgMem."mb\n";
    print QSUB "#PBS -m bea\n";
    print QSUB "#PBS -M $email\n";
    print QSUB "#PBS -N $jobName\n";
#    print QSUB "#PBS -A $account \n\n";
 
    print QSUB "cd $workdir\n";
    print QSUB "echo \"Current working directory is `pwd`\"\n";
    print QSUB "echo \"prog started at: `date`\"\n";

    my $renameOutR1 = "$renameReadsDir/work/$sampleID"."_R1_raw_renamed.fastq";
    my $renameOutR2 = "$renameReadsDir/work/$sampleID"."_R2_raw_renamed.fastq";
    my $trimmoLowQualOutR1 = "$trimmoLowQualOutDir/$sampleID"."_R1_trim.fastq";
    my $trimmoLowQualOutR2 = "$trimmoLowQualOutDir/$sampleID"."_R2_trim.fastq";
    my $trimLowQualLogR1 = "$trimmoLowQualOutDir/$sampleID"."_R1_log.txt";
    my $trimLowQualLogR2 = "$trimmoLowQualOutDir/$sampleID"."_R2_log.txt";
    my $cutadaptTrimmedR1 = "$cutadaptOutDir/$sampleID"."_HQ_R1_rmAdap";
    my $cutadaptTrimmedR2 = "$cutadaptOutDir/$sampleID"."_HQ_R2_rmAdap";
    my $splitIn1 = $cutadaptTrimmedR1.".fastq";
    my $splitIn2 = $cutadaptTrimmedR2.".fastq";



    if($runPreMinLength){
	if($runPrePrimerTrim){

	    if($isGzipped){
		printCmdToQSUB ("gunzip -f $rawFastaR1gz");
		printCmdToQSUB ("gunzip -f $rawFastaR2gz");
	    }

	    printCmdToQSUB ("~/programs/FastQC/fastqc -q -f fastq -o $homeDir/QC/raw $rawFastaR1");
	    printCmdToQSUB ("~/programs/FastQC/fastqc -q -f fastq -o $homeDir/QC/raw $rawFastaR2");

	    printCmdToQSUB ("~/scripts/$renameReadsScript -i $rawFastaR1 -j $rawFastaR2 -o $renameOutR1 -p $renameOutR2 -s $sampleID");

	    printCmdToQSUB ("java -classpath /home/tva4/programs/trimmomatic/Trimmomatic-0.25/trimmomatic-0.25.jar org.usadellab.trimmomatic.TrimmomaticSE -threads 1 -phred33 -trimlog $trimLowQualLogR1 $renameOutR1 $trimmoLowQualOutR1 SLIDINGWINDOW:$windowLength:$minQualityForWindow LEADING:$minQualityLeading");
	    printCmdToQSUB ("java -classpath /home/tva4/programs/trimmomatic/Trimmomatic-0.25/trimmomatic-0.25.jar org.usadellab.trimmomatic.TrimmomaticSE -threads 1 -phred33 -trimlog $trimLowQualLogR2 $renameOutR2 $trimmoLowQualOutR2 SLIDINGWINDOW:$windowLength:$minQualityForWindow LEADING:$minQualityLeading");

	    printCmdToQSUB ("~/programs/FastQC/fastqc -q -f fastq -o $homeDir/QC/2_trimLowQuality $trimmoLowQualOutR1");
	    printCmdToQSUB ("~/programs/FastQC/fastqc -q -f fastq -o $homeDir/QC/2_trimLowQuality $trimmoLowQualOutR2");
	    
	    printCmdToQSUB("bash ~/scripts/getLineLengthHistogram.sh $trimmoLowQualOutR1");
	    printCmdToQSUB("bash ~/scripts/getLineLengthHistogram.sh $trimmoLowQualOutR2");

	    ## TRIM ADAPTERS ##
	    
	    printCmdToQSUB ("python /home/tva4/programs/cutadapt/cutadapt -e 0.1 -a $adapterR1 -o $cutadaptTrimmedR1.fastq --info-file=$cutadaptTrimmedR1.info $trimmoLowQualOutR1 -m 15");

	    printCmdToQSUB ("python /home/tva4/programs/cutadapt/cutadapt -e 0.1 -a $adapterR2 -o $cutadaptTrimmedR2.fastq --info-file=$cutadaptTrimmedR2.info $trimmoLowQualOutR2 -m 15");

	    printCmdToQSUB ("~/programs/FastQC/fastqc -q -f fastq -o $homeDir/QC/3_trimAdapters $cutadaptTrimmedR1.fastq");
	    printCmdToQSUB( "~/programs/FastQC/fastqc -q -f fastq -o $homeDir/QC/3_trimAdapters $cutadaptTrimmedR2.fastq");

	    printCmdToQSUB("bash ~/scripts/getLineLengthHistogram.sh $cutadaptTrimmedR1.fastq");
	    printCmdToQSUB("bash ~/scripts/getLineLengthHistogram.sh $cutadaptTrimmedR2.fastq");

	}

	if($trimPrimers){
         ## TRIM PRIMERS ##
	
	    my $cutadaptTrimmedR1primer = "$trimPrimerOutDir/$sampleID"."_HQ_R1_rmAdapRmPrimer";
	    my $cutadaptTrimmedR2primer = "$trimPrimerOutDir/$sampleID"."_HQ_R2_rmAdapRmPrimer";
	    
	    #running with two adapters in one cmd does not handle the case where both primers appear in the read
	    # these commands tell it to remove the primers from anywhere, and to check for them appearing at most 4 times
	    printCmdToQSUB ("python /home/tva4/programs/cutadapt/cutadapt -e 0.1 -b $primerF -o $cutadaptTrimmedR1primer.tmp --info-file=$cutadaptTrimmedR1primer.F.info $cutadaptTrimmedR1.fastq -m 15 --times=5 -f fastq");
	    printCmdToQSUB ("python /home/tva4/programs/cutadapt/cutadapt -e 0.1 -b $primerR -o $cutadaptTrimmedR1primer.fastq --info-file=$cutadaptTrimmedR1primer.R.info $cutadaptTrimmedR1primer.tmp -m 15 --times=5 -f fastq");
	    printCmdToQSUB ("rm $cutadaptTrimmedR1primer.tmp");

	    printCmdToQSUB ("python /home/tva4/programs/cutadapt/cutadapt -e 0.1 -b $primerF -o $cutadaptTrimmedR2primer.tmp --info-file=$cutadaptTrimmedR2primer.F.info $cutadaptTrimmedR2.fastq -m 15 --times=5 -f fastq");
	    printCmdToQSUB ("python /home/tva4/programs/cutadapt/cutadapt -e 0.1 -b $primerR -o $cutadaptTrimmedR2primer.fastq --info-file=$cutadaptTrimmedR2primer.R.info $cutadaptTrimmedR2primer.tmp -m 15 --times=5 -f fastq");
	    printCmdToQSUB ("rm $cutadaptTrimmedR2primer.tmp");


	    printCmdToQSUB ("~/programs/FastQC/fastqc -q -f fastq -o $homeDir/QC/3b_trimPrimers $cutadaptTrimmedR1primer.fastq");
	    printCmdToQSUB( "~/programs/FastQC/fastqc -q -f fastq -o $homeDir/QC/3b_trimPrimers $cutadaptTrimmedR2primer.fastq");
	    
	    printCmdToQSUB("bash ~/scripts/getLineLengthHistogram.sh $cutadaptTrimmedR1primer.fastq");
	    printCmdToQSUB("bash ~/scripts/getLineLengthHistogram.sh $cutadaptTrimmedR2primer.fastq");

	    $splitIn1 = $cutadaptTrimmedR1primer.".fastq";
	    $splitIn2 = $cutadaptTrimmedR2primer.".fastq";
	
	}



    ### MERGE PAIRED READS ###
    ### SPLIT UP PAIRED AND UNPAIRED READS ###

    my $r1paired =  $sampleID."_HQ_R1_pair.fastq";
    my $r1unpaired =  $sampleID."_HQ_R1_unpair.fastq";
    my $r2paired =  $sampleID."_HQ_R2_pair.fastq";
    my $r2unpaired =  $sampleID."_HQ_R2_unpair.fastq";

    printCmdToQSUB("cd $mergePairsDir/work");
    printCmdToQSUB("perl ~/scripts/splitIntoPairedAndUnpaired.pl -f $splitIn1 -r $splitIn2 -s $sampleID -a $r1paired -b $r1unpaired -c $r2paired -d $r2unpaired");
    printCmdToQSUB("/home/tva4/programs/pear/pear-0.9.0-bin-32/pear -f $r1paired -r $r2paired -o $sampleID"."_HQ -t 5");

    # reads that have been merged should end with .1-2
    printCmdToQSUB("cat $sampleID"."_HQ.assembled.fastq | paste - - - - | sed 's/^\\(\\S*\\)\\.1/\\1.1-2/' | tr '\\t' '\\n' > tmp.\$PBS_JOBID; mv tmp.\$PBS_JOBID $sampleID"."_HQ.assembled.fastq;");

    # get unpaired
    printCmdToQSUB("cat $sampleID"."_HQ_R1_unpair.fastq $sampleID"."_HQ.unassembled.forward.fastq > $sampleID"."_R1_unmerged.fastq");
    printCmdToQSUB("cat $sampleID"."_HQ_R2_unpair.fastq $sampleID"."_HQ.unassembled.reverse.fastq > $sampleID"."_R2_unmerged.fastq");

    printCmdToQSUB("bash ~/scripts/getLineLengthHistogram.sh $sampleID"."_HQ.assembled.fastq");
    printCmdToQSUB("bash ~/scripts/getLineLengthHistogram.sh $sampleID"."_R1_unmerged.fastq");
    printCmdToQSUB("bash ~/scripts/getLineLengthHistogram.sh $sampleID"."_R2_unmerged.fastq");

    printCmdToQSUB ("~/programs/FastQC/fastqc -q -f fastq -o $homeDir/QC/4_mergePairs $sampleID"."_HQ.assembled.fastq");
    printCmdToQSUB ("~/programs/FastQC/fastqc -q -f fastq -o $homeDir/QC/4_mergePairs $sampleID"."_R1_unmerged.fastq");
    printCmdToQSUB ("~/programs/FastQC/fastqc -q -f fastq -o $homeDir/QC/4_mergePairs $sampleID"."_R2_unmerged.fastq");

    printCmdToQSUB("cd $workdir");
    }

    ### FILTER BY MIN LENGTH ###
    # quality scores are messed up by merging with PEAR (I think it sums them?), this can make biopieces (reasonably) fail, using prinseq instead

    printCmdToQSUB("rm $minLengthDir/work/$sampleID"."_HQ.assembled.min$minLength.fasta $minLengthDir/work/$sampleID"."_R1_unmerged.min$minLength.fasta $minLengthDir/work/$sampleID"."_R2_unmerged.min$minLength.fasta");

    printCmdToQSUB("/home/tva4/programs/prinseq/prinseq-lite-0.20.4/prinseq-lite.pl -fastq $mergePairsDir/work/$sampleID"."_HQ.assembled.fastq  -out_format 1 -out_good $minLengthDir/work/$sampleID"."_HQ.assembled.min$minLength  -out_bad null  -min_len $minLength -line_width 0 ");
    printCmdToQSUB("/home/tva4/programs/prinseq/prinseq-lite-0.20.4/prinseq-lite.pl -fastq $mergePairsDir/work/$sampleID"."_R1_unmerged.fastq  -out_format 1 -out_good $minLengthDir/work/$sampleID"."_R1_unmerged.min$minLength -out_bad null  -min_len $minLength -line_width 0");
    printCmdToQSUB("/home/tva4/programs/prinseq/prinseq-lite-0.20.4/prinseq-lite.pl -fastq $mergePairsDir/work/$sampleID"."_R2_unmerged.fastq  -out_format 1 -out_good $minLengthDir/work/$sampleID"."_R2_unmerged.min$minLength -out_bad null  -min_len $minLength -line_width 0");

    printCmdToQSUB("cat $minLengthDir/work/$sampleID"."_HQ.assembled.min$minLength.fasta $minLengthDir/work/$sampleID"."_R1_unmerged.min$minLength.fasta $minLengthDir/work/$sampleID"."_R2_unmerged.min$minLength.fasta > tmp$sampleID.\$PBS_JOBID; mv tmp$sampleID.\$PBS_JOBID $minLengthDir/work/$sampleID"."_HQ.min$minLength.fasta");

    ### RUN METAPHLAN ###

    if($runMetaphlan1){

	my $bowtieOut1="$metaphlanDir/vsl-mtphln_".$sampleID."_min$minLength.bowtie.out";
	printCmdToQSUB("python ~/programs/metaphlan/metaphlan.py --bowtie2db ~/programs/metaphlan/bowtie2db/mpa --bowtie2_exe /usr/local/bin/bowtie2 --bowtie2out ".$bowtieOut1." --tax_lev a -t rel_ab  --input_type multifasta $minLengthDir/work/$sampleID"."_HQ.min$minLength.fasta -o $metaphlanDir/vsl-mtphln_".$sampleID."_min$minLength.m1.out  --bt2_ps very-sensitive-local");

        printCmdToQSUB("python ~/programs/metaphlan/metaphlan.py --bowtie2db ~/programs/metaphlan/bowtie2db/mpa --bowtie2_exe /usr/local/bin/bowtie2 --tax_lev a -t reads_map --input_type bowtie2out -o $metaphlanDir/vsl-mtphln_".$sampleID."_min$minLength.m1.readMap.out  --bt2_ps very-sensitive-local " .$bowtieOut1);

    }

    if($runMetaphlan2){

        my $bowtieOut2="$metaphlanDir/vsl-mtphln2_".$sampleID."_min$minLength.m2.bowtie.out";
        printCmdToQSUB("python ~/programs/metaphlan2/metaphlan2.py --bowtie2db ~/programs/metaphlan2/db_v20/mpa_v20_m200 --bowtie2_exe /usr/local/bin/bowtie2 --bowtie2out ".$bowtieOut2." --tax_lev a -t rel_ab  --input_type multifasta $minLengthDir/work/$sampleID"."_HQ.min$minLength.fasta -o $metaphlanDir/vsl-mtphln2_".$sampleID."_min$minLength.m2.out  --bt2_ps very-sensitive-local --mpa_pkl ~/programs/metaphlan2/db_v20/mpa_v20_m200.pkl ");

        printCmdToQSUB("python ~/programs/metaphlan2/metaphlan2.py --mpa_pkl ~/programs/metaphlan2/db_v20/mpa_v20_m200.pkl  --bowtie2db ~/programs/metaphlan/bowtie2db/mpa --bowtie2_exe /usr/local/bin/bowtie2 --tax_lev a -t reads_map --input_type bowtie2out -o $metaphlanDir/vsl-mtphln2_".$sampleID."_min$minLength.m2.readMap.out  --bt2_ps very-sensitive-local " .$bowtieOut2);


    }


    ### run RTM ###
    if($runRTM){
	printCmdToQSUB("perl  -I /home/tva4/perl5/lib/perl5 -I /home/tva4/perl5/lib/perl5/x86_64-linux-thread-multi -I /home/tva4/SEED/sas/lib -I /home/tva4/SEED/sas/modules/lib  ~/SEED/sas/plbin/svr_assign_to_dna_using_figfams.pl -kmer=9 -reliability=2 -maxGap=600 < $minLengthDir/work/$sampleID"."_HQ.min$minLength.fasta > $rtmDir/rtm_".$sampleID."_min$minLength.out");

	printCmdToQSUB("perl  -I /home/tva4/perl5/lib/perl5 -I /home/tva4/perl5/lib/perl5/x86_64-linux-thread-multi -I /home/tva4/SEED/sas/lib -I /home/tva4/SEED/sas/modules/lib  ~/SEED/sas/plbin/svr_roles_to_subsys.pl -c 4 < $rtmDir/rtm_".$sampleID."_min$minLength.out > $rtmDir/rtmAnno_".$sampleID."_min$minLength.out");
    }
    
    print QSUB "echo \"prog $jobName finished at: `date`\"\n";
    print QSUB "echo \"prog $jobName finished with exit code \$?\"\n";

    close QSUB;

    if($submit){
	print "Submitting job $jobName.qsub\n";
	system("qsub $workdir/$jobName.qsub");
    }

}

sub printCmdToQSUB {
    my $cmd = $_[0];
    print QSUB "echo \"".$cmd."\" >> $workdir/$jobName.\$PBS_JOBID.out \n";
    print QSUB $cmd."\n";
}
