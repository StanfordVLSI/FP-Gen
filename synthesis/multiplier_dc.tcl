source header.tcl

analyze -format sverilog [glob ../*.v]
elaborate $DESIGN_NAME -architecture verilog -library DEFAULT
set_max_delay -from [all_inputs] -to [all_outputs] 0
set_dont_touch [get_cells -hierarchical "add"]
set_dont_touch [get_cells -hierarchical "cell_*"]
#set_map_only $CSA_cells
compile_ultra -no_autoungroup

set CSA_cells [get_cells -hierarchical "*add"];
remove_attribute -quiet $CSA_cells dont_touch
set_size_only $CSA_cells
compile_ultra -no_autoungroup

write -format verilog -hierarchy -output $DESIGN_NAME.$VT.mapped.v
write -format ddc -hierarchy -output $DESIGN_NAME.$VT.mapped.ddc
write_sdc -nosplit $DESIGN_NAME.$VT.mapped.sdc
report_timing -transition_time -nets -attributes -nosplit > reports/${DESIGN_NAME}.${VT}_$Voltage.mapped.timing.rpt

exit
