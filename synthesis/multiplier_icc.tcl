set DESIGN_NAME Multiplier_unq1

set MW_DESIGN_LIBRARY ${DESIGN_NAME}_LIB
if { ![file exists $MW_DESIGN_LIBRARY/lib] } {
       create_mw_lib \
            -tech $TECH_FILE \
            -bus_naming_style {[%d]} \
            -mw_reference_library $mw_ref_lib_dbs \
            $MW_DESIGN_LIBRARY
}

open_mw_lib $MW_DESIGN_LIBRARY
import_designs $DESIGN_NAME.mapped.v -format verilog -top $DESIGN_NAME -cel $DESIGN_NAME
derive_pg_connection -power_net $MW_POWER_NET -power_pin $MW_POWER_PORT -ground_net $MW_GROUND_NET -ground_pin $MW_GROUND_PORT -create_port top

 

set CSA_cells [get_cells -hierarchical "*csa*"];
set max_row 0;
set max_column 0;
set max_compressed_column 0;

foreach_in_collection CSA_cell $CSA_cells {

  regexp {column_([0-9]*)/csa_([0-9]*)_([0-9]*)} [get_object_name $CSA_cell] matched CSA_column CSA_row compressed_CSA_column;

  if { $CSA_column > $max_column } {
    set max_column $CSA_column
  }

  if { $compressed_CSA_column > $max_compressed_column } {
    set max_compressed_column $compressed_CSA_column
  }

  if { $CSA_row > $max_row } {
    set max_row $CSA_row
  }
}

# flip rows and columns to keep it more square
create_rp_group rp_tree -columns [expr $max_row + 1] -rows  [expr $max_compressed_column + 1] -compress;

foreach_in_collection CSA_cell $CSA_cells {
    set CSA_name [get_object_name $CSA_cell];

    regexp {column_([0-9]*)/csa_([0-9]*)_([0-9]*)} $CSA_name matched CSA_column CSA_row compressed_CSA_column;
    
    set child_cells [get_cells "${CSA_name}/*"];
    set children_count [sizeof_collection $child_cells];
    if {$children_count>1} {
      create_rp_group rp_csa_${CSA_row}_${CSA_column} -columns $children_count -rows 1 -compress;
      set child_column 0;
      foreach_in_collection child_cell $child_cells {
        set child_name [get_object_name $child_cell];
        add_to_rp_group ${DESIGN_NAME}::rp_csa_${CSA_row}_${CSA_column} -leaf $child_name -column $child_column -row 0;
        set child_column [expr $child_column + 1]
      }
      add_to_rp_group ${DESIGN_NAME}::rp_tree -hierarchy ${DESIGN_NAME}::rp_csa_${CSA_row}_${CSA_column} \
              -column $CSA_row -row $compressed_CSA_column;
    } else {
      foreach_in_collection child_cell $child_cells {
        set child_name [get_object_name $child_cell];
        add_to_rp_group ${DESIGN_NAME}::rp_tree -leaf $child_name -column $CSA_row -row  $compressed_CSA_column;
      }    
    }
} 

initialize_floorplan \
  	-control_type aspect_ratio \
  	-core_aspect_ratio 1 \
  	-core_utilization 0.7 \
  	-row_core_ratio 1 \
  	-left_io2core 30 \
  	-bottom_io2core 30 \
  	-right_io2core 30 \
  	-top_io2core 30 \
  	-start_first_row

if {$TLUPLUS_MIN_FILE == ""} {set TLUPLUS_MIN_FILE $TLUPLUS_MAX_FILE}
set_tlu_plus_files \
     -max_tluplus $TLUPLUS_MAX_FILE \
     -min_tluplus $TLUPLUS_MIN_FILE \
     -tech2itf_map $MAP_FILE               ;# set the tlu plus files

derive_pg_connection -power_net $MW_POWER_NET -power_pin $MW_POWER_PORT -ground_net $MW_GROUND_NET -ground_pin $MW_GROUND_PORT
derive_pg_connection -power_net $MW_POWER_NET -power_pin $MW_POWER_PORT -ground_net $MW_GROUND_NET -ground_pin $MW_GROUND_PORT -tie

place_opt  -effort medium -power -area_recovery -num_cpus 2

derive_pg_connection -power_net $MW_POWER_NET -power_pin $MW_POWER_PORT -ground_net $MW_GROUND_NET -ground_pin $MW_GROUND_PORT 
derive_pg_connection -power_net $MW_POWER_NET -power_pin $MW_POWER_PORT -ground_net $MW_GROUND_NET -ground_pin $MW_GROUND_PORT -tie

route_opt -initial_route_only
route_opt -skip_initial_route -effort medium -xtalk_reduction -power

save_mw_cel -as ${DESIGN_NAME}_wih_RP
exit

