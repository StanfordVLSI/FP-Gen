set DESIGN_NAME Multiplier_unq1

analyze -format sverilog [glob ../*.v]
elaborate $DESIGN_NAME -architecture verilog -library DEFAULT

set_max_delay -from [all_inputs] -to [all_outputs] 1

compile_ultra -no_autoungroup

write -format verilog -hierarchy -output $DESIGN_NAME.mapped.v
write_sdc -nosplit $DESIGN_NAME.mapped.sdc

exit
