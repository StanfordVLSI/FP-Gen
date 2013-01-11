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
	  'retry' => 3,
          'jsub_retry' => 5, 
	  'BatchLimit' => 96 , 
          'design_title' => 'FPGEN_REGEN_ALL_V1',
          'param_make_variable' => 'GENESIS_PARAMS',
          'clean_rules' => 'clean',
          'genesis_hierarchy_variable' => 'GENESIS_HIERARCHY',
          'genesis_cfg_xml_variable' => 'GENESIS_CFG_XML',
          'rollup_rules' => 'rollup1',
          'gen_rules' => 'gen',
          'rollup_variable' => 'ROLLUP_TARGET',
	  'cubby_root' => '/tmp/jbrunhaver/runMake/'   
};


my @trees  = ( 'Wallace', 'Array', 'ZM', 'OS1' ) ; # 4 
#my @trees  = ( 'Wallace' , 'OS1'  ) ;
my @pipes  = ( 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10 , 12 , 14 ) ; # 10
#my @pipes  = ( 5 , 6 , 10 , 12 ) ;
my @vts    = ( 'lvt' , 'svt' , 'hvt' ); # 3 
#my @vts    = ( 'lvt' );
my @delays = ( 0.25 , 0.375 , 0.45 , 0.5 , 0.625 , 0.75 , 1.0 , 1.125 , 1.25 , 1.5 , 2.0 ); # 11 
#my @delays = ( 0.1 , 0.2 , 0.25 );
my @pumps  = ('YES' , 'NO' ) ; # 2 
#my @pumps   = ('YES') ;
my @booths  = ( 2 , 3 , 4 ) ; # 4 
#my @booths  = ( 2 , 3  ) ;

my %fracH = (  'half'=>10 , 'single'=>23 , 'double'=>52 , 'double-ext'=>64 , 'quad'=>112  ) ;
my %expH  = (  'half'=>5  , 'single'=>8  , 'double'=>11 , 'double-ext'=>15 , 'quad'=>15  ) ;

my $i = -1 ;

foreach my $prec ( ( 'half' , 'single' , 'double' ) ){


my $frac = $fracH{$prec} ;
my $exp  = $expH{$prec} ; 

foreach my $booth (@booths){
foreach my $tree  (@trees){
foreach my $pipe  (@pipes){
foreach my $vt    (@vts){
foreach my $pump  (@pumps){
foreach my $delay (@delays){
    $i += 1 ; 

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
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.DW_FMA.ExponentWidth'}        = $exp ;  
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.DW_FMA.FractionWidth'}        = $frac ; 
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
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.FMA.ExponentWidth'}           = $exp ;  
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.FMA.FractionWidth'}           = $frac ; 
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
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.CMA.ExponentWidth'}            = $exp ; 
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.CMA.FractionWidth'}            = $frac ;
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
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.CMA.ExponentWidth'}            = $exp ; 
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.CMA.FractionWidth'}            = $frac ; 
    $configuration->{'design'}[$i]{'top_FPGen.FPGen.CMA.EnableMultiplePumping'}    = $pump ;

    $configuration->{'make_params'}[$i]{'VT'}      = $vt;
    $configuration->{'make_params'}[$i]{'VOLTAGE'} = $vt eq 'lvt' ? '1v0' : ( $vt eq 'svt' ? '0v9' : '0v8' );

    $configuration->{'target_delay'}[$i] = $delay;

}}}}


} ## Foreach Precision

$i += 1 ; 
$configuration->{'runs'} = $i ;

print Dump $configuration;
#print Dumper($configuration)
