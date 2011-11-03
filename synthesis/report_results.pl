#!/usr/bin/perl


#get a sorted list of all report files
@files = <*/reports/*.mapped.timing.rpt>;
print "run, mapped delay, routed delay, optimized delay, mapped core area, routed core area, optimized core area, mapped dynamic power, routed dynamic power, optimized dynamic power, mapped leakage power, routed leakage power, optimized leakage power\n";

foreach $file (@files) {
  $file =~ /(.vt)_(\dv\d)_(.*)\/reports\/(.*)\.(.vt)_(\dv\d)\.(.*)\.mapped\.timing\.rpt/;
  $vt = $1;
  $vdd = $2;
  $target_delay = $3;
  $design_name = $4;
  $prefix = "$design_name.${vt}_$vdd.$target_delay";
  $optimized_prefix = "$design_name.optimized.${vt}_$vdd.$target_delay";

  @report_files = <${vt}_${vdd}_$target_delay/reports/$prefix.mapped.timing.*>;
  $mapped_delay = 1000;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) { 
      if ( $_ =~ /data arrival time\s+-?(\d+\.?\d*)/ && $1 < $mapped_delay) {    
	    $mapped_delay = $1;
      }
    }
    close REPORTFILE;
  }

  $mapped_core_area="";
  @report_files = <${vt}_${vdd}_$target_delay/reports/$design_name.${vt}.$target_delay.mapped.area.*>;
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
  @report_files = <${vt}_${vdd}_$target_delay/reports/$prefix.mapped.power.*>;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) {
	 if ( $_ =~ /Total Dynamic Power\s*=\s+(\d+\.?\d*((e|E)-?\d+)?)/ ) {    
		$mapped_dynamic_power = $1;
	 }
	 if ( $_ =~ /Cell Leakage Power\s*=\s+(\d+\.?\d*((e|E)-?\d+)?)\s*(.W)/ ) {
           $mapped_leakage_power = ($4 eq "uW")? $1 / 1000.0: $1;
	 }
     }
    close REPORTFILE;
  }



  @report_files = <${vt}_${vdd}_$target_delay/reports/$prefix.routed.timing.*>;
  $routed_delay = 1000;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) { 
      if ( $_ =~ /data arrival time\s+-?(\d+\.?\d*)/ && $1 < $routed_delay) {    
	    $routed_delay = $1;
      }
    }
    close REPORTFILE;
  }

  $routed_core_area="";
  @report_files = <${vt}_${vdd}_$target_delay/reports/$design_name.${vt}.$target_delay.routed.area.*>;
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
  @report_files = <${vt}_${vdd}_$target_delay/reports/$prefix.routed.power.*>;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) {
	 if ( $_ =~ /Total Dynamic Power\s*=\s+(\d+\.?\d*((e|E)-?\d+)?)/ ) {    
		$routed_dynamic_power = $1;
	 }
	 if ( $_ =~ /Cell Leakage Power\s*=\s+(\d+\.?\d*((e|E)-?\d+)?)\s*(.W)/ ) {
           $routed_leakage_power = ($4 eq "uW")? $1 / 1000.0: $1;
	 }
     }
    close REPORTFILE;
  }

  @report_files = <${vt}_${vdd}_$target_delay/reports/$optimized_prefix.routed.timing.*>;
  $optimized_delay = 1000;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) { 
      if ( $_ =~ /data arrival time\s+-?(\d+\.?\d*)/ && $1 < $optimized_delay) {    
	    $optimized_delay = $1;
      }
    }
    close REPORTFILE;
  }


  $optimized_core_area="";
  @report_files = <${vt}_${vdd}_$target_delay/reports/$design_name.optimized.${vt}.$target_delay.routed.area.*>;
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
  @report_files = <${vt}_${vdd}_$target_delay/reports/$optimized_prefix.routed.power.*>;
  foreach $report_file (@report_files) {
    open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
    while(<REPORTFILE>) {
	 if ( $_ =~ /Total Dynamic Power\s*=\s+(\d+\.?\d*((e|E)-?\d+)?)/ ) {    
		$optimized_dynamic_power = $1;
	 }
	 if ( $_ =~ /Cell Leakage Power\s*=\s+(\d+\.?\d*((e|E)-?\d+)?)\s*(.W)/ ) {
           $optimized_leakage_power = ($4 eq "uW")? $1 / 1000.0: $1;
	 }
     }
    close REPORTFILE;
  }
  if ($mapped_delay != 1000)
  {
     print "$prefix, $mapped_delay, $routed_delay, $optimized_delay, $mapped_core_area, $routed_core_area, $optimized_core_area, $mapped_dynamic_power, $routed_dynamic_power, $optimized_dynamic_power, $mapped_leakage_power, $routed_leakage_power, $optimized_leakage_power\n";
  }
}
