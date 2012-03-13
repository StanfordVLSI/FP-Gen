#!/usr/bin/perl

use strict ;
use warnings ;
use diagnostics -verbose ;

my $log_file = shift or die "No log file supplied as arguments" ;

my $status = `cat $log_file` ;

print "++++++++++++++++++++++++++++++++++\n" ;
print "Checking $log_file in checkRun.pl\n" ;
print "++++++++++++++++++++++++++++++++++\n" ;

$status =~ m/Fatal:/    and die "Fatal error in run\n" ;
$status =~ m/Error:/    and die "Error in run\n" ;
$status =~ m/Abort at / and die "Abort in run\n" ;

