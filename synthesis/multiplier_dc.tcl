# the variable $ENABLE_MANUAL_PLACEMENT is used to switch on relative placement
# one example is running this from command line
# dc_shell-xg-t -f multiplier_dc.tcl -x "set ENABLE_MANUAL_PLACEMENT 1; set VT hvt; set Voltage 0v8" | tee -i multiplier_dc_optimized.log

source -echo ../header.tcl

analyze -format sverilog [glob ../../*.v]
elaborate $DESIGN_NAME -architecture verilog -library DEFAULT
check_design

if {$target_delay!=-1} {
  set_max_delay -from [all_inputs] -to [all_outputs] [expr 0.8*double($target_delay)/1000]
  if {$target_delay==0} {
    set target_delay min
  }  
} else {
  set target_delay max
}

compile_ultra -no_autoungroup

set_max_delay -from [all_inputs] -to [all_outputs] [expr double($target_delay)/1000]

write -format verilog -hierarchy -output $DESIGN_NAME.$VT.$target_delay.mapped.v
write -format ddc -hierarchy -output $DESIGN_NAME.$VT.$target_delay.mapped.ddc
write_sdc -nosplit $DESIGN_NAME.$VT.$target_delay.mapped.sdc

file mkdir reports

report_area  > reports/${DESIGN_NAME}.${APPENDIX}.$target_delay.mapped.area.rpt

remove_attribute [current_design] local_link_library

set link_library [set ${VT}_0v8_target_libs]
report_timing -transition_time -nets -attributes -nosplit > reports/${DESIGN_NAME}.${VT}_0v8.$target_delay.mapped.timing.rpt
report_power  > reports/${DESIGN_NAME}.${APPENDIX}_0v8.$target_delay.mapped.power.rpt
report_qor > reports/${DESIGN_NAME}.${APPENDIX}_0v8.$target_delay.mapped.qor.rpt

set link_library [set ${VT}_0v9_target_libs]
report_timing -transition_time -nets -attributes -nosplit > reports/${DESIGN_NAME}.${VT}_0v9.$target_delay.mapped.timing.rpt
report_power  > reports/${DESIGN_NAME}.${APPENDIX}_0v9.$target_delay.mapped.power.rpt
report_qor  > reports/${DESIGN_NAME}.${APPENDIX}_0v9.$target_delay.mapped.qor.rpt

set link_library [set ${VT}_1v0_target_libs]
report_timing -transition_time -nets -attributes -nosplit > reports/${DESIGN_NAME}.${VT}_1v0.$target_delay.mapped.timing.rpt
report_power  > reports/${DESIGN_NAME}.${APPENDIX}_1v0.$target_delay.mapped.power.rpt
report_qor  > reports/${DESIGN_NAME}.${APPENDIX}_1v0.$target_delay.mapped.qor.rpt

exit
