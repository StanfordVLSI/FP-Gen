# the variable $ENABLE_MANUAL_PLACEMENT is used to switch on relative placement
# one example is running this from command line
# icc_shell -f multiplier_icc.tcl -x "set ENABLE_MANUAL_PLACEMENT 1;" | tee -i multiplier_icc_optimized.log

source ../header.tcl

if {$target_delay==0} {
  set target_delay min
}
  
if {$target_delay==-1} {
  set target_delay max
}

if {[info exists ENABLE_MANUAL_PLACEMENT]} {
  set MW_DESIGN_LIBRARY ${DESIGN_NAME}_${VT}_${target_delay}_optimized_LIB
} else {
  set MW_DESIGN_LIBRARY ${DESIGN_NAME}_${VT}_${target_delay}_LIB
}

if { ![file exists $MW_DESIGN_LIBRARY/lib] } {
       create_mw_lib \
            -tech $TECH_FILE \
            -bus_naming_style {[%d]} \
            -mw_reference_library $mw_ref_lib_dbs \
            $MW_DESIGN_LIBRARY
}



open_mw_lib $MW_DESIGN_LIBRARY
import_designs $DESIGN_NAME.$VT.$target_delay.mapped.v -format verilog -top $DESIGN_NAME -cel $DESIGN_NAME
read_sdc $DESIGN_NAME.$VT.$target_delay.mapped.sdc

derive_pg_connection -power_net $MW_POWER_NET -power_pin $MW_POWER_PORT -ground_net $MW_GROUND_NET -ground_pin $MW_GROUND_PORT -create_port top

save_mw_cel -as ${DESIGN_NAME}_before_floorplanning

set CSA_cells [get_cells -hierarchical "*csa*"];
set max_row 0;
set max_column 0;
set max_compressed_column 0;
set min_compressed_column 100000;

foreach_in_collection CSA_cell $CSA_cells {

  regexp {column_([0-9]*)/csa_([0-9]*)_([0-9]*)} [get_object_name $CSA_cell] matched CSA_column row_index compressed_CSA_column;

  if { $CSA_column > $max_column } {
    set max_column $CSA_column
  }

  if { $compressed_CSA_column > $max_compressed_column } {
    set max_compressed_column $compressed_CSA_column
  }

  if { $compressed_CSA_column < $min_compressed_column } {
    set min_compressed_column $compressed_CSA_column
  }

  if { $row_index > $max_row } {
    set max_row $row_index
  }
}

#get_ports -regexp {[ab][[.[.]].*[[.].]]
#set_mpc_port_options -side t -order t pin_order




if {[info exists ENABLE_MANUAL_PLACEMENT]} {
  # First: pin placement
  set a_ports [get_ports {a[*]}] 
  foreach_in_collection a_port $a_ports {
    regexp {a\[([0-9]*)\]} [get_object_name $a_port] matched port_number
    set_pin_physical_constraints -side 1 $a_port -order [expr $port_number+1]
  }

  set b_ports [get_ports {b[*]}] 
  foreach_in_collection b_port $b_ports {
    regexp {b\[([0-9]*)\]} [get_object_name $b_port] matched port_number
    set_pin_physical_constraints -side 2 $b_port -order [expr $port_number+1]
  }

  set max_out_port 0;
  set out0_ports [get_ports {out0[*]}]
  foreach_in_collection out0_port $out0_ports {
    regexp {out0\[([0-9]*)\]} [get_object_name $out0_port] matched port_number
    if { $port_number > $max_out_port } {
      set max_out_port $port_number
    }
  }

  for { set port_number 0 } { $port_number < [expr int($max_out_port/2)] } { incr port_number } {
    set_pin_physical_constraints -pin_name out0[$port_number] -side 4 -order [expr ($port_number*2)+2]
    set_pin_physical_constraints -pin_name out1[$port_number] -side 4 -order [expr ($port_number*2)+3] 
  }
  for { set port_number [expr int($max_out_port/2)] } { $port_number < $max_out_port} { incr port_number } {
    set_pin_physical_constraints -pin_name out0[$port_number] -side 3 -order [expr ($port_number*2)+2] 
    set_pin_physical_constraints -pin_name out1[$port_number] -side 3 -order [expr ($port_number*2)+3] 
  }


  # flip rows and columns to keep it more square
  suppress_message [list SEL-004 PSYN-1002]
  create_rp_group rp_tree -columns [expr $max_row + 2] -rows  [expr 2*($max_compressed_column - $min_compressed_column + 1)] -allow_non_rp_cells -x_offset 0 -y_offset 0 -placement_type compression;


  foreach_in_collection CSA_cell $CSA_cells {

    set CSA_name [get_object_name $CSA_cell];

    regexp {column_([0-9]*)/csa_([0-9]*)_([0-9]*)} $CSA_name matched CSA_column row_index compressed_CSA_column;
    set column_index [expr $compressed_CSA_column-$min_compressed_column]
    set is_odd_row [expr $row_index%2];
 
    # Second: CSA cells 
    set CSA_child_cells [get_cells "${CSA_name}/*"];
    #set_dont_touch $CSA_child_cells;
    set CSA_children_count [sizeof_collection $CSA_child_cells];
    if {$CSA_children_count>1} {
      create_rp_group rp_CSA_${row_index}_${column_index} -columns $CSA_children_count -rows 1;
      #echo "created rp group rp_CSA_${row_index}_${column_index}";
      set CSA_child_column 0;
      foreach_in_collection CSA_child_cell $CSA_child_cells {
        set CSA_child_name [get_object_name $CSA_child_cell];
        add_to_rp_group ${DESIGN_NAME}::rp_CSA_${row_index}_${column_index} \
                           -leaf $CSA_child_name -column $CSA_child_column -row 0;
        #echo "added leaf  $CSA_child_name to rp group rp_CSA_${row_index}_${column_index}";
        set CSA_child_column [expr $CSA_child_column + 1]
      }
      add_to_rp_group ${DESIGN_NAME}::rp_tree \
                    -hierarchy ${DESIGN_NAME}::rp_CSA_${row_index}_${column_index} \
                    -column $row_index -row [expr 2*$column_index+$is_odd_row];
      #echo "added group  rp_CSA_${row_index}_${column_index}  to rp group rp_tree";
    } else {
      foreach_in_collection CSA_child_cell $CSA_child_cells {
        set CSA_child_name [get_object_name $CSA_child_cell];
        add_to_rp_group ${DESIGN_NAME}::rp_tree \
                    -leaf $CSA_child_name -column $row_index -row [expr 2*$column_index+$is_odd_row];
            #echo "added leaf  $CSA_child_name to rp group rp_tree";
      }
    } 

    # Second: Booth cells
    set booth_cells [get_cells -hierarchical -regexp  "Booth2Enc_u${row_index}.cell_${column_index}"];
    #set_dont_touch $booth_cells ;
    set booth_count [sizeof_collection $booth_cells];
    foreach_in_collection booth_cell $booth_cells {
      set booth_name [get_object_name $booth_cell];
      set booth_child_cells [get_cells "${booth_name}/*"];
      set booth_children_count [sizeof_collection $booth_child_cells];
      if {$booth_children_count>0} {
         create_rp_group rp_booth_${row_index}_${column_index} -columns [expr $booth_children_count+1] -rows 1;
         #echo "created rp group rp_booth_${row_index}_${column_index}";
         set booth_child_column 0;
         foreach_in_collection booth_child_cell $booth_child_cells {
           set booth_child_name [get_object_name $booth_child_cell];
           add_to_rp_group ${DESIGN_NAME}::rp_booth_${row_index}_${column_index} \
                           -leaf $booth_child_name -column $booth_child_column -row 0;
           #echo "added leaf  $booth_child_name to rp group rp_booth_${row_index}_${column_index}";
           set booth_child_column [expr $booth_child_column + 1]
         }
         add_to_rp_group ${DESIGN_NAME}::rp_booth_${row_index}_${column_index} \
                    -keepout gap_${row_index}_${column_index} -type space -column $booth_children_count -row 0 -width 4 -height 1;
         add_to_rp_group ${DESIGN_NAME}::rp_tree \
                    -hierarchy ${DESIGN_NAME}::rp_booth_${row_index}_${column_index} \
                    -column $row_index -row [expr 2*$column_index+1-$is_odd_row];
         #echo "added group  rp_booth_${row_index}_${column_index}  to rp group rp_tree";
      }    
    }
  }

#  set_rp_group_options [all_rp_groups] \
#           -psynopt_option size_only \
#           -route_opt_option in_place_size_only \
#           -cts_option fixed_placement \
#          -placement_type compression \
#           -disable_buffering \
#           -allow_non_rp_cells;
}




initialize_floorplan \
  	-control_type row_number \
  	-number_rows [expr 2*$max_compressed_column+4] \
  	-core_utilization 0.7 \
  	-row_core_ratio 1 \
  	-left_io2core 30 \
  	-bottom_io2core 30 \
  	-right_io2core 30 \
  	-top_io2core 30 \
  	-start_first_row



save_mw_cel -as ${DESIGN_NAME}_before_placement



if {$TLUPLUS_MIN_FILE == ""} {set TLUPLUS_MIN_FILE $TLUPLUS_MAX_FILE}
set_tlu_plus_files \
     -max_tluplus $TLUPLUS_MAX_FILE \
     -min_tluplus $TLUPLUS_MIN_FILE \
     -tech2itf_map $MAP_FILE               ;# set the tlu plus files

derive_pg_connection -power_net $MW_POWER_NET -power_pin $MW_POWER_PORT -ground_net $MW_GROUND_NET -ground_pin $MW_GROUND_PORT
derive_pg_connection -power_net $MW_POWER_NET -power_pin $MW_POWER_PORT -ground_net $MW_GROUND_NET -ground_pin $MW_GROUND_PORT -tie


place_opt  -effort medium -power -area_recovery -num_cpus 2

estimate_fp_area -sizing_type fixed_height

save_mw_cel -as ${DESIGN_NAME}_before_routing

derive_pg_connection -power_net $MW_POWER_NET -power_pin $MW_POWER_PORT -ground_net $MW_GROUND_NET -ground_pin $MW_GROUND_PORT 
derive_pg_connection -power_net $MW_POWER_NET -power_pin $MW_POWER_PORT -ground_net $MW_GROUND_NET -ground_pin $MW_GROUND_PORT -tie


route_opt -initial_route_only
route_opt -skip_initial_route -effort medium -power

save_mw_cel -as ${DESIGN_NAME}_final

file mkdir reports

report_area  -physical -hierarchy > reports/${DESIGN_NAME}.${APPENDIX}.$target_delay.routed.area.rpt

remove_attribute [current_design] local_link_library



set link_library [set wc_0v8_lib_dbs]
report_timing -transition_time -nets -attributes -nosplit > reports/${DESIGN_NAME}.${APPENDIX}_0v8.$target_delay.routed.timing.rpt
report_power  > reports/${DESIGN_NAME}.${APPENDIX}_0v8.$target_delay.routed.power.rpt

set link_library [set wc_0v9_lib_dbs]
report_timing -transition_time -nets -attributes -nosplit > reports/${DESIGN_NAME}.${APPENDIX}_0v9.$target_delay.routed.timing.rpt
report_power  > reports/${DESIGN_NAME}.${APPENDIX}_0v9.$target_delay.routed.power.rpt

set link_library [set wc_1v0_lib_dbs]
report_timing -transition_time -nets -attributes -nosplit > reports/${DESIGN_NAME}.${APPENDIX}_1v0.$target_delay.routed.timing.rpt
report_power  > reports/${DESIGN_NAME}.${APPENDIX}_1v0.$target_delay.routed.power.rpt


exit

