#! /usr/bin/perl

use strict;
use Getopt::Long;

my $xml = "SysCfgs/ibm_verif/WlcBth2_64_pipe1.xml";
my $fpgen_size = 1000;
my $fpgen_index = 0;
my $fpgen_seed = 1234;
my $fpgen_type = "fmadd";
my $fpgen_model = "ch-5-1-2-3-All-Exponents.fpdef";
my $run = shift;
my $name = shift;

my $tag = sprintf( "%03x" , int( rand( 4095 ) ) ) ;

my $home_dir = $ENV{'PWD'};
my $verif_dir = $home_dir . "/verif_work/";
my $work_dir = $verif_dir . $name. "/";


GetOptions(
    'xml=s'     =>      \$xml,
    'number=i'	=>	\$fpgen_size,
    'index=i'	=>	\$fpgen_index,
    'seed=i'	=>	\$fpgen_seed,
    'type=s'	=>	\$fpgen_type,
    'model=s'   =>      \$fpgen_model,
);

# go into work dir
mkdir("$verif_dir");
mkdir("$work_dir");
chdir("$work_dir") or die "Can not enter $work_dir\n";
mkdir("$work_dir"."log/");
print "Entering $work_dir\n";

my $make_flags = "GENESIS_CFG_XML=$home_dir/$xml DESIGN_NAME=FMA FPGEN_SEED=$fpgen_seed FPGEN_CLUSTER_SIZE=$fpgen_size FPGEN_CLUSTER_INDEX=$fpgen_index FPGEN_TYPE=$fpgen_type COVERAGE_MODEL=$fpgen_model";

if(!$run){

print "=================================================\n";
print "=====          Begin Simulation Task        =====\n";
print "=================================================\n\n";
print "Configuration:    $xml\n";
print "Number of tests:  $fpgen_size\n";
print "Index of cluster: $fpgen_index\n";
print "Random Seed:      $fpgen_seed\n";
print "Type of Op:       $fpgen_type\n";
print "FP-Gen model:     $fpgen_model\n\n";

print "Begin Running IBM's fpgen tool.\n";
`make -f $home_dir/Makefile fpgen $make_flags >log/fpgen.log 2>&1`;
print "fpgen is done.\n\n";

}else{
print "Begin Genesis compile phase.\n";
`make -f $home_dir/Makefile clean comp $make_flags >log/comp.log 2>&1`;
print "Genesis compile is done.\n\n";


print "Begin Running simulation.\n";
`make -f $home_dir/Makefile run_ibm $make_flags >log/run.log 2>&1`;
print "Simulation is done.\n\n";


`make -f $home_dir/Makefile clean`;


print "begin parsing log files.\n";
my $line = 0;
my $error = 0;
open(LOGFILE, "log/comp.log") or die "Can not find log/comp.log";
while(<LOGFILE>){
    $line++;
    if($_ =~ m/(Error)|(ERROR)|(Stop.)/){
	print "Error found in log/comp.log: Line $line\n";
	print "=============================\n";
	print "$_\n";
	$error = 1;
    }
}
close(LOGFILE);

$line = 0;
open(LOGFILE, "log/fpgen.log") or die "Can not find log/fpgen.log";
while(<LOGFILE>){
    $line++;
    if($_ =~ m/(Error)|(ERROR)|(FAILED)/){
	print "Error found in log/fpgen.log: Line $line\n";
	print "=============================\n";
	print "$_\n";
	$error = 1;
    }
}
close(LOGFILE);

$line = 0;
open(LOGFILE, "log/run.log") or die "Can not find log/run.log";
while(<LOGFILE>){
    $line++;
    if($_ =~ m/(Error)|(ERROR)|(Stop.)/){
	print "Error found in log/run.log: Line $line\n";
	print "=============================\n";
	print "$_\n";
	$error = 1;
    }
}
close(LOGFILE);

if(!$error){
    print "Test PASS.\n\n";
}

}

