#!/usr/bin/perl
# This script generate yml file for MultiplierP configs
# The design space is the crossproduct of {half, single, double, quad}
#                                        X{array, wallace, zm, os1}
#                                        X{booth 1,2,3,4}
#                                        X{informed/uniformed placement}
#                                        X{lvt,svt,hvt}
#                                        X{delay ranges that make sense based on previos writeup}

use strict;
use warnings ;
use Getopt::Std;

use YAML::Any ;
use Data::Dumper ;


#print `cat test_01.yml`;
#
#my $cfg = `cat test_01.yml` ;
#my $hash = Load $cfg;
#
#print Dumper( $hash );

my $configuration = 
{
          'makefile' => '/horowitz/users/jingpu/projects/FP-Gen/Makefile',
          'setupfile' => '/horowitz/users/jingpu/projects/FP-Gen/scripts/setup_kiwi.bash',
          'delay_make_variable' => 'SYN_CLK_PERIOD',
          'make_arguments' => 'FPPRODUCT=MultiplierP USE_SAIF=0 USE_GATE_SAIF=0 USE_ICC_GATE_SAIF=0 IO2CORE=8  VERILOG_SIMULATION_FLAGS="+IgnoreErrors"',
#          'eval_rules' => 'run_dc_notopo run_icc_opt dc_clean run_dc run_icc',
	  'eval_rules' => 'run_dc run_icc run_icc_opt',
          'cleanup' => 1,
          'design_title' => 'MultP16svt_dc_icc_v8',
          'param_make_variable' => 'GENESIS_PARAMS',
          'clean_rules' => 'clean',
          'genesis_hierarchy_variable' => 'GENESIS_HIERARCHY',
          'genesis_cfg_xml_variable' => 'GENESIS_CFG_XML',
          'rollup_rules' => 'rollup1',
          'gen_rules' => 'gen',
          'rollup_variable' => 'ROLLUP_TARGET',
	  'cubby_root' => '/tmp/jingpu/runMake',
#	  'cubby_root' => '/nobackup/jingpu/FP-Gen/tmp/runMake'    
};


my @trees  = ( 'Wallace', 'Array', 'ZM', 'OS1' ) ;
#my @trees  = ( 'Wallace') ;
my @pipes  = ( 0) ;
#my @vts    = ( 'lvt' , 'svt' , 'hvt' );
my @vts    = ( 'svt' );
my @delays = ( 0.35, 0.4, 0.45 , 0.5 , 0.55 , 0.6 , 0.7 , 0.8);  #for half precision
#my @delays = ( 0.6, 0.65, 0.7 ,0.75, 0.8 , 0.85, 0.9 , 0.95, 1.0, 1.2);  #for single precision
#my @delays = (  0.9 , 0.95, 1.0, 1.05, 1.1, 1.2, 1.3, 1.4, 1.5, 1.7 );  #for double
#my @delays = ( 1.25, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.2, 2.4, 2.6 );  #for quade
my @booths  = ( [1, 0], [2, 0], [2, 1], [3, 1], [4, 1] ) ;
#my @booths  = ([2, 1] ) ;


# Width: 11 for half, 24 for single, 53 for double, 113 for quad
my $width = 11 ; 



my $i = -1 ;
for(my $iter=0; $iter<1; $iter++){
    foreach my $booth (@booths){
	foreach my $tree  (@trees){
	    foreach my $pipe  (@pipes){
		foreach my $vt    (@vts){
		    foreach my $delay (@delays){
			my $delay2 = $delay + $iter * 0.01;
			$i += 1 ; 
			#$i = 0 ;
			

			$configuration->{'design'}[$i]{'top_MultiplierP.VERIF_MODE'}                  = 'OFF' ;
			$configuration->{'design'}[$i]{'top_MultiplierP.SYNTH_MODE'}                  = 'ON' ;
			$configuration->{'design'}[$i]{'top_MultiplierP.MultiplierP.Designware_MODE'} = 'OFF';
			$configuration->{'design'}[$i]{'top_MultiplierP.MultiplierP.Width'}           = $width;
			$configuration->{'design'}[$i]{'top_MultiplierP.MultiplierP.PipelineDepth'}   = $pipe;
			$configuration->{'design'}[$i]{'top_MultiplierP.MultiplierP.TreeType'}        = $tree ;
			$configuration->{'design'}[$i]{'top_MultiplierP.MultiplierP.BoothType'}       = $$booth[0] ;
			$configuration->{'design'}[$i]{'top_MultiplierP.MultiplierP.ModifiedBooth'}   = $$booth[1] ;

			$configuration->{'make_params'}[$i]{'VT'}      = $vt;
			$configuration->{'make_params'}[$i]{'VOLTAGE'} = $vt eq 'lvt' ? '1v0' : ( $vt eq 'svt' ? '0v9' : '0v8' );

			$configuration->{'target_delay'}[$i] = $delay2;

		    }}}}}


    foreach my $pipe  (@pipes){
	foreach my $vt    (@vts){
	    foreach my $delay (@delays){
		$i += 1 ; 

		my $delay2 = $delay + $iter * 0.01;
		$configuration->{'design'}[$i]{'top_MultiplierP.VERIF_MODE'}                  = 'OFF' ;
		$configuration->{'design'}[$i]{'top_MultiplierP.SYNTH_MODE'}                  = 'ON' ;
		$configuration->{'design'}[$i]{'top_MultiplierP.MultiplierP.Designware_MODE'} = 'ON';
		$configuration->{'design'}[$i]{'top_MultiplierP.MultiplierP.Width'}           = $width;
		$configuration->{'design'}[$i]{'top_MultiplierP.MultiplierP.PipelineDepth'}   = $pipe;

		$configuration->{'make_params'}[$i]{'VT'}      = $vt;
		$configuration->{'make_params'}[$i]{'VOLTAGE'} = $vt eq 'lvt' ? '1v0' : ( $vt eq 'svt' ? '0v9' : '0v8' );

		$configuration->{'target_delay'}[$i] = $delay2;
	    }}}
}



$i += 1 ; 
$configuration->{'runs'} = $i ;

print Dump $configuration;
