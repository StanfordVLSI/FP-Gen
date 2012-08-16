# the variable $ENABLE_MANUAL_PLACEMENT is used to switch on relative placement
# one example is running this from command line
# dc_shell-xg-t -f multiplier_dc.tcl -x "set ENABLE_MANUAL_PLACEMENT 1; set VT hvt; set Voltage 0v8" | tee -i multiplier_dc_optimized.log

source -echo -verbose $env(FPGEN)/synthesis/header.tcl

file mkdir reports
file mkdir SAIF

if { [file exists ${DESIGN_TARGET}.saif] } {
  saif_map -start
}

analyze -format sverilog [glob ${RUNDIR}/genesis_synth/*.v]
elaborate $DESIGN_TARGET -architecture verilog -library DEFAULT
link
check_design


set HEDGE 0.8
set PATH_RATIO 0.8 

if { $PipelineDepth > 0 } {

  set CLK clk
  set RST reset
  set CLK_PERIOD [expr double($HEDGE)*double($target_delay)/1000]
  
  ## NOTE THAT THIS RETIMING ASSUMES THAT INPUT AND OUTPUT FLOPS ARE MARKED NO_RETIME
       
  if { $Retiming && $SmartRetiming } {
    current_design MultiplierP_unq1
    set cycle_multiplier 1;
    if { $EnableMultiplePumping == "YES" && $MulpPipelineDepth>1 } {
      set cycle_multiplier $MulpPipelineDepth;
    }
    set_max_delay [expr double($cycle_multiplier)*double($HEDGE)*double($PATH_RATIO)*double($target_delay)/1000] -from [all_inputs] -to [all_outputs]
    compile_ultra -no_autoungroup

#    if { $Architecture=="CMA" } {
#       current_design FarPathAdd_unq1
#       create_clock $CLK -period $CLK_PERIOD
#       compile_ultra -no_autoungroup -retime
#       optimize_registers -sync_transform decompose -print_critical_loop
#       current_design ClosePathSub_unq1
#       create_clock $CLK -period $CLK_PERIOD
#       compile_ultra -no_autoungroup -retime
#       optimize_registers -sync_transform decompose -print_critical_loop
#    }


    current_design ${DESIGN_TARGET}
    #set_dont_touch [get_cells -hierarchical MUL0] true
  }  

  
  create_clock $CLK -period $CLK_PERIOD
  set_DESIGN_switching_activity "avg"
  if { [file exists ${DESIGN_TARGET}.saif] } {
    set_DESIGN_switching_activity "avg" ${DESIGN_TARGET}.saif
    report_saif -hier -rtl_saif -missing
  }

  set_output_delay 0.15 -clock $CLK  [get_ports "*" -filter {@port_direction == out} ]
  #set all_inputs_wo_rst_clk [remove_from_collection [remove_from_collection [all_inputs] [get_port $CLK]] [get_port $RST]]
  #set_input_delay -clock $CLK [ expr $CLK_PERIOD*1/2 ] $all_inputs_wo_rst_clk

  if { $EnableMultiplePumping == "YES" && $MulpPipelineDepth>1} {
   set MultP_Path [get_object_name [get_cells -hierarchical * -filter "@ref_name == Pipelined_MultiplierP_unq1"]];
   set_multicycle_path $MulpPipelineDepth -from [get_cells "${MultP_Path}/*" -filter {@is_sequential==true}]
  }
  set_optimize_registers true -design ${DESIGN_TARGET}
  set COMPILE_COMMAND "compile_ultra -no_autoungroup"

  if { $Retiming } {
    lappend COMPILE_COMMAND "-retime"
  }
  if { $EnableClockGating } {
    lappend COMPILE_COMMAND "-gate_clock"
  }
  echo $COMPILE_COMMAND 
  eval $COMPILE_COMMAND

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

change_names -rule verilog -hierarchy
write -format verilog -hierarchy -output SAIF/$DC_NETLIST
write -format ddc -hierarchy -output $DESIGN_TARGET.${VT}_${Voltage}.$target_delay.mapped.ddc
write_sdc -nosplit $DESIGN_TARGET.${VT}_${Voltage}.$target_delay.mapped.sdc

if { [file exists ${DESIGN_TARGET}.saif] } {
  report_saif -hier > reports/${DESIGN_TARGET}.mapped.saif.rpt
}

report_area  > reports/${DESIGN_TARGET}.${VT}_${Voltage}.$target_delay.mapped.area.rpt

check_design > reports/${DESIGN_TARGET}.${VT}_${Voltage}.$target_delay.mapped.check_design.rpt

report_timing -loops > reports/${DESIGN_TARGET}.${VT}_${Voltage}.$target_delay.mapped.timing_loops.rpt

remove_attribute [current_design] local_link_library

set link_library $link_library_0v8
report_timing -transition_time -nets -attributes -nosplit > reports/${DESIGN_TARGET}.${VT}_0v8.$target_delay.mapped.timing.rpt
report_timing -loops
report_qor > reports/${DESIGN_TARGET}.${APPENDIX}_0v8.$target_delay.mapped.qor.rpt

set link_library $link_library_0v9
report_timing -transition_time -nets -attributes -nosplit > reports/${DESIGN_TARGET}.${VT}_0v9.$target_delay.mapped.timing.rpt
report_qor  > reports/${DESIGN_TARGET}.${APPENDIX}_0v9.$target_delay.mapped.qor.rpt

set link_library $link_library_1v0
report_timing -transition_time -nets -attributes -nosplit > reports/${DESIGN_TARGET}.${VT}_1v0.$target_delay.mapped.timing.rpt
report_qor  > reports/${DESIGN_TARGET}.${APPENDIX}_1v0.$target_delay.mapped.qor.rpt

exit
