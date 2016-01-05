#!/usr/bin/perl

use strict;
use Getopt::Long;
use Cwd qw(abs_path getcwd);

BEGIN{
# Find absolute path of script
    my ($path) = abs_path($0) =~ /^(.+)\//;
    chdir($path);
sub mypath { return $path; }
};

my $name = shift;

my @command = @ARGV;

my $email = "theajobreports\@gmail.com";

MAIN: {
    writeQSub();
my $path = mypath();

    `qsub $path/$name.qsub`;

	exit;
}

sub writeQSub {
    my $path = mypath();

    open(QSUB, ">$path/$name.qsub") 
        || die "Error opening file $path/$name.qsub: $!";

    print "Writing QSUB file $name.qsub\n";

    print QSUB "#!/bin/bash\n\n";
    print QSUB "#PBS -r n\n";
    print QSUB "#PBS -l walltime=20:00:00\n";
#    print QSUB "#PBS -l procs=20\n";
    print QSUB "#PBS -l pmem=2000m\n";
    print QSUB "#PBS -m bea\n";
    print QSUB "#PBS -M $email\n\n";
 
    print QSUB "cd $path\n";
    print QSUB "echo \"prog started at: `date`\"\n";
    print QSUB "echo \"@command\"\n";
    print QSUB "@command\n";
    print QSUB "echo \"prog finished at: `date`\"\n";
    print QSUB "echo \"prog finished with error code: \$\?\"\n";

    close QSUB;

}
