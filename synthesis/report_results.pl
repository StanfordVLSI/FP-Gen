#!/usr/bin/perl

if ( $#ARGV > 0 ){
  $run_folder = shift @ARGV ;
} else {
  $run_folder = "." ;
}

#get a sorted list of all report files
@files = <$run_folder/*/synthesis/*/reports/*.mapped.*_power.rpt>;
print "Design, Configuration, Instruction, Vt, Vdd, clock period, mapped worst slack, routed worst slack, optimized worst slack, mapped area, routed area, optimized_area, mapped dynamic power, routed dynamic power, optimized dynamic power, mapped leakage power, routed leakage power, optimized leakage power\n";

foreach $file (@files) {
  $file =~ /(.*\/(.*)\/synthesis\/syn_(.vt_\dv\d)_\d+\.?\d*_?(.*)?)\/reports\/(.*)\.(.vt)_(\dv\d)\.(\d+\.?\d*)\.mapped\.(.*)_power\.rpt/;
  $folder_name = $1;    #e.g. ./CMA378/synthesis/syn_lvt_1v0_500.0_cg/reports
  $design_name = $2;    #e.g. CMA378
  $run_name = $3;       #e.g. lvt_1v0_500.0
  $appendix = $4;       #e.g. cg
  $top_name = $5;       #e.g. FPGen
  $vt = $6;             #e.g. lvt
  $vdd = $7;            #e.g. 1v0
  $target_delay = $8;   #e.g. 500.0
  $instruction_name=$9; #e.g. mul
  $prefix = "$top_name.${vt}_$vdd.$target_delay";
  $optimized_prefix = "$top_name.optimized.${vt}_$vdd.$target_delay";

  @report_files = <$folder_name/reports/$prefix.mapped.timing.rpt>;
  $mapped_delay = 1000;
  $mapped_worst_slack = 1000;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) { 
      if ( $_ =~ /data arrival time\s+-?(\d+\.?\d*)/ && $1 < $mapped_delay) {    
	$mapped_delay = $1;
      }
      if ( $_ =~ /slack\s+\(\w*\)\s*(-?\d+\.?\d*)/ && $1 < $mapped_worst_slack) {    
	$mapped_worst_slack = $1;
      }
    }
    close REPORTFILE;
  }

  $mapped_core_area="";
  @report_files = <$folder_name/reports/$top_name.$run_name.$target_delay.mapped.area.rpt>;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) {
      if ( $_ =~ /Total cell area:\s+(\d+\.?\d*)/ ) {
        $mapped_core_area = $1;
      }
    }
    close REPORTFILE;
  }

  $mapped_dynamic_power="";
  $mapped_leakage_power="";
  @report_files = <$folder_name/reports/$prefix.mapped.${instruction_name}_power.rpt>;
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



  @report_files = <$folder_name/reports/$prefix.routed.timing.*>;
  $routed_delay = 1000;
  $routed_worst_slack = 1000;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) { 
      if ( $_ =~ /data arrival time\s+-?(\d+\.?\d*)/ && $1 < $routed_delay) {    
	    $routed_delay = $1;
      }
      if ( $_ =~ /slack\s+\(\w*\)\s*(-?\d+\.?\d*)/ && $1 < $routed_worst_slack) {    
	$routed_worst_slack = $1;
      }
    }
    close REPORTFILE;
  }

  $routed_core_area="";
  @report_files = <$folder_name/reports/$top_name.${vt}.$target_delay.routed.area.*>;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) {
      if ( $_ =~ /Core Area:\s+(\d+\.?\d*)/ ) {
        $routed_core_area = $1;
      }
    }
    close REPORTFILE;
  }

  $routed_dynamic_power="";
  $routed_leakage_power="";
  @report_files = <$folder_name/reports/$prefix.routed.${instruction_name}_power.*>;
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

  @report_files = <$folder_name/reports/$optimized_prefix.routed.timing.*>;
  $optimized_delay = 1000;
  $optimized_worst_slack = 1000;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) { 
      if ( $_ =~ /data arrival time\s+-?(\d+\.?\d*)/ && $1 < $optimized_delay) {    
	    $optimized_delay = $1;
      }
      if ( $_ =~ /slack\s+\(\w*\)\s*(-?\d+\.?\d*)/ && $1 < $optimized_worst_slack) {    
	$optimized_worst_slack = $1;
      }
    }
    close REPORTFILE;
  }


  $optimized_core_area="";
  @report_files = <$folder_name/reports/$top_name.optimized.${vt}.$target_delay.routed.area.*>;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) {
      if ( $_ =~ /Core Area:\s+(\d+\.?\d*)/ ) {
        $optimized_core_area = $1;
      }
    }
    close REPORTFILE;
  }

  $optimized_dynamic_power="";
  $optimized_leakage_power="";
  @report_files = <$folder_name/reports/$optimized_prefix.routed.power.*>;
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

  $vdd =~ s/v/./;
  $clk_period_ns = $target_delay / 1000;
  if ($mapped_delay != 1000)
  {
     print "$design_name, $appendix, $instruction_name, $vt, $vdd, $clk_period_ns, $mapped_worst_slack, $routed_worst_slack, $optimized_worst_slack, $mapped_core_area, $routed_core_area, $optimized_core_area, $mapped_dynamic_power, $routed_dynamic_power, $optimized_dynamic_power, $mapped_leakage_power, $routed_leakage_power, $optimized_leakage_power\n";
  }
}
