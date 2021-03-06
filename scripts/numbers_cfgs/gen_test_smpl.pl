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
          'make_arguments' => 'USE_SAIF=1 USE_GATE_SAIF=1 USE_ICC_GATE_SAIF=1  VERILOG_SIMULATION_FLAGS="+IgnoreErrors"',
          'eval_rules' => 'comp run run_dc ',
          'cleanup' => 1,
          'design_title' => 'FPGEN64_DC_v10_',
          'param_make_variable' => 'GENESIS_PARAMS',
          'clean_rules' => 'clean',
          'genesis_hierarchy_variable' => 'GENESIS_HIERARCHY',
          'genesis_cfg_xml_variable' => 'GENESIS_CFG_XML',
          'rollup_rules' => 'rollup1',
          'gen_rules' => 'gen',
          'rollup_variable' => 'ROLLUP_TARGET',
	  'cubby_root' => '/tmp/jbrunhaver/runMake/'   
};


my @trees  = ( 'Wallace', 'Array', 'ZM', 'OS1' ) ;
#my @trees  = ( 'Wallace'  ) ;
my @pipes  = ( 3 , 4 , 5 , 6 , 7 , 8 , 9) ;
#my @pipes  = ( 4 , 5 , 6 , 7 ) ;
my @vts    = ( 'lvt' , 'svt' , 'hvt' );
#my @vts    = ( 'lvt' );
my @delays = ( 0.3 , 0.4 , 0.5 , 0.6 , 0.7 , 0.9 , 1.0 , 1.2 , 1.4 , 1.6 , 1.8 , 2.0 );
my @pumps  = ('YES' , 'NO' ) ;
#my @pumps   = ('NO') ;
my @booths  = ( 1 , 2 , 3 ) ;
#my @booths  = ( 2 ) ;

my $frac = 52 ;
my $exp  = 11 ; 


my $i = -1 ;
foreach my $booth (@booths){
foreach my $tree  (@trees){
foreach my $pipe  (@pipes){
foreach my $vt    (@vts){
foreach my $pump  (@pumps){
foreach my $delay (@delays){
    $i += 1 ; 
    #$i = 0 ;

    $configuration->{'design'}[$i]{'top_FPGen.FPGen.Architecture'}                = 'FMA' ;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.FMA.ExponentWidth'}           = $exp ;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.FMA.FractionWidth'}           = $frac ;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.FMA.PipelineDepth'}           = $pipe;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.FMA.EnableMultiplePumping'}   = $pump;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.FMA.MulShift.MUL0.TreeType'}  = $tree ;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.FMA.MulShift.MUL0.BoothType'} = $booth ;

    $configuration->{'make_params'}[$i]{'VT'}      = $vt;
    $configuration->{'make_params'}[$i]{'VOLTAGE'} = $vt eq 'lvt' ? '1v0' : ( $vt eq 'svt' ? '0v9' : '0v8' );

    $configuration->{'target_delay'}[$i] = $delay;

}}}}}}


foreach my $pipe  (@pipes){
foreach my $vt    (@vts){
foreach my $delay (@delays){
    $i += 1 ; 

    $configuration->{'design'}[$i]{'top_FPGen.FPGen.Architecture'}                = 'DW_FMA' ;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.DW_FMA.ExponentWidth'}        = $exp ;  # FIX ME
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.DW_FMA.FractionWidth'}        = $frac ;  # FIX ME
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.DW_FMA.PipelineDepth'}        = $pipe;

    $configuration->{'make_params'}[$i]{'VT'}      = $vt;
    $configuration->{'make_params'}[$i]{'VOLTAGE'} = $vt eq 'lvt' ? '1v0' : ( $vt eq 'svt' ? '0v9' : '0v8' );

    $configuration->{'target_delay'}[$i] = $delay;
}}}


foreach my $pipe  (@pipes){
foreach my $vt    (@vts){
foreach my $pump  (@pumps){
foreach my $delay (@delays){
    $i += 1 ; 

    $configuration->{'design'}[$i]{'top_FPGen.FPGen.Architecture'}                = 'FMA' ;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.FMA.MulShift.MUL0.Designware_MODE'} = 'ON' ;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.FMA.ExponentWidth'}           = $exp ; # FIX ME
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.FMA.FractionWidth'}           = $frac ; # FIX ME
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.FMA.PipelineDepth'}           = $pipe;

    $configuration->{'make_params'}[$i]{'VT'}      = $vt;
    $configuration->{'make_params'}[$i]{'VOLTAGE'} = $vt eq 'lvt' ? '1v0' : ( $vt eq 'svt' ? '0v9' : '0v8' );

    $configuration->{'target_delay'}[$i] = $delay;

}}}}

foreach my $tree  (@trees){
foreach my $booth (@booths){
foreach my $pipe  (@pipes){
foreach my $vt    (@vts){
foreach my $pump  (@pumps){
foreach my $delay (@delays){
    $i += 1 ; 

    $configuration->{'design'}[$i]{'top_FPGen.FPGen.Architecture'}                 = 'CMA' ;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.CMA.ExponentWidth'}            = $exp ; # FIX ME
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.CMA.FractionWidth'}            = $frac ; # FIX ME
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.CMA.PipelineDepth'}            = $pipe;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.CMA.MUL.Mult.MultP.BoothType'} = $booth ;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.CMA.MUL.Mult.MultP.TreeType'}  = $tree ;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.CMA.EnableMultiplePumping'}    = $pump ;

    $configuration->{'make_params'}[$i]{'VT'}      = $vt;
    $configuration->{'make_params'}[$i]{'VOLTAGE'} = $vt eq 'lvt' ? '1v0' : ( $vt eq 'svt' ? '0v9' : '0v8' );

    $configuration->{'target_delay'}[$i] = $delay;

}}}}}}

foreach my $pipe  (@pipes){
foreach my $vt    (@vts){
foreach my $pump  (@pumps){
foreach my $delay (@delays){
    $i += 1 ; 

    $configuration->{'design'}[$i]{'top_FPGen.FPGen.Architecture'}                = 'CMA' ;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.CMA.MUL.Mult.MultP.Designware_MODE'} = 'ON' ;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.CMA.PipelineDepth'}            = $pipe;
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.CMA.ExponentWidth'}            = $exp ; # FIX ME
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.CMA.FractionWidth'}            = $frac ; # FIX ME
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.CMA.EnableMultiplePumping'}    = $pump ;

    $configuration->{'make_params'}[$i]{'VT'}      = $vt;
    $configuration->{'make_params'}[$i]{'VOLTAGE'} = $vt eq 'lvt' ? '1v0' : ( $vt eq 'svt' ? '0v9' : '0v8' );

    $configuration->{'target_delay'}[$i] = $delay;

}}}}



$i += 1 ; 
$configuration->{'runs'} = $i ;

print Dump $configuration;
#print Dumper($configuration)
