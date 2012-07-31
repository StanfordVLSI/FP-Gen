#!/usr/bin/perl

use strict ;
use warnings ;
use diagnostics -verbose ;
use File::Copy;

my $log_file = shift or die "No log file supplied as arguments" ;


print "\n" ;
print "\n" ;
print "++++++++++++++++++++++++++++++++++\n" ;
print "Checking $log_file in checkRun.pl\n" ;
print "++++++++++++++++++++++++++++++++++\n" ;
print "\n" ;


open (MYFILE, $log_file) or error("Could not open $log_file");
while (my $line = <MYFILE>) {
    $line =~ m/Fatal:/    and error("\tFatal error at Line $. of File $log_file: \n\t$line");
    $line =~ m/Error:/    and error("\tError error at Line $. of File $log_file: \n\t$line");
    $line =~ m/Abort at / and error("\tAbort error at Line $. of File $log_file: \n\t$line");
}
close (MYFILE); 

sub error{
    my $msg = shift;
    print STDERR "ERROR: $msg\n\n";
    move ($log_file, $log_file.Error);
    exit 7;
}

# If we are here, life is good!
print "Woohoo! No trouble mate.. Continue!\n";
exit 0;

1;
