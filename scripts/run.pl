#!/usr/bin/perl

use strict;
use Getopt::Long;

my $home_dir = $ENV{'FPGEN'};
my $xml_dir = $home_dir . "/SysCfgs";
my $synth_dir = $home_dir . "/synthesis";
my $work_dir = "./work";

my $cluster = ();
my $jobs = 50;
my @xmls = ();
my @synths = ();

GetOptions(
	'cluster!'	=>	\$cluster,
	'jobs=i'	=>	\$jobs,
	'xml=s'		=>	\@xmls,
	'synth=s'	=>	\@synths,
);

if($#xmls != $#synths){
	die("The number of XML config files and synthesis scripts do NOT match.");
}

my $id = 0 ;
my $tag = sprintf( "%03x" , int( rand( 4095 ) ) ) ;

# go into work dir
mkdir("$work_dir");
chdir("$work_dir");
print "Entering $work_dir\n";

# begin working
while ( $#xmls >= 0){
	my $xml = shift @xmls;
	my $synth_scr = shift @synths;

	# generate and compile .v files
	mkdir("$xml");
	chdir("$xml");
	print "Entering $work_dir/$xml\n";
	print "Now making file for $xml...\n";
	`make -f $home_dir/Makefile clean all FPPRODUCT=FPMult GENESIS_CFG_XML=$xml_dir/$xml`;

	# extract synthesis target
	open(SYNTH_PAR,"$synth_dir/$synth_scr")||die("Could not open file.\n");	
	my @target = ();
	while(my $line = <SYNTH_PAR>){
		my @tmp=( split(/[\s\\]+/,$line));
		if (length($tmp[0])==0) {shift @tmp;}
		@target = ( @target, @tmp);
	}
	shift(@target);
	close(SYNTJ_PAR);

	# generate and run batch jobs
	`cp -r $synth_dir ./`;
	chdir ("synthesis");
	print "Entering $work_dir/$xml/synthesis\n";
	while (	$#target >0 ){
	$id++ ;
	my $batchName = "batch_" . $tag . "_n" . $id . ".sh" ;
	
	my $s1 = shift @target ;
	my $s2 = shift @target ;
	my $s3 = shift @target ;
	my $s4 = shift @target ;

	my $flow = "" ;

	$flow .= "#!/bin/bash  \n";
	$flow .= "   \n";
	$flow .= "date\n";
	$flow .= "   \n";
	$flow .= " echo \"$id $tag\" \n";
	$flow .= "   \n";
	$flow .= "source $synth_dir/synSetup/synopsys_startup/setup.sh \n";
	$flow .= "source $synth_dir/synSetup/synopsys_startup/library_TSMC_45.sh\n";
	$flow .= "export VCS_ARCH_OVERRIDE=linux   \n";
	$flow .= "export VCS_HOME=/hd/cad/synopsys/vcs-mx/2010.06   \n";
	$flow .= "export PATH=\${VCS_HOME}/bin:\${PATH}   \n";
	$flow .= "export VIRSIM_HOME=\${VCS_HOME}/gui/virsim   \n";
	$flow .= "export DVE=\${VCS_HOME}/gui/dve/bin/   \n";
	$flow .= "export VCS_LIC_EXPIRE_WARNING=5   \n";
	$flow .= "PATH=/hd/cad/synopsys/dc_shell/F-2011.09/bin/:\$PATH   \n";
	$flow .= "export SNPSLMD_LICENSE_FILE=26585\@vlsi,26585\@omni,26585\@shimbala:27000\@cadlic0   \n";
	$flow .= "PATH=:/hd/cad/synopsys/icc/2011.09-SP1/bin/:\$PATH   \n";
	$flow .= "PATH=:/hd/cad/synopsys/pts/2009.12-SP2/bin/:\$PATH   \n";
	$flow .= "PATH=:/hd/cad/synopsys/star-rcxt/2008.12/amd64_star-rcxt/bin:\$PATH   \n";
	$flow .= "export GENESIS_LIBS=\"/hd/cad/genesis2/r9648/PerlLibs\"   \n";
	$flow .= "PATH=\$GENESIS_LIBS/Genesis2:\$PATH   \n";
	$flow .= "make all VT=$s1 Voltage=$s2 target_delay=$s3 io2core=$s4";
	open( BATCHFILE , ">$batchName") ;
	printf BATCHFILE $flow ;
    	close( BATCHFILE ) ;
	`chmod 777 $batchName`;
	
	if($cluster){
		my $usrname = $ENV{'USER'};
		my $count = `qstat | grep -c $usrname`;
		while ($count >= $jobs){
			print "Now there are already $count jobs in the queue. The maximum is $jobs. Job #$id is waiting...\n";
			sleep(30);
			$count = `qstat | grep -c $usrname`;
		}
		$count++;
		`jsub -q horowitz -- ./$batchName`;
		print "Submitting Job #$id --> " . $s1 ."_". $s2 . "_" . $s3 . "\n" ;
		print "Job #$id submitted. Now you have $count jobs in the queue.\n";
	}else{
		`./$batchName`;
		print "Running Job #$id --> " . $s1 ."_". $s2 . "_" . $s3 . "\n" ;
	}
	}
	chdir("../");
	print "Leaving $work_dir/$xml/synthesis\n";
	chdir("../");
	print "Leaving $work_dir/$xml\n";
}
