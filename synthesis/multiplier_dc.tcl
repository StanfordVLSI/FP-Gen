# the variable $ENABLE_MANUAL_PLACEMENT is used to switch on relative placement
# one example is running this from command line
# dc_shell-xg-t -f multiplier_dc.tcl -x "set ENABLE_MANUAL_PLACEMENT 1; set VT hvt; set Voltage 0v8" | tee -i multiplier_dc_optimized.log

source -echo -verbose ../header.tcl

file mkdir reports

if { [file exists ../../top.saif] } {
  saif_map -start
}

analyze -format sverilog [glob ../../*unq*.v]
elaborate $DESIGN_NAME -architecture verilog -library DEFAULT
link
check_design

if { [file exists ../../top.saif] } {
  read_saif -auto_map_names -instance top/${TOP_NAME}/${DESIGN_INSTANCE} -input ../../top.saif -verbose
  report_saif 
} else {
  set_switching_activity -toggle_rate 2 -static_probability 0.5 clk
  set_switching_activity -toggle_rate 0.5 -static_probability 0.5 [get_ports -regexp {[abc][[.[.]].*[[.].]]}]
  set_switching_activity -toggle_rate 0.01 -static_probability 0.01 {reset SI stall SCAN_ENABLE test_mode}
  set_switching_activity -toggle_rate 0.2 -static_probability 0.8 valid_in
}


set HEDGE 0.8
set PATH_RATIO 0.8 

if { $PipelineDepth > 0 } {

  set CLK clk
  set RST reset
  
  ## NOTE THAT THIS RETIMING ASSUMES THAT INPUT AND OUTPUT FLOPS ARE MARKED NO_RETIME
       
  if { $Retiming && $SmartRetiming } {
    current_design MultiplierP_unq1
    set cycle_multiplier 1;
    if { $EnableMultiplePumping == "YES" && $MulpPipelineDepth>1 } {
      set cycle_multiplier $MulpPipelineDepth;
    }
    set_max_delay [expr double($cycle_multiplier)*double($HEDGE)*double($PATH_RATIO)*double($target_delay)/1000] -from [all_inputs] -to [all_outputs]
    compile_ultra -no_autoungroup
    current_design ${DESIGN_NAME}
    #set_dont_touch [get_cells -hierarchical MUL0] true
  }  

  set CLK_PERIOD [expr double($HEDGE)*double($target_delay)/1000]
  create_clock $CLK -period $CLK_PERIOD
  set_output_delay 0.15 -clock $CLK  [get_ports "*" -filter {@port_direction == out} ]
  #set all_inputs_wo_rst_clk [remove_from_collection [remove_from_collection [all_inputs] [get_port $CLK]] [get_port $RST]]
  #set_input_delay -clock $CLK [ expr $CLK_PERIOD*1/2 ] $all_inputs_wo_rst_clk

  if { $EnableMultiplePumping == "YES" && $MulpPipelineDepth>1} {
   set MultP_Path [get_object_name [get_cells -hierarchical * -filter "@ref_name == Pipelined_MultiplierP_unq1"]];
   set_multicycle_path $MulpPipelineDepth -from [get_cells "${MultP_Path}/*" -filter {@is_sequential==true}]
  }
  if { $Retiming } { 	
    set_optimize_registers true -design ${DESIGN_NAME}
 
    # https://solvnet.synopsys.com/dow_retrieve/G-2012.03/manpages/syn2/optimize_registers.html
    #optimize_registers -no_compile -justification_effort high -check_design -verbose -print_critical_loop
    # https://solvnet.synopsys.com/dow_retrieve/G-2012.03/manpages/syn2/compile_ultra.html?otSearchResultSrc=advSearch&otSearchResultNumber=15&otPageNum=1
    compile_ultra -no_autoungroup -retime
    #report_timing -transition_time -nets -attributes -nosplit > reports/${DESIGN_NAME}.${VT}_${Voltage}.$target_delay.mapped_retime.timing.rpt
    #optimize_registers -sync_transform multiclass -async_transform multiclass
    #report_timing -transition_time -nets -attributes -nosplit > reports/${DESIGN_NAME}.${VT}_${Voltage}.$target_delay.mapped_retime_mc.timing.rpt
    #optimize_registers -sync_transform decompose -async_transform decompose
    #report_timing -transition_time -nets -attributes -nosplit > reports/${DESIGN_NAME}.${VT}_${Voltage}.$target_delay.mapped_retime_dc.timing.rpt
    report_power  > reports/${DESIGN_NAME}.${APPENDIX}_${Voltage}.$target_delay.mapped_noclockgating.power.rpt
  }
  compile_ultra -no_autoungroup -gate_clock

   #Reset Constraints for ICC
  set CLK_PERIOD [expr double($target_delay)/1000]
  create_clock $CLK -period $CLK_PERIOD
  set_output_delay 0.15 -clock $CLK  [get_ports "*" -filter {@port_direction == out} ]
  #set all_inputs_wo_rst_clk [remove_from_collection [remove_from_collection [all_inputs] [get_port $CLK]] [get_port $RST]]
  #set_input_delay -clock $CLK [ expr $CLK_PERIOD*1/2 ] $all_inputs_wo_rst_clk
 
} else {

    #DELAY ONLY EVALUATION.  

  if {$target_delay!=-1} {
    set_max_delay -from [all_inputs] -to [all_outputs] [expr double($HEDGE)*double($target_delay)/1000]
    if {$target_delay==0} {
      set target_delay min
    }  
  } else {
    set target_delay max
  }

  compile_ultra -no_autoungroup

  set_max_delay -from [all_inputs] -to [all_outputs] [expr double($target_delay)/1000]
}

link
write -format verilog -hierarchy -output $DESIGN_NAME.$VT.$target_delay.mapped.v
write -format ddc -hierarchy -output $DESIGN_NAME.$VT.$target_delay.mapped.ddc
write_sdc -nosplit $DESIGN_NAME.$VT.$target_delay.mapped.sdc

report_area  > reports/${DESIGN_NAME}.${APPENDIX}.$target_delay.mapped.area.rpt

remove_attribute [current_design] local_link_library

check_design
check_design > reports/${DESIGN_NAME}.${APPENDIX}_0v8.$target_delay.mapped.check_design.rpt


if { [file exists ../../top.saif] } {
  report_saif -hier > reports/${DESIGN_NAME}.mapped.saif.rpt
  write_saif -output ../../dc_out.saif 
}

report_timing -loops > reports/${DESIGN_NAME}.${VT}_0v8.$target_delay.mapped.timing_loops.rpt
report_timing -loops

report_power -net > reports/${DESIGN_NAME}.${VT}_0v8.$target_delay.mapped.activity_factor.rpt


set link_library [set ${VT}_0v8_target_libs]
report_timing -transition_time -nets -attributes -nosplit > reports/${DESIGN_NAME}.${VT}_0v8.$target_delay.mapped.timing.rpt
report_timing -loops > reports/${DESIGN_NAME}.${VT}_0v8.$target_delay.mapped.timing_loops.rpt
report_timing -loops
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
