#!/usr/bin/perl
# This script generate yml file for MultiplierP configs
# The design space is the crossproduct of {double MP}
#                                        X{array, wallace, zm, os1}
#                                        X{booth 1,2,3}
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
          'makefile' => '/horowitz/users/tema8/projects/ChipGen/FP-Gen/Makefile',
          'setupfile' => '/horowitz/users/tema8/projects/ChipGen/FP-Gen/scripts/setup_kiwi.bash',
          'delay_make_variable' => 'SYN_CLK_PERIOD',
          'make_arguments' => 'FPPRODUCT=MultiplierP USE_SAIF=0 USE_GATE_SAIF=0 USE_ICC_GATE_SAIF=0 IO2CORE=8  VERILOG_SIMULATION_FLAGS="+IgnoreErrors"',
          'eval_rules' => 'run_dc run_icc run_icc_opt',
          'cleanup' => 1,
          'design_title' => 'MultP_MP_DC_ICC_v1',
          'param_make_variable' => 'GENESIS_PARAMS',
          'clean_rules' => 'clean',
          'genesis_hierarchy_variable' => 'GENESIS_HIERARCHY',
          'genesis_cfg_xml_variable' => 'GENESIS_CFG_XML',
          'rollup_rules' => 'rollup1',
          'gen_rules' => 'gen',
          'rollup_variable' => 'ROLLUP_TARGET',
	  'cubby_root' => '/tmp/tema8/runMake/'   
};


my @trees  = ( 'Wallace', 'Array', 'ZM', 'OS1' ) ;
#my @trees  = ( 'Wallace') ;
my @pipes  = ( 0) ;
my @vts    = ( 'lvt' , 'svt' , 'hvt' );
#my @vts    = ( 'lvt' );
my @delays = ( 0.4, 0.45 , 0.5 , 0.55 , 0.6 , 0.7 , 0.8 , 0.9 , 1.0, 1.1 );
#my @delays = ( 0.5 );
my @booths  = ( 1 , 2 , 3 ) ;
#my @booths  = (2 ) ;


# Width: 11 for half, 24 for single, 53 for double, 113 for quad
my $width = 53 ; 



my $i = -1 ;
foreach my $booth (@booths){
foreach my $tree  (@trees){
foreach my $pipe  (@pipes){
foreach my $vt    (@vts){
foreach my $delay (@delays){
    $i += 1 ; 
    #$i = 0 ;

    $configuration->{'design'}[$i]{'top_MultiplierP.UseMP'}                       = '1' ;
    $configuration->{'design'}[$i]{'top_MultiplierP.UseInc'}                      = 'YES' ;
    $configuration->{'design'}[$i]{'top_MultiplierP.VERIF_MODE'}                  = 'OFF' ;
    $configuration->{'design'}[$i]{'top_MultiplierP.SYNTH_MODE'}                  = 'ON' ;
    $configuration->{'design'}[$i]{'top_MultiplierP.MultiplierP.Designware_MODE'} = 'OFF';
    $configuration->{'design'}[$i]{'top_MultiplierP.MultiplierP.Width'}           = $width;
    $configuration->{'design'}[$i]{'top_MultiplierP.MultiplierP.PipelineDepth'}   = $pipe;
    $configuration->{'design'}[$i]{'top_MultiplierP.MultiplierP.TreeType'}        = $tree ;
    $configuration->{'design'}[$i]{'top_MultiplierP.MultiplierP.BoothType'}       = $booth ;

    $configuration->{'make_params'}[$i]{'VT'}      = $vt;
    $configuration->{'make_params'}[$i]{'VOLTAGE'} = $vt eq 'lvt' ? '1v0' : ( $vt eq 'svt' ? '0v9' : '0v8' );

    $configuration->{'target_delay'}[$i] = $delay;

}}}}}


foreach my $width  ( 24, 53 ){
foreach my $pipe  (@pipes){
foreach my $vt    (@vts){
foreach my $delay (@delays){
    $i += 1 ; 

#    $configuration->{'design'}[$i]{'top_MultiplierP.UseMP'}                       = '1' ;
#    $configuration->{'design'}[$i]{'top_MultiplierP.UseInc'}                      = 'YES' ;
    $configuration->{'design'}[$i]{'top_MultiplierP.VERIF_MODE'}                  = 'OFF' ;
    $configuration->{'design'}[$i]{'top_MultiplierP.SYNTH_MODE'}                  = 'ON' ;
    $configuration->{'design'}[$i]{'top_MultiplierP.MultiplierP.Designware_MODE'} = 'ON';
    $configuration->{'design'}[$i]{'top_MultiplierP.MultiplierP.Width'}           = $width;
    $configuration->{'design'}[$i]{'top_MultiplierP.MultiplierP.PipelineDepth'}   = $pipe;

    $configuration->{'make_params'}[$i]{'VT'}      = $vt;
    $configuration->{'make_params'}[$i]{'VOLTAGE'} = $vt eq 'lvt' ? '1v0' : ( $vt eq 'svt' ? '0v9' : '0v8' );

    $configuration->{'target_delay'}[$i] = $delay;
}}}}




$i += 1 ; 
$configuration->{'runs'} = $i ;

print Dump $configuration;
