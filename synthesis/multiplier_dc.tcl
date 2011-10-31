# the variable $ENABLE_MANUAL_PLACEMENT is used to switch on relative placement
# one example is running this from command line
# dc_shell-xg-t -f multiplier_dc.tcl -x "set ENABLE_MANUAL_PLACEMENT 1; set VT hvt; set Voltage 0v8" | tee -i multiplier_dc_optimized.log

source header.tcl

analyze -format sverilog [glob ../*.v]
elaborate $DESIGN_NAME -architecture verilog -library DEFAULT

if {$target_delay!=-1} {
  set_max_delay -from [all_inputs] -to [all_outputs] [expr double($target_delay)/1000]
  if {$target_delay==0} {
    set target_delay min
  }  
} else {
  set target_delay max
}

compile_ultra -no_autoungroup

write -format verilog -hierarchy -output $DESIGN_NAME.$VT.$target_delay.mapped.v
write -format ddc -hierarchy -output $DESIGN_NAME.$VT.$target_delay.mapped.ddc
write_sdc -nosplit $DESIGN_NAME.$VT.$target_delay.mapped.sdc
report_timing -transition_time -nets -attributes -nosplit > reports/${DESIGN_NAME}.${VT}_$Voltage.$target_delay.mapped.timing.rpt
report_area  > reports/${DESIGN_NAME}.${APPENDIX}_$Voltage.$target_delay.mapped.area.rpt
report_power  > reports/${DESIGN_NAME}.${APPENDIX}_$Voltage.$target_delay.mapped.power.rpt

exit
