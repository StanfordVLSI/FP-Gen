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
$globalConfig{STAT}{PlaceRoute} = $synStatus2 ;

my $synStatus3 = 1 ;
-e $globalConfig{INFO}{ICC_OPT_LOG} or $synStatus3 = 0 ;
`grep Error $globalConfig{INFO}{ICC_OPT_LOG} | grep :` and $synStatus3 = 0 ;
`grep Fatal $globalConfig{INFO}{ICC_OPT_LOG} | grep :` and $synStatus3 = 0 ;
$globalConfig{STAT}{OptPlaceRoute} = $synStatus3 ;


#get a sorted list of all report files
my @files = <synthesis/*/reports/*.mapped.timing.rpt>;
my %r  ;
my $ri = -1 ;


#SUB EXTRACT POWER REPORT
#--------------------------------------------------------------------------------
#                                       Switch   Int      Leak     Total
#Hierarchy                              Power    Power    Power    Power    %
#--------------------------------------------------------------------------------
#FPGen                                     1.585    3.281 4.09e+05    5.275 100.0
#CLOCK_TREE_EST                         5.72e-02 5.14e-02 2.58e+03    0.111   2.1
#  FMA_inc_pipe_clk_gate_stages_reg_0_ (SNPS_CLOCK_GATE_HIGH_FF_pipeline_unq8)
#                                       2.57e-02 4.76e-03  216.207 3.07e-02   0.6
#  FMA_fma_pipe_clk_gate_valid_stages_reg (SNPS_CLOCK_GATE_HIGH_FF_pipeline_unq7_6)
#                                       5.98e-03 4.73e-03  216.093 1.09e-02   0.2

sub extractPowerReport{
    my $report_file = shift  or return ( -1 , -1 );
    my $design_name = shift  or return ( -1 , -1 );

    my $dynamic_power_mW = -1 ;
    my $leakage_power_mW = -1 ;
    open (REPORTFILE,"<$report_file") or return ( $dynamic_power_mW  , $leakage_power_mW ) ;
    while( my $line = <REPORTFILE> ) {
	
	#print $line . "\n" ;
	if( $line =~ /$design_name/ ){
	    if( $line =~ /\s(\d+.\S+)\s+(\d+.\S+)\s+(\d+.\S+)\s+(\d+.\S+)/ ) {
		#print "$1 $2 $3 $4\n" ;  #Switch Power , Internal Power , Leak Power , Total Power 
		$dynamic_power_mW = $1 * 1.0 + $2 * 1.0 ;
		$leakage_power_mW = $3 * 1.0 / 1000000.0 ;
	    }
	}
	
    }

    close( REPORTFILE );

    return ( $dynamic_power_mW  , $leakage_power_mW ) ;

}



#                                  Global cell area          Local cell area
#                                  ------------------  ---------------------------- 
#Hierarchical cell                 Absolute   Percent  Combi-     Noncombi-  Black
#                                  Total      Total    national   national   boxes   Design
#--------------------------------  ---------  -------  ---------  ---------  ------  ----------------------------------------
#FPGen                             4705.9993    100.0    46.9224   222.6168  0.0000  FPGen
#FMA_Incrementer                     88.2000      1.9    67.3848    20.8152  0.0000  FPIncrementer_unq1
#FMA_MulShift                      1772.2908     37.7   502.5636   419.8320  0.0000  FMA_MulShift_unq1
#FMA_MulShift/MUL0                  829.7856     17.6     4.5864    10.5840  0.0000  Pipelined_MultiplierP_unq1
#FMA_MulShift/MUL0/MultP            804.5604     17.1     0.0000     0.0000  0.0000  MultiplierP_unq1
#FMA_MulShift/MUL0/MultP/Booth      523.5552     11.1    14.6412   279.4176  0.0000  Booth_unq1

sub extractAreaReport{
    my $report_file = shift  or return ( -1 );
    my $design_name = shift  or return ( -1 );

    my $area_sqmm = -1 ;
    open (REPORTFILE,"<$report_file") or return ( -1  ) ;
    while( my $line = <REPORTFILE> ) {
	
	#print $line . "\n" ;
	if( $line =~ /$design_name/ ){
	    if( $line =~ /(\d+.\S+)\s+(\d+.\S+)\s+(\d+.\S+)\s+(\d+.\S+)\s+(\d+.\S+)/ ) {
		#print "$1 $2 $3 $4\n" ;  #Abs Area , Foo , Comb Area , Non Comb Area  , Black Boxes
		$area_sqmm = $1 * 1.0/1000000.0 ;
	    }
	}
	
    }

    close( REPORTFILE );

    return ( $area_sqmm ) ;

}




sub extracQorReport{
    my $report_file = shift or return ( -1 , -1 , -1 , -1 , -1 , -1 , -1 , -1  );
    
    my $core_area_mmsq    = "-1";
    my $cell_area_mmsq    = "-1";
    my $net_area_mmsq     = "-1";
    my $noncomb_area_mmsq = "-1";
    my $comb_area_mmsq    = "-1";
    my $comb_cell_cnt     = "-1";
    my $seq_cell_cnt      = "-1";
    my $compile_time_sec  = "-1"; 
    
    open (REPORTFILE,"<$report_file") || return  ( $comb_area_mmsq , $noncomb_area_mmsq , $net_area_mmsq , $cell_area_mmsq , $core_area_mmsq ,  $comb_cell_cnt , $seq_cell_cnt , $compile_time_sec ) ;
    while( my $line=<REPORTFILE>) {
	if ( $line =~ /Design Area:\s+(\d+\.?\d*)/ ) {
	    $core_area_mmsq = $1 / 1000000.0;
	}
	if ( $line =~ /Cell Area:\s+(\d+\.?\d*)/ ) {
	    $cell_area_mmsq = $1 / 1000000.0;
	}
	if ( $line =~ /Net Area:\s+(\d+\.?\d*)/ ) {
	    $net_area_mmsq = $1 / 1000000.0;
	}
	if ( $line =~ /Noncombinational Area:\s+(\d+\.?\d*)/ ) {
	    $noncomb_area_mmsq = $1 / 1000000.0;
	}
	if ( $line =~ /Combinational Area:\s+(\d+\.?\d*)/ ) {
	    $comb_area_mmsq = $1 / 1000000.0;
	}
	if ( $line =~ /Combinational Cell Count:\s+(\d+)/ ) {
	    $comb_cell_cnt = $1;
	}
	if ( $line =~ /Sequential Cell Count:\s+(\d+)/ ) {
	    $seq_cell_cnt = $1;
	}
	if ( $line =~ /Overall Compile Wall Clock Time:\s+(\d+.\d+)/ ){
	    $compile_time_sec = $1; 
	}
	
    }
    close REPORTFILE;
    
    return ( $comb_area_mmsq , $noncomb_area_mmsq , $net_area_mmsq , $cell_area_mmsq , $core_area_mmsq ,  $comb_cell_cnt , $seq_cell_cnt , $compile_time_sec )

}

sub extracTimingReport{
    my $report_file = shift or return ( -1 , -1 , -1 );
    
    my $target_clk_period_nS = -1 ;
    my $clk_period_nS = -1 ;
    my $lib_setup_time_nS = -1 ; 
    my $worst_slack_nS = -1 ;
    my $data_arrival_time_nS = -1 ;
    my $clk_freq_Ghz = -1 ;

    open( REPORTFILE , "<$report_file" ) or return  ($target_clk_period_nS , $clk_period_nS , -1 ) ;
    while(my $line=<REPORTFILE>) { 
	if ( $line =~ /library setup time\s+-?(\d+\.?\d*)/ ) {    
	    $lib_setup_time_nS = $1 ;
	}
	if ( $line =~ /data arrival time\s+-?(\d+\.?\d*)/ ) {    
	    $data_arrival_time_nS = $1 ;
	}
	if ( $line =~ /slack\s+\S+\s+((-|\+)?\d+\.?\d*)/ ) {    
	    $worst_slack_nS = $1; print "Slack $worst_slack_nS \n" ;
	}
	if ( $line =~ /clock clk \(rise edge\)\s+-?(\d+\.?\d*)/ ) {    
	    $target_clk_period_nS = $1 ; print "Clock $target_clk_period_nS\n" ; print "Target Clock $globalConfig{TOP}{Target_Delay} \n" ;
	}
    }
    close( REPORTFILE );

    if( ($worst_slack_nS != -1 ) and ( $target_clk_period_nS != -1 ) ){
	$clk_period_nS = $globalConfig{TOP}{Target_Delay}/1000.0 - $worst_slack_nS / ( $target_clk_period_nS / ($globalConfig{TOP}{Target_Delay}/1000.0)  ) ;
    }
    
    # extract clk period for non-pipeline design (no clk signal)
    if( ( $target_clk_period_nS == -1 ) and ($data_arrival_time_nS != -1 ) ) {
	$clk_period_nS = $data_arrival_time_nS;
    } 
    if(  $clk_period_nS != -1  ){
	$clk_freq_Ghz = 1.0 / $clk_period_nS ;
    }
    

    return ( $globalConfig{TOP}{Target_Delay}/1000.0 , $clk_period_nS , $clk_freq_Ghz ) ;
}




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


    #Collect Power Reports
    my @report_files ;

    my @event_names  = qw( muladd add mul avg );
    my @event_Labels = qw( MulAdd Add Mul Avg  );
    my @units        = ( $options{d} , "Pipelined_MultiplierP" , "LZA" , "CompoundAdder") ;
    my @unit_Labels  = ( ""       , "_u_Pipelined_MultiplierP_" , "_u_LZA_" , "_u_CompoundAdder_") ;
    my @pref         = ( "$prefix.mapped" , "$prefix.routed" , "$optimized_prefix.routed" ) ;  
    my @pref_Labels  = ( "Mapped"         , "Routed"         , "Optimized" ) ;  

    for( my $unt = 0 ; $unt <= $#units ; $unt++ ){ 
	for( my $pr = 0 ; $pr <= $#pref ; $pr++ ){
	    for( my $evt = 0 ; $evt <= $#event_names ; $evt++ ){ 
		my $eN = $event_names[$evt]; #print "$eN\n" ;
		my $eL = $event_Labels[$evt]; #print "$eL\n" ;
		my $uN = $units[$unt] ; #print "$uN\n" ;
		my $uL = $unit_Labels[$unt] ; #print "$uL\n" ;
		my $pN = $pref[$pr] ; #print "$pN\n" ;
		my $pL = $pref_Labels[$pr] ;  #print "$pL\n" ;
		
		@report_files = <synthesis/$folder_name/reports/$pN.$eN\_power.*>;
		scalar( @report_files ) or warn "Missing $pL $eL $uL power\n" ;
		
		print $pL."_".$uL.$eL."_Dyn_Power_mW\n" ;
		print $pL."_".$uL.$eL."_Leak_Power_mW\n" ; 

		( $r{result}[$rj]{COST}{ $pL."_".$uL.$eL."_Dyn_Power_mW" } , 
		  $r{result}[$rj]{COST}{ $pL."_".$uL.$eL."_Leak_Power_mW" } )  =
		( $r{result}[$ri]{COST}{ $pL."_".$uL.$eL."_Dyn_Power_mW" } , 
		  $r{result}[$ri]{COST}{ $pL."_".$uL.$eL."_Leak_Power_mW" }     ) = extractPowerReport( $report_files[0] , $uN ) ;



		if( $pL eq "Optimized" ){
		    ( $r{result}[$ri]{COST}{ $uL.$eL."_Dyn_Power_mW" } , 
		      $r{result}[$ri]{COST}{ $uL.$eL."_Leak_Power_mW" } )  =
		    ( $r{result}[$ri]{COST}{ $pL."_".$uL.$eL."_Dyn_Power_mW" } , 
		      $r{result}[$ri]{COST}{ $pL."_".$uL.$eL."_Leak_Power_mW" }     ) ;
		} elsif( ($pL eq "Routed") and !defined($r{result}[$rj]{COST}{ $uL.$eL."_Dyn_Power_mW" }) ){
		    ( $r{result}[$rj]{COST}{ $uL.$eL."_Dyn_Power_mW" } , 
		      $r{result}[$rj]{COST}{ $uL.$eL."_Leak_Power_mW" } )  =
		    ( $r{result}[$rj]{COST}{ $pL."_".$uL.$eL."_Dyn_Power_mW" } , 
		      $r{result}[$rj]{COST}{ $pL."_".$uL.$eL."_Leak_Power_mW" }     ) ;
		}
	    } #End For Each Event 
	} # End foreach prefix 
    } # End foreach Unit
   

    $r{result}[$rj]{COST}{Dyn_Power_mW} = $r{result}[$rj]{COST}{MulAdd_Dyn_Power_mW} ;
    $r{result}[$ri]{COST}{Dyn_Power_mW} = $r{result}[$ri]{COST}{MulAdd_Dyn_Power_mW} ;

    #Collect QOR Reports
    @report_files = <synthesis/$folder_name/reports/$prefix.mapped.qor.*>;
    scalar( @report_files ) or warn "Missing mapped qor\n" ;
    ( $r{result}[$ri]{COST}{Mapped_Comb_Area_mmsq} , $r{result}[$ri]{COST}{Mapped_NonComb_Area_mmsq} , $r{result}[$ri]{COST}{Mapped_Net_Area_mmsq} , 
      $r{result}[$ri]{COST}{Mapped_Cell_Area_mmsq} , $r{result}[$ri]{COST}{Mapped_Core_Area_mmsq}    , $r{result}[$ri]{INFO}{Mapped_Comb_Cell_Cnt}  , 
      $r{result}[$ri]{INFO}{Mapped_Seq_Cell_Cnt}   , $r{result}[$ri]{INFO}{Mapped_Compile_Time_Sec}  ) =  extracQorReport( $report_files[0] );
    ( $r{result}[$rj]{COST}{Mapped_Comb_Area_mmsq} , $r{result}[$rj]{COST}{Mapped_NonComb_Area_mmsq} , $r{result}[$rj]{COST}{Mapped_Net_Area_mmsq} , 
      $r{result}[$rj]{COST}{Mapped_Cell_Area_mmsq} , $r{result}[$rj]{COST}{Mapped_Core_Area_mmsq}    , $r{result}[$rj]{INFO}{Mapped_Comb_Cell_Cnt}  , 
      $r{result}[$rj]{INFO}{Mapped_Seq_Cell_Cnt}   , $r{result}[$rj]{INFO}{Mapped_Compile_Time_Sec}  ) =  extracQorReport( $report_files[0] );

    @report_files = <synthesis/$folder_name/reports/$prefix.routed.qor.*>;
    scalar( @report_files ) or warn "Missing optimized qor\n" ;
    ( $r{result}[$ri]{COST}{Routed_Comb_Area_mmsq} , $r{result}[$ri]{COST}{Routed_NonComb_Area_mmsq} , $r{result}[$ri]{COST}{Routed_Net_Area_mmsq} , 
      $r{result}[$ri]{COST}{Routed_Cell_Area_mmsq} , $r{result}[$ri]{COST}{Routed_Core_Area_mmsq}    , $r{result}[$ri]{INFO}{Routed_Comb_Cell_Cnt}  , 
      $r{result}[$ri]{INFO}{Routed_Seq_Cell_Cnt}   , $r{result}[$ri]{INFO}{Routed_Compile_Time_Sec}  ) =  extracQorReport( $report_files[0] );
    ( $r{result}[$rj]{COST}{Routed_Comb_Area_mmsq} , $r{result}[$rj]{COST}{Routed_NonComb_Area_mmsq} , $r{result}[$rj]{COST}{Routed_Net_Area_mmsq} , 
      $r{result}[$rj]{COST}{Routed_Cell_Area_mmsq} , $r{result}[$rj]{COST}{Routed_Core_Area_mmsq}    , $r{result}[$rj]{INFO}{Routed_Comb_Cell_Cnt}  , 
      $r{result}[$rj]{INFO}{Routed_Seq_Cell_Cnt}   , $r{result}[$rj]{INFO}{Routed_Compile_Time_Sec}  ) =  extracQorReport( $report_files[0] );
    ( $r{result}[$rj]{COST}{Comb_Area_mmsq} , $r{result}[$rj]{COST}{NonComb_Area_mmsq} , $r{result}[$rj]{COST}{Net_Area_mmsq} , 
      $r{result}[$rj]{COST}{Cell_Area_mmsq} , $r{result}[$rj]{COST}{Core_Area_mmsq}    , $r{result}[$rj]{INFO}{Comb_Cell_Cnt}  , 
      $r{result}[$rj]{INFO}{Seq_Cell_Cnt}   , $r{result}[$rj]{INFO}{Compile_Time_Sec}  ) =  extracQorReport( $report_files[0] );

    @report_files = <synthesis/$folder_name/reports/$optimized_prefix.routed.qor.*>;
    scalar( @report_files ) or warn "Missing optimized qor\n" ;
    ( $r{result}[$ri]{COST}{Optimized_Comb_Area_mmsq} , $r{result}[$ri]{COST}{Optimized_NonComb_Area_mmsq} , $r{result}[$ri]{COST}{Optimized_Net_Area_mmsq} , 
      $r{result}[$ri]{COST}{Optimized_Cell_Area_mmsq} , $r{result}[$ri]{COST}{Optimized_Core_Area_mmsq}    , $r{result}[$ri]{INFO}{Optimized_Comb_Cell_Cnt}  , 
      $r{result}[$ri]{INFO}{Optimized_Seq_Cell_Cnt}   , $r{result}[$ri]{INFO}{Optimized_Compile_Time_Sec}  ) =  extracQorReport( $report_files[0] );
    ( $r{result}[$rj]{COST}{Optimized_Comb_Area_mmsq} , $r{result}[$rj]{COST}{Optimized_NonComb_Area_mmsq} , $r{result}[$rj]{COST}{Optimized_Net_Area_mmsq} , 
      $r{result}[$rj]{COST}{Optimized_Cell_Area_mmsq} , $r{result}[$rj]{COST}{Optimized_Core_Area_mmsq}    , $r{result}[$rj]{INFO}{Optimized_Comb_Cell_Cnt}  , 
      $r{result}[$rj]{INFO}{Optimized_Seq_Cell_Cnt}   , $r{result}[$rj]{INFO}{Optimized_Compile_Time_Sec}  ) =  extracQorReport( $report_files[0] );
    ( $r{result}[$ri]{COST}{Comb_Area_mmsq} , $r{result}[$ri]{COST}{NonComb_Area_mmsq} , $r{result}[$ri]{COST}{Net_Area_mmsq} , 
      $r{result}[$ri]{COST}{Cell_Area_mmsq} , $r{result}[$ri]{COST}{Core_Area_mmsq}    , $r{result}[$ri]{INFO}{Comb_Cell_Cnt}  , 
      $r{result}[$ri]{INFO}{Seq_Cell_Cnt}   , $r{result}[$ri]{INFO}{Compile_Time_Sec}  ) =  extracQorReport( $report_files[0] );

    #TODO Extract Additional Statistics from Area Report
    ## Utilization
    ## Aspect Ratio

    # Extract Timing Information
    @report_files = <synthesis/$folder_name/reports/$prefix.mapped.timing.*>;
    scalar( @report_files ) or warn "Missing mapped timing\n" ;
    ( $r{result}[$ri]{INFO}{Mapped_Target_Clk_Period_nS} , $r{result}[$ri]{COST}{Mapped_Clk_Period_nS} , $r{result}[$ri]{PERF}{Mapped_Clk_Freq_Ghz} ) = extracTimingReport( $report_files[0] ) ;
    ( $r{result}[$rj]{INFO}{Mapped_Target_Clk_Period_nS} , $r{result}[$rj]{COST}{Mapped_Clk_Period_nS} , $r{result}[$rj]{PERF}{Mapped_Clk_Freq_Ghz} ) = extracTimingReport( $report_files[0] ) ;
                          
    @report_files = <synthesis/$folder_name/reports/$prefix.routed.timing.*>;
    scalar( @report_files ) or warn "Missing routed timing\n" ;
    ( $r{result}[$ri]{INFO}{Routed_Target_Clk_Period_nS} , $r{result}[$ri]{COST}{Routed_Clk_Period_nS} , $r{result}[$ri]{PERF}{Routed_Clk_Freq_Ghz} ) = extracTimingReport( $report_files[0] ) ;
    ( $r{result}[$rj]{INFO}{Routed_Target_Clk_Period_nS} , $r{result}[$rj]{COST}{Routed_Clk_Period_nS} , $r{result}[$rj]{PERF}{Routed_Clk_Freq_Ghz} ) = extracTimingReport( $report_files[0] ) ;
    ( $r{result}[$rj]{INFO}{Target_Clk_Period_nS}        , $r{result}[$rj]{COST}{Clk_Period_nS}        , $r{result}[$rj]{PERF}{Clk_Freq_Ghz}        ) = extracTimingReport( $report_files[0] ) ;

    @report_files = <synthesis/$folder_name/reports/$optimized_prefix.routed.timing.*>;
    scalar( @report_files ) or warn "Missing optimized timing\n" ;
    ( $r{result}[$ri]{INFO}{Optimized_Target_Clk_Period_nS} , $r{result}[$ri]{COST}{Optimized_Clk_Period_nS} , $r{result}[$ri]{PERF}{Optimized_Clk_Freq_Ghz}) = extracTimingReport( $report_files[0] ) ;
    ( $r{result}[$rj]{INFO}{Optimized_Target_Clk_Period_nS} , $r{result}[$rj]{COST}{Optimized_Clk_Period_nS} , $r{result}[$rj]{PERF}{Optimized_Clk_Freq_Ghz}) = extracTimingReport( $report_files[0] ) ;
    ( $r{result}[$ri]{INFO}{Target_Clk_Period_nS}           , $r{result}[$ri]{COST}{Clk_Period_nS}           , $r{result}[$ri]{PERF}{Clk_Freq_Ghz}          ) = extracTimingReport( $report_files[0] ) ;


    # Calculate Energy
    @pref_Labels  = qw( Mapped Routed Optimized ) ;  
    @event_Labels = qw( MulAdd Add Mul Avg );
    @unit_Labels  = ( ""       , "_u_Pipelined_MultiplierP_" , "_u_LZA_" , "_u_CompoundAdder_") ;

    for( my $unt = 0 ; $unt <= $#unit_Labels ; $unt++ ){ 
	for( my $pr = 0 ; $pr <= $#pref_Labels ; $pr++ ){
	    for( my $evt = 0 ; $evt <= $#event_Labels ; $evt++ ){ 
		foreach my $ii ( $ri , $rj ){
		    my $eL = $event_Labels[$evt]; #print "$eL\n" ;
		    my $uL = $unit_Labels[$unt] ; #print "$uL\n" ;
		    my $pL = $pref_Labels[$pr] ;  #print "$pL\n" ;
		    
		    my $power_name = $pL."_".$uL.$eL."_Dyn_Power_mW" ;
		    my $leak_name  = $pL."_".$uL.$eL."_Leak_Power_mW" ;
		    my $delay_name = $pL."_Target_Clk_Period_nS" ;
		    
		    my $d_eng_name = $pL."_".$uL.$eL."_Dyn_Energy_pJ" ;
		    
		    $r{result}[$ii]{COST}{$power_name} or die "Doesn't Exist.... $power_name" ;
		    $r{result}[$ii]{COST}{$leak_name} or die "Doesn't Exist.... $leak_name" ;
		    $r{result}[$ii]{INFO}{$delay_name} or die "Doesn't Exist.... $delay_name" ;

		    if( $r{result}[$ii]{COST}{$power_name} < 0 or $r{result}[$ii]{INFO}{$delay_name} < 0 or $r{result}[$ii]{COST}{$leak_name} < 0 ){
			$r{result}[$ii]{COST}{$d_eng_name} = -1 ;
		    } else {
			$r{result}[$ii]{COST}{$d_eng_name} = $r{result}[$ii]{COST}{$power_name} * $r{result}[$ii]{INFO}{$delay_name} ; 
		    }
		}
	    }
	}
    }

    @pref =  ( "$design_name.${vt}_*.$target_delay.mapped" , "$design_name.${vt}_*.$target_delay.routed" , "$design_name.optimized.${vt}_*.$target_delay" );  

    for( my $unt = 0 ; $unt <= $#unit_Labels ; $unt++ ){ 
	for( my $pr = 0 ; $pr <= $#pref ; $pr++ ){
	    my $uN = $units[$unt] ; #print "$uN\n" ;
	    my $uL = $unit_Labels[$unt] ; #print "$uL\n" ;
	    my $pN = $pref[$pr] ; #print "$pN\n" ;
	    my $pL = $pref_Labels[$pr] ;  #print "$pL\n" ;
	    
	    @report_files = <synthesis/$folder_name/reports/$pN.area.hier.*>;
	    scalar( @report_files ) or warn "Missing area report $uL $pL\n" ;
	    $r{result}[$ri]{COST}{ $pL."_".$uL."_Area_mmsq"} = extractAreaReport( $report_files[0] , $uN ) ;
	    $r{result}[$rj]{COST}{ $pL."_".$uL."_Area_mmsq"} = extractAreaReport( $report_files[0] , $uN ) ;
	    if( $pL eq "Optimized" ){
		$r{result}[$ri]{COST}{ "_".$uL."_Area_mmsq"} = extractAreaReport( $report_files[0] , $uN ) ;
	    } elsif( $pL eq "Routed" ) {
		$r{result}[$rj]{COST}{ "_".$uL."_Area_mmsq"} = extractAreaReport( $report_files[0] , $uN ) ;
	    }
	}
    }

#    my $routed_core_area="-1";
#    @report_files = <synthesis/$folder_name/reports/$design_name.${vt}.$target_delay.routed.area.*>;
#    scalar( @report_files ) or warn "Missing routed area\n" ;
#    foreach $report_file (@report_files) {
#	open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
#	while(<REPORTFILE>) {
#	    if ( $_ =~ /Core Area:\s+(\d+\.?\d*)/ ) {
#		$routed_core_area = $1;
#		$routed_core_area = $routed_core_area / 1000000.0;
#	    }
#	}
#	close REPORTFILE;
#    }
    

#    my $optimized_core_area="-1";
#    @report_files = <synthesis/$folder_name/reports/$design_name.optimized.${vt}.$target_delay.routed.area.*>;
#    scalar( @report_files ) or warn "Missing optimized area\n" ;
#    foreach $report_file (@report_files) {
#	open (REPORTFILE,"<$report_file") || die "Can't open $report_file $!";
#	while(<REPORTFILE>) {
#	    if ( $_ =~ /Core Area:\s+(\d+\.?\d*)/ ) {
#		$optimized_core_area = $1;
#		$optimized_core_area = $optimized_core_area / 1000000.0;     
#	    }
#	}
#	close REPORTFILE;
#    }
    


#    my $mapped_dynamic_energy    ;
#    my $routed_dynamic_energy    ;
#    my $optimized_dynamic_energy ;

#    if( $options{p} ){
#     $mapped_dynamic_energy    = $mapped_dynamic_power    * ($Target_Delay/1000.0) ; #pJ
#     $routed_dynamic_energy    = $routed_dynamic_power    * ($Target_Delay/1000.0) ; #pJ
#     $optimized_dynamic_energy = $optimized_dynamic_power * ($Target_Delay/1000.0) ; #pJ
#    } else {
#     $mapped_dynamic_energy    = $mapped_dynamic_power ;
#     $routed_dynamic_energy    = $routed_dynamic_power  ;
#     $optimized_dynamic_energy = $optimized_dynamic_power  ;
#    }

#    my $mapped_throughput = 1.0 / $mapped_delay ;  #Result in ops per nS
#    my $routed_throughput = 1.0 / $routed_delay ;  #Result in ops per nS
#    my $optimized_throughput = 1.0 / $optimized_delay ; #Result in ops per nS

#    my $mapped_throughput_Density = 1.0 / ( $mapped_delay * $mapped_core_area );  #Result in ops per nS per sqmm
#    my $routed_throughput_Density = 1.0 / ( $routed_delay * $routed_core_area );  #Result in ops per nS per sqmm
#    my $optimized_throughput_Density = 1.0 / ( $optimized_delay * $optimized_core_area );  #Result in ops per nS per sqmm

#    my $mapped_energy_per_op = $mapped_dynamic_energy + $optimized_leakage_power * ($Target_Delay/1000.0); #pJ/op
#    my $routed_energy_per_op = $routed_dynamic_energy + $optimized_leakage_power * ($Target_Delay/1000.0); #pJ/op
#    my $optimized_energy_per_op = $optimized_dynamic_energy + $optimized_leakage_power * ($Target_Delay/1000.0); #pJ/op

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
   $r{result}[$ri]{STAT}{PlaceRoute} = $synStatus2 ;
   $r{result}[$ri]{STAT}{OptPlaceRoute} = $synStatus3 ;
   $r{result}[$ri]{STAT}{Timing_Good} = $synStatus ; 
   $r{result}[$ri]{INFO}{DC_LOG} = $globalConfig{INFO}{DC_LOG};
   $r{result}[$ri]{INFO}{ICC_LOG} = $globalConfig{INFO}{ICC_LOG};
   $r{result}[$ri]{INFO}{ICC_OPT_LOG} = $globalConfig{INFO}{ICC_OPT_LOG};

    #NON-RP RESULT
   $r{result}[$rj]{INFO}{VT} = $VT ;
   $r{result}[$rj]{INFO}{TARGET_VOLTAGE} = $Target_Voltage ;
   $r{result}[$rj]{INFO}{TARGET_DELAY} =  $Target_Delay/1000.0 ;
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
   $r{result}[$ri]{STAT}{PlaceRoute} = $synStatus2 ;
   $r{result}[$ri]{STAT}{OptPlaceRoute} = $synStatus3 ;
   $r{result}[$rj]{STAT}{Timing_Good} = $synStatus ;
   $r{result}[$rj]{INFO}{DC_LOG} = $globalConfig{INFO}{DC_LOG};
   $r{result}[$rj]{INFO}{ICC_LOG} = $globalConfig{INFO}{ICC_LOG};
   $r{result}[$rj]{INFO}{ICC_OPT_LOG} = $globalConfig{INFO}{ICC_OPT_LOG};


}


## CLEAN OUT -1 Fields 

if( $r{result} ){
    my $iiL = scalar( @{ $r{result} } ) ;
    for( my $ii = 0 ; $ii < $iiL ; $ii+=1 ){
	foreach my $jj ( keys %{$r{result}[$ii]} ){
	    foreach my $kk ( keys %{$r{result}[$ii]{$jj}} ){
		if( $r{result}[$ii]{$jj}{$kk} eq '-1' ){
		   # print "DELETED\n" ;
		    delete $r{result}[$ii]{$jj}{$kk} ;
		}
	    }
	}
    }
}


open( TARGET , ">$options{t}" ) ;

print( TARGET  Dump(\%r) );
print Dump( \%r ) ;
close( TARGET ) ;

print "Pushed result to $options{t}\n" ;
