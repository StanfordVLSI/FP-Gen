#!/usr/bin/perl
 
use strict;
use warnings ;
use Getopt::Std;

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

-e $designFile or die "Error: Sorry DesignFile is missing....\n" ;
my $designString = `cat $designFile` ;
my @pipeRes = $designString =~ m/PipelineDepth\s+(\d)/ ;
if( scalar( @pipeRes ) ){
    $options{p} = $pipeRes[0] > 1 ? 1 : 0 ;
} else {
    $options{p} = 0 ;
}

open( TARGET , "| tee $options{t}" );


my $compStatus = 1 ;
-e "comp_bb.log" or $compStatus = 0 ;
`grep Error comp_bb.log | grep :` and $compStatus = 0 ;

my $runStatus = 1 ;
-e "run_bb.log" or  $runStatus = 0 ;
`grep Error run_bb.log | grep :` and $runStatus = 0 ;

my $synStatus = 1 ;
-e "syn_bb.log" or $synStatus = 0 ;
`grep Error syn_bb.log | grep :` and $synStatus = 0 ;
`grep Fatal syn_bb.log | grep :` and $synStatus = 0 ;

#get a sorted list of all report files
my @files = <synthesis/*/reports/*.mapped.timing.rpt>;
#print "design, Vth, Vdd, mapped delay, routed delay, optimized delay, mapped core area, routed core area, optimized core area, mapped dynamic power, routed dynamic power, optimized dynamic power, mapped leakage power, routed leakage power, optimized leakage power\n";

unless( scalar( @files) ){
    print TARGET "INFO_VT:$VT\n" ;
    print TARGET "INFO_TARGET_VOLTAGE:$Target_Voltage\n" ;
    print TARGET "INFO_TARGET_DELAY:" . ($Target_Delay/1000.0) . "\n" ;
    print TARGET "INFO_IO2CORE:$IO2CORE\n" ;
    print TARGET "INFO_TARGET:1\n" ;
    print TARGET "STAT_Comp_Good:$compStatus\n" ;
    print TARGET "STAT_Run_Good:$runStatus\n" ;
    print TARGET "STAT_Synthesis_Good:$synStatus\n" ;
}

foreach my $file ( @files ) {
   
    $file =~ /(.vt_\dv\d_.*)\/reports\/(.*)\.(.vt)_(\dv\d)\.(.*)\.mapped\.timing\.rpt/;


    my $folder_name=$1;
    my $design_name = $2;
    my $vt = $3;
    my $vdd = $4;
    my $target_delay = $5;
    my $prefix = "$design_name.${vt}_$vdd.$target_delay";
    my $optimized_prefix = "$design_name.optimized.${vt}_$vdd.$target_delay";

    my $vdd_param = $vdd; $vdd_param =~ s/v/./ ;

    print TARGET "INFO_DESIGN:$design_name\n" ;
    print TARGET "INFO_DESIGN_NAME:$options{d}\n" ;
    print TARGET "TOP.Voltage:$vdd_param\n" ;
    print TARGET "TOP.VT:$vt\n" ;

    print TARGET "STAT_Comp_Good:$compStatus\n" ;
    print TARGET "STAT_Run_Good:$runStatus\n" ;
    print TARGET "STAT_Synthesis_Good:$synStatus\n" ;
    
    #STAT for 


    my @report_files = <synthesis/$folder_name/reports/$prefix.mapped.timing.*>;
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
    
  my $mapped_core_area="";
  @report_files = <synthesis/$folder_name/reports/$design_name.${vt}.$target_delay.mapped.area.*>;
    scalar( @report_files ) or warn "Missing mapped area\n" ;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) {
      if ( $_ =~ /Total cell area:\s+(\d+\.?\d*)/ ) {
	  $mapped_core_area = $1;
	  $mapped_core_area = $mapped_core_area / 1000000.0 ;
      }
    }
    close REPORTFILE;
  }

  my $mapped_dynamic_power="-1";
  my $mapped_leakage_power="-1";
  @report_files = <synthesis/$folder_name/reports/$prefix.mapped.power.*>;
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

  my $routed_core_area="";
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
  @report_files = <synthesis/$folder_name/reports/$prefix.routed.power.*>;
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


  my $optimized_core_area="";
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
  @report_files = <synthesis/$folder_name/reports/$optimized_prefix.routed.power.*>;
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
     $mapped_dynamic_energy    = $mapped_dynamic_power    * ($Target_Delay/1000.0) ;
     $routed_dynamic_energy    = $routed_dynamic_power    * ($Target_Delay/1000.0) ;
     $optimized_dynamic_energy = $optimized_dynamic_power * ($Target_Delay/1000.0) ;
    } else {
     $mapped_dynamic_energy    = $mapped_dynamic_power ;
     $routed_dynamic_energy    = $routed_dynamic_power  ;
     $optimized_dynamic_energy = $optimized_dynamic_power  ;
    }


    #RP RESULTS
    print TARGET "INFO_VT:$VT\n" ;
    print TARGET "INFO_TARGET_VOLTAGE:$Target_Voltage\n" ;
    print TARGET "INFO_TARGET_DELAY:" . ($Target_Delay/1000.0) . "\n" ;
    print TARGET "INFO_IO2CORE:$IO2CORE\n" ;
    if( ($VT eq $vt) and ($vdd_param eq $Target_Voltage) and ($target_delay eq $Target_Delay) ){
	print TARGET "INFO_TARGET:1\n" ;
    } else {
	print TARGET "INFO_TARGET:0\n" ;
    }
    print TARGET "INFO_DESIGN:$design_name\n" ;
    print TARGET "INFO_DESIGN_NAME:$options{d}\n" ;
    print TARGET "TOP.Voltage:$vdd_param\n" ;
    print TARGET "TOP.VT:$vt\n" ;
    print TARGET "TOP.RP:YES\n" ;
    print TARGET "STAT_Comp_Good:$compStatus\n" ;
    print TARGET "STAT_Run_Good:$runStatus\n" ;
    print TARGET "STAT_Synthesis_Good:$synStatus\n" ;
    print TARGET "STAT_Timing_Good:$synStatus\n" ; 
    print TARGET "COST_Mapped_Delay:$mapped_delay\n" ;
    print TARGET "COST_Routed_Delay:$routed_delay\n" ;
    print TARGET "COST_Optimized_Delay:$optimized_delay\n" ;
    print TARGET "COST_Delay:$optimized_delay\n" ;
    print TARGET "COST_Mapped_Area:$mapped_core_area\n" ;
    print TARGET "COST_Routed_Area:$routed_core_area\n" ;
    print TARGET "COST_Optimized_Area:$optimized_core_area\n" ;
    print TARGET "COST_Area:$optimized_core_area\n" ;
    print TARGET "COST_Mapped_Dyn_Power:$mapped_dynamic_power\n" ;
    print TARGET "COST_Routed_Dyn_Power:$routed_dynamic_power\n" ;
    print TARGET "COST_Optimized_Dyn_Power:$optimized_dynamic_power\n" ;
    print TARGET "COST_Dyn_Power:$optimized_dynamic_power\n" ;
    print TARGET "COST_Mapped_Dyn_Energy:$mapped_dynamic_energy\n" ;
    print TARGET "COST_Routed_Dyn_Energy:$routed_dynamic_energy\n" ;
    print TARGET "COST_Optimized_Dyn_Energy:$optimized_dynamic_energy\n" ;
    print TARGET "COST_Dyn_Energy:$optimized_dynamic_energy\n" ;
    print TARGET "COST_Mapped_Leak_Power:$mapped_leakage_power\n" ;
    print TARGET "COST_Routed_Leak_Power:$routed_leakage_power\n" ;
    print TARGET "COST_Optimized_Leak_Power:$optimized_leakage_power\n";
    print TARGET "COST_Leak_Power:$optimized_leakage_power\n";
    print TARGET "INFO_Suggest_Delay:$optimized_delay\n";
    print TARGET "INFO_Mapped_Comb_Cell_Count:$mapped_comb_cell_count\n";
    print TARGET "INFO_Mapped_Seq_Cell_Count:$mapped_seq_cell_count\n";
    print TARGET "INFO_Routed_Comb_Cell_Count:$routed_comb_cell_count\n";
    print TARGET "INFO_Routed_Seq_Cell_Count:$routed_seq_cell_count\n";
    print TARGET "INFO_Optimized_Comb_Cell_Count:$optimized_comb_cell_count\n";
    print TARGET "INFO_Optimized_Seq_Cell_Count:$optimized_seq_cell_count\n";
    print TARGET "INFO_Comb_Cell_Count:$optimized_comb_cell_count\n";
    print TARGET "INFO_Seq_Cell_Count:$optimized_seq_cell_count\n";
    print TARGET "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
    #NON-RP RESULT
    print TARGET "INFO_VT:$VT\n" ;
    print TARGET "INFO_TARGET_VOLTAGE:$Target_Voltage\n" ;
    print TARGET "INFO_TARGET_DELAY:" . ($Target_Delay/1000.0) . "\n" ;
    print TARGET "INFO_IO2CORE:$IO2CORE\n" ;
    print TARGET "INFO_TARGET:0\n" ;
    print TARGET "INFO_DESIGN:$design_name\n" ;
    print TARGET "INFO_DESIGN_NAME:$options{d}\n" ;
    print TARGET "TOP.Voltage:$vdd_param\n" ;
    print TARGET "TOP.VT:$vt\n" ;
    print TARGET "TOP.RP:NO\n" ;
    print TARGET "STAT_Comp_Good:$compStatus\n" ;
    print TARGET "STAT_Run_Good:$runStatus\n" ;
    print TARGET "STAT_Synthesis_Good:$synStatus\n" ;
    print TARGET "STAT_Timing_Good:$synStatus\n" ;
    print TARGET "COST_Mapped_Delay:$mapped_delay\n" ;
    print TARGET "COST_Routed_Delay:$routed_delay\n" ;
    print TARGET "COST_Optimized_Delay:$optimized_delay\n" ;
    print TARGET "COST_Delay:$routed_delay\n" ;
    print TARGET "COST_Mapped_Area:$mapped_core_area\n" ;
    print TARGET "COST_Routed_Area:$routed_core_area\n" ;
    print TARGET "COST_Optimized_Area:$optimized_core_area\n" ;
    print TARGET "COST_Area:$routed_core_area\n" ;
    print TARGET "COST_Mapped_Dyn_Power:$mapped_dynamic_power\n" ;
    print TARGET "COST_Routed_Dyn_Power:$routed_dynamic_power\n" ;
    print TARGET "COST_Optimized_Dyn_Power:$optimized_dynamic_power\n" ;
    print TARGET "COST_Dyn_Power:$routed_dynamic_power\n" ;
    print TARGET "COST_Mapped_Dyn_Energy:$mapped_dynamic_energy\n" ;
    print TARGET "COST_Routed_Dyn_Energy:$routed_dynamic_energy\n" ;
    print TARGET "COST_Optimized_Dyn_Energy:$optimized_dynamic_energy\n" ;
    print TARGET "COST_Dyn_Energy:$routed_dynamic_energy\n" ;
    print TARGET "COST_Mapped_Leak_Power:$mapped_leakage_power\n" ;
    print TARGET "COST_Routed_Leak_Power:$routed_leakage_power\n" ;
    print TARGET "COST_Optimized_Leak_Power:$optimized_leakage_power\n";
    print TARGET "COST_Leak_Power:$routed_leakage_power\n";
    print TARGET "INFO_Suggest_Delay:$optimized_delay\n";
    print TARGET "INFO_Mapped_Comb_Cell_Count:$mapped_comb_cell_count\n";
    print TARGET "INFO_Mapped_Seq_Cell_Count:$mapped_seq_cell_count\n";
    print TARGET "INFO_Routed_Comb_Cell_Count:$routed_comb_cell_count\n";
    print TARGET "INFO_Routed_Seq_Cell_Count:$routed_seq_cell_count\n";
    print TARGET "INFO_Optimized_Comb_Cell_Count:$optimized_comb_cell_count\n";
    print TARGET "INFO_Optimized_Seq_Cell_Count:$optimized_seq_cell_count\n";
    print TARGET "INFO_Comb_Cell_Count:$routed_comb_cell_count\n";
    print TARGET "INFO_Seq_Cell_Count:$routed_seq_cell_count\n";
    print TARGET "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";


}
