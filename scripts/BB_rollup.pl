#!/usr/bin/perl
 
use strict;
use warnings ;
use Getopt::Std;

#use lib "$ENV{FPGEN}/perl_libs/YAML-0.84/lib";
use YAML ;

use Storable;

my %options ;
getopts("hp:d:t:", \%options);

my $makeArguments = "" ; 
foreach my $mA ( @ARGV ){ $makeArguments .= " $mA " ;}

$options{d} or die "Error: Must specify the current design name with -d flag...\n" ;
$options{t} or die "Error: Must specify the target to place reults ...\n" ;

$makeArguments =~ m/VT/           or die "VT not specified in BB_rollup.pl\n" ;
$makeArguments =~ m/Voltage/      or die "Voltage not specified in BB_rollup.pl\n" ;
$makeArguments =~ m/target_delay/ or die "target_delay not specified in BB_rollup.pl\n" ;
$makeArguments =~ m/io2core/      or die "io2core not specified in BB_rollup.pl\n" ;
$makeArguments =~ m/DESIGN_FILE/  or die "designFile not specified in BB_rollup.pl\n" ;
sub extractMakeVal{
    my $name  = shift ;
    my @Parse = $makeArguments =~ m/$name=(\S+)/ ;
    my $Val   = $Parse[0];
    return $Val ;
}

my $VT             = extractMakeVal( "VT" ) ;
my $Target_Voltage = extractMakeVal( "Voltage" ) ;  $Target_Voltage =~ s/v/./ ;
my $Target_Delay   = extractMakeVal( "target_delay" ) ;
my $IO2CORE        = extractMakeVal( "io2core" ) ;
my $designFile     = extractMakeVal( "DESIGN_FILE" );
my $SmartRetiming  = extractMakeVal( "SmartRetiming" );
my $EnableClockGating =extractMakeVal( "EnableClockGating" );

-e $designFile or die "Error: Sorry DesignFile is missing....\n" ;
my $designString = `cat $designFile` ;
my @pipeRes = $designString =~ m/PipelineDepth\s+(\d)/ ;
if( scalar( @pipeRes ) ){
    $options{p} = $pipeRes[0] > 1 ? 1 : 0 ;
} else {
    $options{p} = 0 ;
}


my %globalConfig ;
$globalConfig{TOP}{VT}                =  $VT ;
$globalConfig{TOP}{Target_Voltage}    =  $Target_Voltage ;
$globalConfig{TOP}{Target_Delay}      =  $Target_Delay ;
$globalConfig{TOP}{IO2CORE}           =  $IO2CORE ;
$globalConfig{TOP}{designFile}        =  $designFile ;
$globalConfig{TOP}{SmartRetiming}     =  $SmartRetiming ;
$globalConfig{TOP}{EnableClockGating} =  $EnableClockGating ;

$globalConfig{INFO}{DC_LOG}      = extractMakeVal("DC_LOG") ;
$globalConfig{INFO}{ICC_LOG}     = extractMakeVal("ICC_LOG") ;
$globalConfig{INFO}{ICC_OPT_LOG} = extractMakeVal("ICC_OPT_LOG") ;

my $compStatus = 1 ;
-e "comp_bb.log" or $compStatus = 0 ;
`grep Error comp_bb.log | grep :` and $compStatus = 0 ;
$globalConfig{STAT}{Compile} =  $compStatus ;

my $runStatus = 1 ;
-e "run_bb.log" or  $runStatus = 0 ;
`grep Error run_bb.log | grep :` and $runStatus = 0 ;
$globalConfig{STAT}{Run} = $runStatus ;

my $synStatus = 1 ;
-e $globalConfig{INFO}{DC_LOG} or $synStatus = 0 ;
`grep Error $globalConfig{INFO}{DC_LOG} | grep :` and $synStatus = 0 ;
`grep Fatal $globalConfig{INFO}{DC_LOG} | grep :` and $synStatus = 0 ;
$globalConfig{STAT}{Synthesis} = $synStatus ;

my $synStatus2 = 1 ;
-e $globalConfig{INFO}{ICC_LOG} or $synStatus2 = 0 ;
`grep Error $globalConfig{INFO}{ICC_LOG} | grep :` and $synStatus2 = 0 ;
`grep Fatal $globalConfig{INFO}{ICC_LOG} | grep :` and $synStatus2 = 0 ;
$globalConfig{STAT}{PlaceRoute} = $synStatus ;

my $synStatus3 = 1 ;
-e $globalConfig{INFO}{ICC_OPT_LOG} or $synStatus3 = 0 ;
`grep Error $globalConfig{INFO}{ICC_OPT_LOG} | grep :` and $synStatus3 = 0 ;
`grep Fatal $globalConfig{INFO}{ICC_OPT_LOG} | grep :` and $synStatus3 = 0 ;
$globalConfig{STAT}{OptPlaceRoute} = $synStatus ;


#get a sorted list of all report files
my @files = <synthesis/*/reports/*.mapped.timing.rpt>;
my %r  ;
my $ri = -1 ;

foreach my $file ( @files ) {
   
    $file =~ /(.vt_\dv\d_.*)\/reports\/(.*)\.(.vt)_(\dv\d)\.(.*)\.mapped\.timing\.rpt/;

    $ri++ ;
    $ri++ ;
    my $rj = $ri - 1  ;
    #$r{result}[$ri] = \%globalConfig;
    #$r{result}[$rj] = \%globalConfig;

    my $folder_name=$1;
    my $design_name = $2;
    my $vt = $3;
    my $vdd = $4;
    my $target_delay = $5;
    my $prefix = "$design_name.${vt}_$vdd.$target_delay";
    my $optimized_prefix = "$design_name.optimized.${vt}_$vdd.$target_delay";

    $folder_name = "syn_" . $folder_name ;

    print "\t\tINFO: Checking folder $folder_name at synthesis/$folder_name/reports \n" ;
    print "\t\tINFO: Checking prefix $prefix\n" ;
    print `ls synthesis/$folder_name/reports/ | grep $prefix` ;
    print "\t\tINFO: Checking prefix $optimized_prefix\n" ;
    print `ls synthesis/$folder_name/reports/ | grep $optimized_prefix` ;



    my $vdd_param = $vdd; $vdd_param =~ s/v/./ ;

    $r{result}[$ri]{INFO}{DESIGN} = $design_name;
    $r{result}[$ri]{INFO}{DESIGN_NAME} = $options{d} ;
    $r{result}[$ri]{TOP}{Voltage} = $vdd_param ;
    $r{result}[$ri]{TOP}{VT} = $vt ;
    $r{result}[$ri]{TOP}{RP} = 1 ;

    $r{result}[$rj]{INFO}{DESIGN} = $design_name;
    $r{result}[$rj]{INFO}{DESIGN_NAME} = $options{d} ;
    $r{result}[$rj]{TOP}{Voltage} = $vdd_param ;
    $r{result}[$rj]{TOP}{RP} = 0 ;

    my @report_files = <synthesis/$folder_name/reports/$prefix.mapped.timing.rpt>;
    scalar( @report_files ) or warn "Missing mapped timing\n" ;
    my $mapped_delay = 1000;
    my $design_timing_mapped_good = 0 ;
    my $report_file ;
    foreach $report_file (@report_files) {
	open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
	while(<REPORTFILE>) { 
	    if ( $_ =~ /data arrival time\s+-?(\d+\.?\d*)/ && $1 < $mapped_delay) {    
		$mapped_delay = $1;
	    }
	}
	close REPORTFILE;
	`grep slack $report_file | grep MET`      and $design_timing_mapped_good = 1 ;
	`grep slack $report_file | grep VIOLATED` and $design_timing_mapped_good = 0 ;
    }
   

    #FIXME -> Grab 
    #Area
    #-----------------------------------
    #Combinational Area:     3067.066845
    #Noncombinational Area:  1967.212807
    #Net Area:                  0.000000
    #-----------------------------------
    #Cell Area:              5034.279652
    #Design Area:            5034.279652

  my $mapped_core_area="-1";
  @report_files = <synthesis/$folder_name/reports/$prefix.mapped.qor.rpt>;
    scalar( @report_files ) or warn "Missing mapped area\n" ;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) {
      if ( $_ =~ /Design Area:\s+(\d+\.?\d*)/ ) {
	  $mapped_core_area = $1;
	  $mapped_core_area = $mapped_core_area / 1000000.0 ;
      }
    }
    close REPORTFILE;
  }

  my $mapped_dynamic_power="-1";
  my $mapped_leakage_power="-1";
  @report_files = <synthesis/$folder_name/reports/$prefix.mapped.muladd_power.*>;
    scalar( @report_files ) or warn "Missing mapped power\n" ;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) {
	 if ( $_ =~ /Total Dynamic Power\s*=\s+(\d+\.?\d*((e|E)-?\d+)?)\s*(.W)/ ) { 
		$mapped_dynamic_power = ($4 eq "uW")? $1 / 1000.0 : $1 ;
		$mapped_dynamic_power = ($4 eq " W")? $1 * 1000.0 : $mapped_dynamic_power ; 
	 }
	 if ( $_ =~ /Cell Leakage Power\s*=\s+(\d+\.?\d*((e|E)-?\d+)?)\s*(.W)/ ) {
           $mapped_leakage_power = ($4 eq "uW")? $1 / 1000.0: $1;
           $mapped_leakage_power = ($4 eq " W")? $1 * 1000.0: $mapped_leakage_power;
	 }
     }
    close REPORTFILE;
  }

    my @CombCellCount ;
    my @SeqCellCount  ;
    my $qorStatus    ;
    my $mapped_comb_cell_count = -1;
    my $mapped_seq_cell_count = -1;

    @report_files = <synthesis/$folder_name/reports/$prefix.mapped.qor.*>;
    scalar( @report_files ) or warn "Missing mapped qor\n" ;
    if( scalar( @report_files ) ){
	$report_file = $report_files[0];
	$qorStatus = `cat $report_file` ;
	@CombCellCount = $qorStatus =~ m/Combinational Cell Count:\s+(\d+)/ ;
	@SeqCellCount  = $qorStatus =~ m/Sequential Cell Count:\s+(\d+)/ ;
	$mapped_comb_cell_count = $CombCellCount[0];
	$mapped_seq_cell_count = $SeqCellCount[0];
    }

  @report_files = <synthesis/$folder_name/reports/$prefix.routed.timing.*>;
    scalar( @report_files ) or warn "Missing routed timing\n" ;
    my $routed_delay = 1000;
    my $design_timing_routed_good;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) { 
      if ( $_ =~ /data arrival time\s+-?(\d+\.?\d*)/ && $1 < $routed_delay) {    
	    $routed_delay = $1;
      }
    }
    close REPORTFILE;
    `grep slack $report_file | grep MET`      and $design_timing_routed_good = 1 ;
    `grep slack $report_file | grep VIOLATED` and $design_timing_routed_good = 0 ;
  }

  my $routed_core_area="-1";
  @report_files = <synthesis/$folder_name/reports/$design_name.${vt}.$target_delay.routed.area.*>;
    scalar( @report_files ) or warn "Missing routed area\n" ;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) {
      if ( $_ =~ /Core Area:\s+(\d+\.?\d*)/ ) {
        $routed_core_area = $1;
        $routed_core_area = $routed_core_area / 1000000.0;
      }
    }
    close REPORTFILE;
  }

  my $routed_dynamic_power="-1";
  my $routed_leakage_power="-1";
  @report_files = <synthesis/$folder_name/reports/$prefix.routed.muladd_power.*>;
    scalar( @report_files ) or warn "Missing routed power\n" ;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) {
	 if ( $_ =~ /Total Dynamic Power\s*=\s+(\d+\.?\d*((e|E)-?\d+)?)\s*(.W)/ ) {    
		$routed_dynamic_power = ($4 eq "uW")? $1 /1000.0 : $1 ;
		$routed_dynamic_power = ($4 eq " W")? $1 * 1000.0 : $routed_dynamic_power ;
	 }
	 if ( $_ =~ /Cell Leakage Power\s*=\s+(\d+\.?\d*((e|E)-?\d+)?)\s*(.W)/ ) {
           $routed_leakage_power = ($4 eq "uW")? $1 / 1000.0: $1;
           $routed_leakage_power = ($4 eq " W")? $1 * 1000.0: $routed_leakage_power;
	 }
     }
    close REPORTFILE;
  }

    my $routed_comb_cell_count = -1;
    my $routed_seq_cell_count  = -1;

    @report_files = <synthesis/$folder_name/reports/$prefix.routed.qor.*>;
    scalar( @report_files ) or warn "Missing routed qor\n" ;
    if( scalar( @report_files ) ){
	$report_file = $report_files[0];
	$qorStatus = `cat $report_file` ;
	@CombCellCount = $qorStatus =~ m/Combinational Cell Count:\s+(\d+)/ ;
	@SeqCellCount  = $qorStatus =~ m/Sequential Cell Count:\s+(\d+)/ ;
	$routed_comb_cell_count = $CombCellCount[0];
	$routed_seq_cell_count  = $SeqCellCount[0];
    }


  @report_files = <synthesis/$folder_name/reports/$optimized_prefix.routed.timing.*>;
    scalar( @report_files ) or warn "Missing optimized timing\n" ;
  my $optimized_delay = 1000;
    my  $design_timing_optimized_good = 0 ;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) { 
      if ( $_ =~ /data arrival time\s+-?(\d+\.?\d*)/ && $1 < $optimized_delay) {    
	    $optimized_delay = $1;
      }
    }
    close REPORTFILE;
    `grep slack $report_file | grep MET`      and $design_timing_optimized_good = 1 ;
    `grep slack $report_file | grep VIOLATED` and $design_timing_optimized_good = 0 ;
  }


  my $optimized_core_area="-1";
  @report_files = <synthesis/$folder_name/reports/$design_name.optimized.${vt}.$target_delay.routed.area.*>;
    scalar( @report_files ) or warn "Missing optimized area\n" ;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) {
      if ( $_ =~ /Core Area:\s+(\d+\.?\d*)/ ) {
        $optimized_core_area = $1;
	$optimized_core_area = $optimized_core_area / 1000000.0;     
      }
    }
    close REPORTFILE;
  }

  my $optimized_dynamic_power="";
  my $optimized_leakage_power="";
  @report_files = <synthesis/$folder_name/reports/$optimized_prefix.routed.muladd_power.*>;
    scalar( @report_files ) or warn "Missing optimized power\n" ;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) {
	 if ( $_ =~ /Total Dynamic Power\s*=\s+(\d+\.?\d*((e|E)-?\d+)?)\s*(.W)/ ) {    
		$optimized_dynamic_power = ($4 eq "uW")? $1 / 1000.0: $1;
		$optimized_dynamic_power = ($4 eq " W")? $1 * 1000.0: $optimized_dynamic_power;
	 }
	 if ( $_ =~ /Cell Leakage Power\s*=\s+(\d+\.?\d*((e|E)-?\d+)?)\s*(.W)/ ) {
           $optimized_leakage_power = ($4 eq "uW")? $1 / 1000.0: $1;
           $optimized_leakage_power = ($4 eq " W")? $1 * 1000.0: $optimized_leakage_power;
	 }
     }
    close REPORTFILE;
  }

    my $optimized_comb_cell_count = -1;
    my $optimized_seq_cell_count  = -1;

    @report_files = <synthesis/$folder_name/reports/$optimized_prefix.routed.qor.*>;
    scalar( @report_files ) or warn "Missing mapped qor\n" ;
    if( scalar( @report_files ) ){
	$report_file = $report_files[0];
	$qorStatus = `cat $report_file` ;
	@CombCellCount = $qorStatus =~ m/Combinational Cell Count:\s+(\d+)/ ;
	@SeqCellCount  = $qorStatus =~ m/Sequential Cell Count:\s+(\d+)/ ;
	$optimized_comb_cell_count = $CombCellCount[0];
	$optimized_seq_cell_count  = $SeqCellCount[0];
    }


    my $mapped_dynamic_energy    ;
    my $routed_dynamic_energy    ;
    my $optimized_dynamic_energy ;

    if( $options{p} ){
     $mapped_dynamic_energy    = $mapped_dynamic_power    * ($Target_Delay/1000.0) ; #pJ
     $routed_dynamic_energy    = $routed_dynamic_power    * ($Target_Delay/1000.0) ; #pJ
     $optimized_dynamic_energy = $optimized_dynamic_power * ($Target_Delay/1000.0) ; #pJ
    } else {
     $mapped_dynamic_energy    = $mapped_dynamic_power ;
     $routed_dynamic_energy    = $routed_dynamic_power  ;
     $optimized_dynamic_energy = $optimized_dynamic_power  ;
    }

    my $mapped_throughput = 1.0 / $mapped_delay ;  #Result in ops per nS
    my $routed_throughput = 1.0 / $routed_delay ;  #Result in ops per nS
    my $optimized_throughput = 1.0 / $optimized_delay ; #Result in ops per nS

    my $mapped_throughput_Density = 1.0 / ( $mapped_delay * $mapped_core_area );  #Result in ops per nS per sqmm
    my $routed_throughput_Density = 1.0 / ( $routed_delay * $routed_core_area );  #Result in ops per nS per sqmm
    my $optimized_throughput_Density = 1.0 / ( $optimized_delay * $optimized_core_area );  #Result in ops per nS per sqmm

    my $mapped_energy_per_op = $mapped_dynamic_energy + $optimized_leakage_power * ($Target_Delay/1000.0); #pJ/op
    my $routed_energy_per_op = $routed_dynamic_energy + $optimized_leakage_power * ($Target_Delay/1000.0); #pJ/op
    my $optimized_energy_per_op = $optimized_dynamic_energy + $optimized_leakage_power * ($Target_Delay/1000.0); #pJ/op

   $r{result}[$ri]{INFO}{VT} = $VT ;
   $r{result}[$ri]{INFO}{TARGET_VOLTAGE} = $Target_Voltage ;
   $r{result}[$ri]{INFO}{TARGET_DELAY} =  ($Target_Delay/1000.0) ;
   $r{result}[$ri]{INFO}{IO2CORE} = $IO2CORE ;
    if( ($VT eq $vt) and ($vdd_param eq $Target_Voltage) and ($target_delay eq $Target_Delay) ){
	$r{result}[$ri]{INFO}{TARGET} = 1 ;
    } else {
	$r{result}[$ri]{INFO}{TARGET}  = 0 ;
    }
   $r{result}[$ri]{INFO}{DESIGN} = $design_name ;
   $r{result}[$ri]{INFO}{DESIGN_NAME} = $options{d} ;
   $r{result}[$ri]{TOP}{Voltage} = $vdd_param ;
   $r{result}[$ri]{TOP}{VT} = $vt ;
   $r{result}[$ri]{TOP}{RP} = 'YES' ;
   $r{result}[$ri]{STAT}{Comp_Good} = $compStatus ;
   $r{result}[$ri]{STAT}{Run_Good} = $runStatus ;
   $r{result}[$ri]{STAT}{Synthesis_Good} = $synStatus ;
   $r{result}[$ri]{STAT}{Timing_Good} = $synStatus ; 
   $r{result}[$ri]{COST}{Mapped_Delay} = $mapped_delay ;
   $r{result}[$ri]{COST}{Routed_Delay} = $routed_delay ;
   $r{result}[$ri]{COST}{Optimized_Delay} = $optimized_delay ;
   $r{result}[$ri]{COST}{Delay} = $optimized_delay ;
   $r{result}[$ri]{COST}{Mapped_Area} = $mapped_core_area ;
   $r{result}[$ri]{COST}{Routed_Area} = $routed_core_area ;
   $r{result}[$ri]{COST}{Optimized_Area} = $optimized_core_area ;
   $r{result}[$ri]{COST}{Area} = $optimized_core_area ;
   $r{result}[$ri]{COST}{Mapped_Dyn_Power} = $mapped_dynamic_power ;
   $r{result}[$ri]{COST}{Routed_Dyn_Power} = $routed_dynamic_power ;
   $r{result}[$ri]{COST}{Optimized_Dyn_Power} = $optimized_dynamic_power ;
   $r{result}[$ri]{COST}{Dyn_Power} = $optimized_dynamic_power ;
   $r{result}[$ri]{COST}{Mapped_Dyn_Energy} = $mapped_dynamic_energy ;
   $r{result}[$ri]{COST}{Routed_Dyn_Energy} = $routed_dynamic_energy ;
   $r{result}[$ri]{COST}{Optimized_Dyn_Energy} = $optimized_dynamic_energy ;
   $r{result}[$ri]{COST}{Dyn_Energy} = $optimized_dynamic_energy ;
   $r{result}[$ri]{COST}{Mapped_Leak_Power} = $mapped_leakage_power ;
   $r{result}[$ri]{COST}{Routed_Leak_Power} = $routed_leakage_power ;
   $r{result}[$ri]{COST}{Optimized_Leak_Power} = $optimized_leakage_power;
   $r{result}[$ri]{COST}{Leak_Power} = $optimized_leakage_power;

   $r{result}[$ri]{COST}{Mapped_Energy_per_Operation} = $mapped_energy_per_op;
   $r{result}[$ri]{COST}{Routed_Energy_per_Operation} = $routed_energy_per_op;
   $r{result}[$ri]{COST}{Optimized_Energy_per_Operation} = $optimized_energy_per_op;
   $r{result}[$ri]{COST}{Energy_per_Operation} = $optimized_energy_per_op;

   $r{result}[$ri]{PERF}{Mapped_Throughput} = $mapped_throughput;
   $r{result}[$ri]{PERF}{Routed_Throughput} = $routed_throughput;
   $r{result}[$ri]{PERF}{Optimized_Throughput} = $optimized_throughput;
   $r{result}[$ri]{PERF}{Throughput} = $optimized_throughput;

   $r{result}[$ri]{PERF}{Mapped_Throughput_Density} = $mapped_throughput_Density;
   $r{result}[$ri]{PERF}{Routed_Throughput_Density} = $routed_throughput_Density;
   $r{result}[$ri]{PERF}{Optimized_Throughput_Density} = $optimized_throughput_Density;
   $r{result}[$ri]{PERF}{Throughput_Density} = $optimized_throughput_Density;

   $r{result}[$ri]{INFO}{Suggest_Delay} = $optimized_delay;
   $r{result}[$ri]{INFO}{Mapped_Comb_Cell_Count} = $mapped_comb_cell_count;
   $r{result}[$ri]{INFO}{Mapped_Seq_Cell_Count} = $mapped_seq_cell_count;
   $r{result}[$ri]{INFO}{Routed_Comb_Cell_Count} = $routed_comb_cell_count;
   $r{result}[$ri]{INFO}{Routed_Seq_Cell_Count} = $routed_seq_cell_count;
   $r{result}[$ri]{INFO}{Optimized_Comb_Cell_Count} = $optimized_comb_cell_count;
   $r{result}[$ri]{INFO}{Optimized_Seq_Cell_Count} = $optimized_seq_cell_count;
   $r{result}[$ri]{INFO}{Comb_Cell_Count} = $optimized_comb_cell_count;
   $r{result}[$ri]{INFO}{Seq_Cell_Count} = $optimized_seq_cell_count;

    #NON-RP RESULT
   $r{result}[$rj]{INFO}{VT} = $VT ;
   $r{result}[$rj]{INFO}{TARGET_VOLTAGE} = $Target_Voltage ;
   $r{result}[$rj]{INFO}{TARGET_DELAY} = " . ($Target_Delay/1000.0) . " ;
   $r{result}[$rj]{INFO}{IO2CORE} = $IO2CORE ;
   $r{result}[$rj]{INFO}{TARGET} = 0 ;
   $r{result}[$rj]{INFO}{DESIGN} = $design_name ;
   $r{result}[$rj]{INFO}{DESIGN_NAME} = $options{d} ;
   $r{result}[$rj]{TOP}{Voltage} = $vdd_param ;
   $r{result}[$rj]{TOP}{VT} = $vt ;
   $r{result}[$rj]{TOP}{RP} = 'NO' ;
   $r{result}[$rj]{STAT}{Comp_Good} = $compStatus ;
   $r{result}[$rj]{STAT}{Run_Good} = $runStatus ;
   $r{result}[$rj]{STAT}{Synthesis_Good} = $synStatus ;
   $r{result}[$rj]{STAT}{Timing_Good} = $synStatus ;
   $r{result}[$rj]{COST}{Mapped_Delay} = $mapped_delay ;
   $r{result}[$rj]{COST}{Routed_Delay} = $routed_delay ;
   $r{result}[$rj]{COST}{Optimized_Delay} = $optimized_delay ;
   $r{result}[$rj]{COST}{Delay} = $routed_delay ;
   $r{result}[$rj]{COST}{Mapped_Area} = $mapped_core_area ;
   $r{result}[$rj]{COST}{Routed_Area} = $routed_core_area ;
   $r{result}[$rj]{COST}{Optimized_Area} = $optimized_core_area ;
   $r{result}[$rj]{COST}{Area} = $routed_core_area ;
   $r{result}[$rj]{COST}{Mapped_Dyn_Power} = $mapped_dynamic_power ;
   $r{result}[$rj]{COST}{Routed_Dyn_Power} = $routed_dynamic_power ;
   $r{result}[$rj]{COST}{Optimized_Dyn_Power} = $optimized_dynamic_power ;
   $r{result}[$rj]{COST}{Dyn_Power} = $routed_dynamic_power ;
   $r{result}[$rj]{COST}{Mapped_Dyn_Energy} = $mapped_dynamic_energy ;
   $r{result}[$rj]{COST}{Routed_Dyn_Energy} = $routed_dynamic_energy ;
   $r{result}[$rj]{COST}{Optimized_Dyn_Energy} = $optimized_dynamic_energy ;
   $r{result}[$rj]{COST}{Dyn_Energy} = $routed_dynamic_energy ;
   $r{result}[$rj]{COST}{Mapped_Leak_Power} = $mapped_leakage_power ;
   $r{result}[$rj]{COST}{Routed_Leak_Power} = $routed_leakage_power ;
   $r{result}[$rj]{COST}{Optimized_Leak_Power} = $optimized_leakage_power;
   $r{result}[$rj]{COST}{Leak_Power} = $routed_leakage_power;

   $r{result}[$rj]{COST}{Mapped_Energy_per_Operation} = $mapped_energy_per_op;
   $r{result}[$rj]{COST}{Routed_Energy_per_Operation} = $routed_energy_per_op;
   $r{result}[$rj]{COST}{Optimized_Energy_per_Operation} = $optimized_energy_per_op;
   $r{result}[$rj]{COST}{Energy_per_Operation} = $routed_energy_per_op;

   $r{result}[$rj]{PERF}{Mapped_Throughput} = $mapped_throughput;
   $r{result}[$rj]{PERF}{Routed_Throughput} = $routed_throughput;
   $r{result}[$rj]{PERF}{Optimized_Throughput} = $optimized_throughput;
   $r{result}[$rj]{PERF}{Throughput} = $routed_throughput;

   $r{result}[$rj]{PERF}{Mapped_Throughput_Density} = $mapped_throughput_Density;
   $r{result}[$rj]{PERF}{Routed_Throughput_Density} = $routed_throughput_Density;
   $r{result}[$rj]{PERF}{Optimized_Throughput_Density} = $optimized_throughput_Density;
   $r{result}[$rj]{PERF}{Throughput_Density} = $routed_throughput_Density;


   $r{result}[$rj]{INFO}{Suggest_Delay} = $optimized_delay;
   $r{result}[$rj]{INFO}{Mapped_Comb_Cell_Count} = $mapped_comb_cell_count;
   $r{result}[$rj]{INFO}{Mapped_Seq_Cell_Count} = $mapped_seq_cell_count;
   $r{result}[$rj]{INFO}{Routed_Comb_Cell_Count} = $routed_comb_cell_count;
   $r{result}[$rj]{INFO}{Routed_Seq_Cell_Count} = $routed_seq_cell_count;
   $r{result}[$rj]{INFO}{Optimized_Comb_Cell_Count} = $optimized_comb_cell_count;
   $r{result}[$rj]{INFO}{Optimized_Seq_Cell_Count} = $optimized_seq_cell_count;
   $r{result}[$rj]{INFO}{Comb_Cell_Count} = $routed_comb_cell_count;
   $r{result}[$rj]{INFO}{Seq_Cell_Count} = $routed_seq_cell_count;

}

open( TARGET , ">$options{t}" ) ;

print( TARGET  Dump(\%r) );
print Dump( \%r ) ;
close( TARGET ) ;

print "Pushed result to $options{t}\n" ;
