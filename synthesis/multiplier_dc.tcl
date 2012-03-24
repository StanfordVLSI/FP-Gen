# the variable $ENABLE_MANUAL_PLACEMENT is used to switch on relative placement
# one example is running this from command line
# dc_shell-xg-t -f multiplier_dc.tcl -x "set ENABLE_MANUAL_PLACEMENT 1; set VT hvt; set Voltage 0v8" | tee -i multiplier_dc_optimized.log

source -echo ../header.tcl

analyze -format sverilog [glob ../../*.v]
elaborate $DESIGN_NAME -architecture verilog -library DEFAULT
check_design



if { $PIPELINE_STAGES_COUNT > 0 } {

  if { $PIPELINE_STAGES_COUNT > 1 } {
    set MUL_Block [get_cells -hierarchical MUL0];
set_max_delay [expr ($CLOCK_PERIOD - $CLOCK_SETUP_TIME - $CLOCK_TO_Q_DELAY)] \ 
   -from [get_pins -filter {@pin_direction == in} -of_objects $MUL_Block] \
   -to [get_pins -filter {@pin_direction == out} -of_objects $MUL_Block];
  }

  set PRE_RETIMING_CLOCK_PERIOD [expr ($CLOCK_PERIOD - $CLOCK_SETUP_TIME - $CLOCK_TO_Q_DELAY) * $PIPELINE_STAGES_COUNT];

  
  create_clock clk -period  $PRE_RETIMING_CLOCK_PERIOD
  set_switching_activity -toggle_rate 2 -clock clk -static_probability 0.5 clk
  set_switching_activity -toggle_rate 0.5 -clock clk -static_probability 0.5 [get_ports -regexp {[abc][[.[.]].*[[.].]] }]
  set_switching_activity -toggle_rate 0.01 -clock clk -static_probability 0.01 {reset SI SCAN_ENABLE test_mode}
  set_switching_activity -toggle_rate 0.2 -clock clk -static_probability 0.2 stall_pipeline


  set_input_delay $CLOCK_TO_Q_DELAY -clock clk [remove_from_collection [all_inputs] clk]
  set_output_delay $CLOCK_SETUP_TIME -clock clk [all_outputs]

  compile_ultra -no_autoungroup
  
  if { $PIPELINE_STAGES_COUNT > 1 } {
    remove_constraint -all
    create_clock clk -period $CLOCK_PERIOD
    set_input_delay $CLOCK_TO_Q_DELAY -clock clk [remove_from_collection [all_inputs] clk]
    set_output_delay $CLOCK_SETUP_TIME -clock clk [all_outputs]
    set ports_clock_root [get_ports [all_fanout -flat -clock_tree -level 0]] 
    group_path -name REGOUT -to [all_outputs] 
    group_path -name REGIN -from [remove_from_collection [all_inputs] $ports_clock_root] 
    group_path -name FEEDTHROUGH -from [remove_from_collection [all_inputs] $ports_clock_root] -to [all_outputs]
    optimize_registers -no_compile
    insert_clock_gating
    propagate_constraints -gate_clock
    compile_ultra -no_autoungroup -retime
  }

} else {

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
}

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
