#!/usr/bin/perl

use strict;
use Getopt::Long;

my $home_dir = $ENV{'PWD'};
my $xml_dir = $home_dir . "/SysCfgs";
my $synth_dir = $home_dir . "/synthesis";
my $work_dir = $home_dir . "/work";
my $result_dir = $home_dir . "/results";

my @xmls = ();

GetOptions(
	'folder=s'	=>	\$result_dir,
        'xml=s'         =>      \@xmls,
);

$result_dir = "$home_dir/$result_dir" unless $result_dir =~ m/^\//;

mkdir ("$result_dir");

chdir ("$work_dir")||die("There is no work dir.\n");
print "Entering $work_dir\n";

# begin collecting results
while ( $#xmls >= 0){
	my $xml = shift @xmls;
	chdir ("$xml")||die("There is no $xml dir.\n");
	print "Entering $work_dir/$xml\n";
	
	chdir ("synthesis")||die("There is no synthesis dir in $xml");
	print "Entering $work_dir/$xml/synthesis\n";
	
	my $csv = $xml;
	$csv =~ s/.xml/.csv/;
	print "Saving results to $result_dir/$csv...";
	`./report_results.pl > $result_dir/$csv`;
	print "done\n";
	
        chdir("../");
        print "Leaving $work_dir/$xml/synthesis\n";
        chdir("../");
        print "Leaving $work_dir/$xml\n";
}

