# the variable $ENABLE_MANUAL_PLACEMENT is used to switch on relative placement
# one example is running this from command line
# dc_shell-xg-t -f multiplier_dc.tcl -x "set ENABLE_MANUAL_PLACEMENT 1; set VT hvt; set Voltage 0v8" | tee -i multiplier_dc_optimized.log

source -echo ../header.tcl

analyze -format sverilog [glob ../../*.v]
elaborate $DESIGN_NAME -architecture verilog -library DEFAULT
check_design

set HEDGE 0.8
set PATH_RATIO 0.8 

if { $PipelineDepth > 0 } {

    set CLK clk
    set RST reset 

    if { $Retiming } { 
        ## NOTE THAT THIS RETIMING ASSUMES THAT INPUT AND OUTPUT FLOPS ARE MARKED NO_RETIME
       
        if { $SmartRetiming } {
           current_design MultiplierP_unq1
           set_max_delay [expr double($HEDGE)*double($PATH_RATIO)*double($target_delay)/1000] -from [all_inputs] -to [all_outputs]
           compile_ultra -no_autoungroup
	

	    current_design ${DESIGN_NAME}
            #set_dont_touch [get_cells -hierarchical MUL0] true
	}  

	set CLK_PERIOD [expr double($HEDGE)*double($target_delay)/1000]
	create_clock $CLK -period $CLK_PERIOD
	set_output_delay [ expr $CLK_PERIOD*1/2 ] -clock $CLK  [get_ports "*" -filter {@port_direction == out} ]
	set all_inputs_wo_rst_clk [remove_from_collection [remove_from_collection [all_inputs] [get_port $CLK]] [get_port $RST]]
	set_input_delay -clock $CLK [ expr $CLK_PERIOD*1/2 ] $all_inputs_wo_rst_clk
		
	set_optimize_registers true -design ${DESIGN_NAME}
 
        # https://solvnet.synopsys.com/dow_retrieve/G-2012.03/manpages/syn2/optimize_registers.html
	#optimize_registers -no_compile -justification_effort high -check_design -verbose -print_critical_loop
	# https://solvnet.synopsys.com/dow_retrieve/G-2012.03/manpages/syn2/compile_ultra.html?otSearchResultSrc=advSearch&otSearchResultNumber=15&otPageNum=1
	compile_ultra -no_autoungroup -retime
 
	#Attempt to Recover the minimum clock period.
	#balance_registers

	#Reset Constraints for ICC
	set CLK_PERIOD [expr double($target_delay)/1000]
	create_clock $CLK -period $CLK_PERIOD
	set_output_delay [ expr $CLK_PERIOD*1/2 ] -clock $CLK  [get_ports "*" -filter {@port_direction == out} ]
	set all_inputs_wo_rst_clk [remove_from_collection [remove_from_collection [all_inputs] [get_port $CLK]] [get_port $RST]]
	set_input_delay -clock $CLK [ expr $CLK_PERIOD*1/2 ] $all_inputs_wo_rst_clk

    } else {

	#NO RETIMING
        ## IGNORE set_output_delay and set_input_delay.  These constrainsts are arbitrary.
        ##   they exist to suppress warnings and errors.  These should have no impact
        ##   on the design if inputs and outpus are flopped.

	#Hedged Constraints for DC
	set CLK_PERIOD [expr double($HEDGE)*double($target_delay)/1000] 
	create_clock $CLK -period $CLK_PERIOD
	set_output_delay [ expr $CLK_PERIOD*1/2 ] -clock $CLK  [get_ports "*" -filter {@port_direction == out} ]
	set all_inputs_wo_rst_clk [remove_from_collection [remove_from_collection [all_inputs] [get_port $CLK]] [get_port $RST]]
	set_input_delay -clock $CLK [ expr $CLK_PERIOD*1/2 ] $all_inputs_wo_rst_clk
		
	compile_ultra -no_autoungroup

	#Reset Constraints for ICC
	set CLK_PERIOD [expr double($target_delay)/1000]
	create_clock $CLK -period $CLK_PERIOD
	set_output_delay [ expr $CLK_PERIOD*1/2 ] -clock $CLK  [get_ports "*" -filter {@port_direction == out} ]
	set all_inputs_wo_rst_clk [remove_from_collection [remove_from_collection [all_inputs] [get_port $CLK]] [get_port $RST]]
	set_input_delay -clock $CLK [ expr $CLK_PERIOD*1/2 ] $all_inputs_wo_rst_clk

    }
 
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

write -format verilog -hierarchy -output $DESIGN_NAME.$VT.$target_delay.mapped.v
write -format ddc -hierarchy -output $DESIGN_NAME.$VT.$target_delay.mapped.ddc
write_sdc -nosplit $DESIGN_NAME.$VT.$target_delay.mapped.sdc

file mkdir reports

report_area  > reports/${DESIGN_NAME}.${APPENDIX}.$target_delay.mapped.area.rpt

remove_attribute [current_design] local_link_library

check_design
check_design > reports/${DESIGN_NAME}.${APPENDIX}_0v8.$target_delay.mapped.check_design.rpt

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
