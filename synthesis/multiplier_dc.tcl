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
elaborate $DESIGN_TARGET
link
check_design

if { [shell_is_in_topographical_mode] } {
    # Enable power prediction for this DC-T session using clock tree estimation.
    set_power_prediction true
    if { ${MIN_ROUTING_LAYER} != ""} {
      set_ignored_layers -min_routing_layer ${MIN_ROUTING_LAYER}
    }
    if { ${MAX_ROUTING_LAYER} != ""} {
      set_ignored_layers -max_routing_layer ${MAX_ROUTING_LAYER}
    }

    report_ignored_layers
        
    #SAMEH
    set_preferred_routing_direction -layers {M1 M3 M5 M7 M9} -direction horizontal
    set_preferred_routing_direction -layers {M2 M4 M6 M8 AP} -direction vertical

    set HEDGE 1
} else {
    set HEDGE 0.8
}  
set PATH_RATIO 0.8

set COMPILE_COMMAND "compile_ultra -no_autoungroup"

if { $PipelineDepth > 0 } {

  if { $Retiming } {
    lappend COMPILE_COMMAND "-retime"
  }

  if { $EnableClockGating } {
    lappend COMPILE_COMMAND "-gate_clock"
  }

  set CLK clk
  set RST reset
  set CLK_PERIOD [expr double($HEDGE)*double($target_delay)/1000];
  create_clock $CLK -period $CLK_PERIOD
  set_output_delay 0.15 -clock $CLK  [get_ports "*" -filter {@port_direction == out} ]

  if { $EnableMultiplePumping == "YES" && $MulpPipelineDepth>1} {
   set MultP_instances [get_cells -hierarchical * -filter {@ref_name == MultiplierP_unq1}];
   foreach_in_collection MultP_instance $MultP_instances {
     current_instance $MultP_instance;
     set_multicycle_path $MulpPipelineDepth -from [get_cells -hierarchical * -filter {@is_sequential==true && @is_hierarchical == false}];
   }
   report_timing_requirements;
  }

  set_DESIGN_switching_activity "avg"
  if { [file exists ${DESIGN_TARGET}.saif] } {
    set_DESIGN_switching_activity "avg" ${DESIGN_TARGET}.saif
    report_saif -hier -rtl_saif -missing
  }

  ## NOTE THAT THIS RETIMING ASSUMES THAT INPUT AND OUTPUT FLOPS ARE MARKED NO_RETIME       
  if { $Retiming && $SmartRetiming && $Architecture!="DW_FMA"} {
    current_design MultiplierTree_unq1
    set_max_delay -from [all_inputs] -to [all_outputs] [expr $PATH_RATIO*$CLK_PERIOD]
    compile_ultra -no_autoungroup
    if { $Architecture=="CMA" } {
      set MUL_DESIGN "Multiplier_unq1";
    } else {
      set MUL_DESIGN "Pipelined_MultiplierP_unq1";
    }
    current_design $MUL_DESIGN
    create_clock $CLK -period $CLK_PERIOD
    set_output_delay 0.04 -clock $CLK  [get_ports "*" -filter {@port_direction == out} ];
    set_optimize_registers true -design $MUL_DESIGN
    eval $COMPILE_COMMAND
    remove_constraint -all
    current_design ${DESIGN_TARGET}
    create_clock $CLK -period $CLK_PERIOD
    set_output_delay 0.15 -clock $CLK  [get_ports "*" -filter {@port_direction == out} ]
    if { $EnableMultiplePumping == "YES" && $MulpPipelineDepth>1} {
      set MultP_Path [get_object_name [get_cells -hierarchical * -filter "@ref_name == Pipelined_MultiplierP_unq1"]];
      set_multicycle_path $MulpPipelineDepth -from [get_cells "${MultP_Path}/*" -filter {@is_sequential==true}]
    }
  }

  set_optimize_registers true -design ${DESIGN_TARGET}
  echo $COMPILE_COMMAND
  if {[shell_is_in_topographical_mode]} {
    eval "$COMPILE_COMMAND -check_only"
  } 
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

  eval $COMPILE_COMMAND

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

if {[shell_is_in_topographical_mode]} {
  report_area -physical > reports/${DESIGN_TARGET}.${VT}_${Voltage}.$target_delay.mapped.area.rpt
  report_area  -physical -hierarchy > reports/${DESIGN_TARGET}.${VT}_${Voltage}.$target_delay.mapped.area.hier.rpt
} else {
  report_area  > reports/${DESIGN_TARGET}.${VT}_${Voltage}.$target_delay.mapped.area.rpt
  report_area  -hierarchy > reports/${DESIGN_TARGET}.${VT}_${Voltage}.$target_delay.mapped.area.hier.rpt
}

check_design > reports/${DESIGN_TARGET}.${VT}_${Voltage}.$target_delay.mapped.check_design.rpt

report_timing -loops > reports/${DESIGN_TARGET}.${VT}_${Voltage}.$target_delay.mapped.timing_loops.rpt

remove_attribute [current_design] local_link_library

set link_library $link_library_0v8
report_timing -significant_digits 4 -transition_time -nets -attributes -nosplit > reports/${DESIGN_TARGET}.${VT}_0v8.$target_delay.mapped.timing.rpt
report_timing -loops
report_qor > reports/${DESIGN_TARGET}.${APPENDIX}_0v8.$target_delay.mapped.qor.rpt

set link_library $link_library_0v9
report_timing -significant_digits 4 -transition_time -nets -attributes -nosplit > reports/${DESIGN_TARGET}.${VT}_0v9.$target_delay.mapped.timing.rpt
report_qor  > reports/${DESIGN_TARGET}.${APPENDIX}_0v9.$target_delay.mapped.qor.rpt

set link_library $link_library_1v0
report_timing -significant_digits 4 -transition_time -nets -attributes -nosplit > reports/${DESIGN_TARGET}.${VT}_1v0.$target_delay.mapped.timing.rpt
report_qor  > reports/${DESIGN_TARGET}.${APPENDIX}_1v0.$target_delay.mapped.qor.rpt

if {[shell_is_in_topographical_mode]} {
  # write_milkyway uses: mw_logic1_net, mw_logic0_net and mw_design_library variables from dc_setup.tcl
  write_milkyway -overwrite -output ${DESIGN_TARGET}_DCT
}

exit
