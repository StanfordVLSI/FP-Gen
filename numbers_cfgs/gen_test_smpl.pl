#!/usr/bin/perl

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
          'makefile' => 'Makefile',
          'setupfile' => 'scripts/setup_kiwi.bash',
          'delay_make_variable' => 'SYN_CLK_PERIOD',
          'make_arguments' => 'USE_SAIF=1',
          'eval_rules' => 'comp run run_dc ',
          'cleanup' => 1,
          'design_title' => 'FMA',
          'param_make_variable' => 'GENESIS_PARAMS',
          'clean_rules' => 'clean',
          'genesis_hierarchy_variable' => 'GENESIS_HIERARCHY',
          'genesis_cfg_xml_variable' => 'GENESIS_CFG_XML',
          'rollup_rules' => 'rollup1',
          'gen_rules' => 'gen',
          'runs' => 6,
          'rollup_variable' => 'ROLLUP_TARGET',
	  'cubby_root' => '/tmp/'   
};


my @trees  = ( 'Wallace', 'Array', 'ZM', 'OS1' ) ;
my @pipes  = ( 2 , 3 , 4 , 5 , 6 , 7 , 8 ) ;
my @vts    = ( 'lvt' , 'svt' , 'hvt' );
my @delays = ( 0.3 , 0.4 , 0.5 , 0.6 , 0.7 , 0.9 , 1.0 , 1.2 , 1.4 , 1.6 , 1.8 , 2.0 );
my @pumps  = ('Yes' , 'No' ) ;

my $i = -1 ;
foreach my $tree  (@trees){
foreach my $pipe  (@pipes){
foreach my $vt    (@vts){
foreach my $pump  (@pumps){
foreach my $delay (@delays){
    $i += 1 ; 

    $configuration->{'design'}[$i]{'top_FPGen.FPGen.Architecture'}      = 'FMA' ;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.FMA.ExponentWidth'} = 8 ;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.FMA.FractionWidth'} = 23 ;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.FMA.PipelineDepth'} = $pipe;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.FMA.EnableMultiplePumping'} = $pump;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.FMA.MulShift.MUL0.MultP.TreeType'} = $tree ;

    $configuration->{'make_params'}[$i]{'VT'}      = $vt;
    $configuration->{'make_params'}[$i]{'VOLTAGE'} = $vt eq 'lvt' ? '1v0' : ( $vt eq 'svt' ? '0v9' : '0v8' );

    $configuration->{'target_delay'}[$i] = $delay;

}}}}}

$i += 1 ; 
$configuration->{'runs'} = $i ;

print Dump $configuration;
#print Dumper($configuration)
