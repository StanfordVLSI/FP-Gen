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

if { $PipelineDepth > 0 } {
  report_DESIGN_power "routed" "add";
  report_DESIGN_power "routed" "mul";
  report_DESIGN_power "routed" "muladd";  
}

report_DESIGN_power "routed" "avg"

exit
