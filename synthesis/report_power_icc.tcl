# the variable $ENABLE_MANUAL_PLACEMENT is used to switch on relative placement
# one example is running this from command line
# dc_shell-xg-t -f multiplier_dc.tcl -x "set ENABLE_MANUAL_PLACEMENT 1; set VT hvt; set Voltage 0v8" | tee -i multiplier_dc_optimized.log

source -echo -verbose $env(FPGEN)/synthesis/header.tcl

saif_map -start

if {[info exists ENABLE_MANUAL_PLACEMENT]} {
  set MW_DESIGN_LIBRARY ${DESIGN_TARGET}_${VT}_${target_delay}_optimized_LIB
} else {
  set MW_DESIGN_LIBRARY ${DESIGN_TARGET}_${VT}_${target_delay}_LIB
}

open_mw_lib $MW_DESIGN_LIBRARY
open_mw_cel ${DESIGN_TARGET}_final

set saif_type [expr $USE_ICC_GATE_SAIF?"icc":"dc"]
set use_saif [expr $USE_ICC_GATE_SAIF | $USE_GATE_SAIF]

if { [get_ports clk] != [] } {
    if { $PipelineDepth > 0 } {
	report_DESIGN_power $saif_type "routed" "add" $use_saif;
	report_DESIGN_power $saif_type "routed" "mul" $use_saif;
	report_DESIGN_power $saif_type "routed" "muladd" $use_saif;  
    }    
    report_DESIGN_power $saif_type "routed" "avg" $use_saif
} else {
    set link_library $link_library_0v8
    report_power  > reports/${DESIGN_TARGET}.${APPENDIX}_0v8.$target_delay.routed.avg_power.rpt
    set link_library $link_library_0v9
    report_power  > reports/${DESIGN_TARGET}.${APPENDIX}_0v9.$target_delay.routed.avg_power.rpt
    set link_library $link_library_1v0
    report_power  > reports/${DESIGN_TARGET}.${APPENDIX}_1v0.$target_delay.routed.avg_power.rpt
}



exit
