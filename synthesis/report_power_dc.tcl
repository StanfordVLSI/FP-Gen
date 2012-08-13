# the variable $ENABLE_MANUAL_PLACEMENT is used to switch on relative placement
# one example is running this from command line
# dc_shell-xg-t -f multiplier_dc.tcl -x "set ENABLE_MANUAL_PLACEMENT 1; set VT hvt; set Voltage 0v8" | tee -i multiplier_dc_optimized.log

source -echo -verbose $env(FPGEN)/synthesis/header.tcl

file mkdir reports
file mkdir SAIF

saif_map -start

read_file -format ddc $DESIGN_TARGET.${VT}_${Voltage}.$target_delay.mapped.ddc
link

if { $PipelineDepth > 0 } {
  report_DESIGN_power "mapped" "add";
  report_DESIGN_power "mapped" "mul";
  report_DESIGN_power "mapped" "muladd";  
}

report_DESIGN_power "mapped" "avg"

set target_library [set ${VT}_[string tolower $Voltage]_target_libs]
set link_library [set link_library_[string tolower $Voltage] ]

write -format ddc -hierarchy -output $DESIGN_TARGET.${VT}_${Voltage}.$target_delay.mapped.ddc
write_sdc -nosplit $DESIGN_TARGET.${VT}_${Voltage}.$target_delay.mapped.sdc

exit
