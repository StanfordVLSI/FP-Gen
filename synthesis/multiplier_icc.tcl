# the variable $ENABLE_MANUAL_PLACEMENT is used to switch on relative placement
# one example is running this from command line
# icc_shell -f multiplier_icc.tcl -x "set ENABLE_MANUAL_PLACEMENT 1;" | tee -i multiplier_icc_optimized.log

source ../header.tcl

proc add_cells_to_rp_group {args} {

  global DESIGN_NAME;
  set row 0;
  set column 0;
  set height 1;

  parse_proc_arguments -args $args results
  foreach argname [array names results] { 
    set [regsub {\-} $argname ""] $results($argname);
  }

  set cells_count [sizeof_collection $cells];
  if {$cells_count>1} {
    create_rp_group $cells_name -columns [expr $cells_count/$height + ($cells_count%$height?1:0)] -rows $height;
    add_to_rp_group $rp_groups -hierarchy ${DESIGN_NAME}::${cells_name} -column $column -row $row;
  }
  set cell_idx 0;
  foreach_in_collection cell $cells {
    set cell_name [get_object_name $cell];
    if {$cells_count>1} {
      add_to_rp_group ${DESIGN_NAME}::$cells_name -leaf $cell_name \
                      -column [expr $cell_idx/$height] -row [expr $cell_idx%$height];
    } else {
      add_to_rp_group $rp_groups -leaf $cell_name -column $column -row $row;
    }
    set cell_idx [expr $cell_idx + 1]
  }
}

define_proc_attributes add_cells_to_rp_group -info "Adds a group of cells to an existing relative placement group." \
  -define_args \
  {{cells "Specifies the cells to add to the relative placement groups in rp_groups." cells list required}
   {cells_name "Specifies the name of the cells to be added" cells_name string required}
   {rp_groups "Specifies the relative placement groups in which to add an item. The groups must all be in the same design." rp_groups list required}
   {-column "Specifies the column position in which to add the item. If you do not specify the column position, it defaults to zero." integer int optional} 
   {-row "Specifies the row position in which to add the item. If you do not specify the row position, it defaults to zero." integer int optional}
   {-height "number of columns to spread cells across" integer int optional}}


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

set max_csa_column_width 0.0;
set max_booth_column_width 0.0;
set total_csa_column_width 0.0;
set total_booth_column_width 0.0;
  
for { set compressed_column $min_compressed_column } { $compressed_column <= $max_compressed_column} { incr compressed_column } {
  set csa_column_cells [get_cells "Tree/column_*/csa_*_${compressed_column}/*"];
  set csa_column_width 0.0;
  foreach_in_collection csa_column_cell $csa_column_cells {
    set csa_column_width [expr $csa_column_width+[get_attribute $csa_column_cell width]];
  }
  set total_csa_column_width [expr $total_csa_column_width+$csa_column_width];
  if { $csa_column_width > $max_csa_column_width} {
    set max_csa_column_width $csa_column_width;
  }

  set booth_column_index [expr $compressed_CSA_column-$min_compressed_column];
  set booth_column_cells [get_cells "Booth/BoothEnc_u*/cell_${booth_column_index}/*"];
  set booth_column_width 0.0;
  foreach_in_collection booth_column_cell $booth_column_cells {
    set booth_column_width [expr $booth_column_width+[get_attribute $booth_column_cell width]];
  }
  set total_booth_column_width [expr $total_booth_column_width+$booth_column_width];
  if { $booth_column_width > $max_booth_column_width} {
    set max_booth_column_width $booth_column_width;
  }
}
set average_csa_column_width [expr $total_csa_column_width/($max_compressed_column-$min_compressed_column)];
set average_booth_column_width [expr $total_booth_column_width/($max_compressed_column-$min_compressed_column)];

set booth_sel_cells [get_cells -hierarchical "*Booth_sel_*"];
set booth_encoder_count 0;
set booth_sel_count -1;

foreach_in_collection booth_sel_cell $booth_sel_cells {

  regexp {BoothEnc_u([0-9]*)/Booth_sel_([0-9]*)} [get_object_name $booth_sel_cell] matched booth_sel_row booth_sel_col;

  if { $booth_sel_row >= $booth_encoder_count } {
    set booth_encoder_count [expr $booth_sel_row+1]
  }

  if { $booth_sel_col >= $booth_sel_count } {
    set booth_sel_count [expr $booth_sel_col+1]
  }
}

set max_boothSel_column_width 0.0;
set total_boothSel_column_width 0.0;
for { set $booth_sel_col 0 } { $booth_sel_col < $booth_sel_count} { incr booth_sel_col } {
  set boothSel_column_cells [get_cells "Booth/BoothEnc_u*/Booth_sel_${booth_sel_col}/*"];
  set boothSel_column_width 0.0;
  foreach_in_collection boothSel_column_cell $boothSel_column_cells {
    set boothSel_column_width [expr $boothSel_column_width+[get_attribute $boothSel_column_cell width]];
  }
  set total_boothSel_column_width [expr $total_boothSel_column_width+$boothSel_column_width];
  if { $boothSel_column_width > $max_boothSel_column_width} {
    set max_boothSel_column_width $boothSel_column_width;
  }
}
set average_boothSel_column_width [expr $total_boothSel_column_width/$booth_sel_count];

set boothSel_aspect_ratio [expr int(ceil(2*$max_boothSel_column_width/($average_csa_column_width+$average_booth_column_width)))];

echo "CSA width (max= $max_csa_column_width, avg= $average_csa_column_width )\n"\
     "Booth width (max= $max_booth_column_width, avg= $average_booth_column_width )\n"\
     "BoothSel width (max= $max_boothSel_column_width, avg= $average_boothSel_column_width )\n"\
     "BoothSel aspect ratio = $boothSel_aspect_ratio" > reports/${DESIGN_NAME}.${APPENDIX}_1v0.$target_delay.floorplanning.rpt


set row_count [expr $max_row + 2 > $booth_encoder_count? $max_row + 2 : $booth_encoder_count];
set column_count [expr $max_compressed_column - $min_compressed_column + 1 + $booth_sel_count];
set booth_select_cadence [expr $column_count/$booth_sel_count];

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
  suppress_message [list SEL-004 PSYN-1002 RPGP-090]

  
  create_rp_group rp_tree -columns $row_count -rows [expr 2*$column_count] -allow_non_rp_cells ;

  set boothSel_cells [get_cells -hierarchical "*Booth_sel_*"];


  foreach_in_collection boothSel_cell $boothSel_cells {

    set boothSel_name [get_object_name $boothSel_cell];

    regexp {BoothEnc_u([0-9]*)/Booth_sel_([0-9])} $boothSel_name matched boothEnc_index boothSel_index;
    set boothSel_row [expr 2*($column_count -1 - ($booth_sel_count-1-$boothSel_index)*$booth_select_cadence)]

    set boothSel_child_cells [get_cells "${boothSel_name}/*"];

    add_cells_to_rp_group $boothSel_child_cells rp_boothSel_${boothEnc_index}_${boothSel_index} ${DESIGN_NAME}::rp_tree \
                    -column $boothEnc_index -row $boothSel_row -height $boothSel_aspect_ratio;
  }
  

# handle the edge signal of Booth encoders

  foreach_in_collection CSA_cell $CSA_cells {

    set CSA_name [get_object_name $CSA_cell];

    regexp {column_([0-9]*)/csa_([0-9]*)_([0-9]*)} $CSA_name matched CSA_column row_index compressed_CSA_column;
    set column_offset [expr $booth_sel_count - 1 - ($max_compressed_column - $compressed_CSA_column) / ($booth_select_cadence-1)];
    set column_offset [expr $column_offset<0? 0:$column_offset];
    set column_index [expr $compressed_CSA_column-$min_compressed_column+$column_offset ]
    set is_odd_row [expr $row_index%2];
 
    # Second: CSA cells 
    set CSA_child_cells [get_cells "${CSA_name}/*"];
    add_cells_to_rp_group $CSA_child_cells rp_CSA_${row_index}_${column_index} ${DESIGN_NAME}::rp_tree \
                    -column [expr $row_index+1-$is_odd_row] -row [expr 2*$column_index+$is_odd_row];

    # Second: Booth cells
    set booth_column_index [expr $column_index - $column_offset];
    set booth_cells [get_cells "Booth/BoothEnc_u${row_index}/cell_${booth_column_index}/*"];
    add_cells_to_rp_group $booth_cells rp_booth_${row_index}_${booth_column_index} ${DESIGN_NAME}::rp_tree \
                    -column [expr $row_index-$is_odd_row] -row [expr 2*$column_index+$is_odd_row];
  }

#ADDER PLACEMENT SCRIPTS HERE:
#if {[file exists ../place_SklanskyAdderTree_H.tcl]} {
#  source -echo ../place_SklanskyAdderTree_H.tcl
#  check_rp_groups -verbose ${DESIGN_NAME}::SklanskyAdderTree_H
#}

#if {[file exists ../place_SklanskyAdderTree_K.tcl]} {
#  source -echo ../place_SklanskyAdderTree_K.tcl
#  check_rp_groups -verbose ${DESIGN_NAME}::SklanskyAdderTree_K
#}

if {[file exists ../../place_PartialProductSum.tcl]} {
  source -echo ../../place_PartialProductSum.tcl
  check_rp_groups -verbose ${DESIGN_NAME}::PartialProductSum
  check_rp_groups -verbose ${DESIGN_NAME}::PartialProductSum_2
}

check_rp_groups -all -verbose
create_rp_group RP_MULT -columns 2 -rows 2 -allow_non_rp_cells
add_to_rp_group ${DESIGN_NAME}::RP_MULT   -hierarchy ${DESIGN_NAME}::rp_tree            -column 0 -row 1 ;
add_to_rp_group ${DESIGN_NAME}::RP_MULT   -hierarchy ${DESIGN_NAME}::PartialProductSum  -column 0 -row 0 ;
add_to_rp_group ${DESIGN_NAME}::RP_MULT   -hierarchy ${DESIGN_NAME}::PartialProductSum_2  -column 1 -row 1 ;
check_rp_groups -verbose ${DESIGN_NAME}::RP_MULT



  set_rp_group_options [all_rp_groups] \
           -allow_non_rp_cells \
           -placement_type compression;
#          -disable_buffering \
#          -psynopt_option size_only \
#          -route_opt_option in_place_size_only \
#          -cts_option fixed_placement;

check_rp_groups -all -verbose


}

  save_mw_cel -as ${DESIGN_NAME}_before_floorplanning

if {$max_compressed_column > 0} {
  initialize_floorplan \
  	-control_type row_number \
  	-number_rows [expr 2*$column_count+($boothSel_aspect_ratio-1)*$booth_sel_count] \
  	-core_utilization 0.6 \
  	-row_core_ratio 1 \
  	-left_io2core $io2core \
  	-bottom_io2core $io2core \
  	-right_io2core $io2core \
  	-top_io2core $io2core \
  	-start_first_row      
} else {
  initialize_floorplan \
  	-control_type aspect_ratio \
  	-core_aspect_ratio 1 \
  	-core_utilization 0.6 \
  	-row_core_ratio 1 \
  	-left_io2core $io2core \
  	-bottom_io2core $io2core \
  	-right_io2core $io2core \
  	-top_io2core $io2core \
  	-start_first_row
}





save_mw_cel -as ${DESIGN_NAME}_before_placement



if {$TLUPLUS_MIN_FILE == ""} {set TLUPLUS_MIN_FILE $TLUPLUS_MAX_FILE}
set_tlu_plus_files \
     -max_tluplus $TLUPLUS_MAX_FILE \
     -min_tluplus $TLUPLUS_MIN_FILE \
     -tech2itf_map $MAP_FILE               ;# set the tlu plus files

derive_pg_connection -power_net $MW_POWER_NET -power_pin $MW_POWER_PORT -ground_net $MW_GROUND_NET -ground_pin $MW_GROUND_PORT
derive_pg_connection -power_net $MW_POWER_NET -power_pin $MW_POWER_PORT -ground_net $MW_GROUND_NET -ground_pin $MW_GROUND_PORT -tie


place_opt  -effort high -power -area_recovery -num_cpus 2

save_mw_cel -as ${DESIGN_NAME}_before_rp_blowout

remove_rp_groups -all
place_opt -skip_initial_placement -effort high -power -area_recovery -num_cpus 2

if {$max_compressed_column > 0} {
  estimate_fp_area -sizing_type fixed_height
} else {
  estimate_fp_area -sizing_type fixed_aspect_ratio
}

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

