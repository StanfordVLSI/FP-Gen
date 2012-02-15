# the variable $ENABLE_MANUAL_PLACEMENT is used to switch on relative placement
# one example is running this from command line
# icc_shell -f multiplier_icc.tcl -x "set ENABLE_MANUAL_PLACEMENT 1;" | tee -i multiplier_icc_optimized.log

source ../header.tcl

proc add_cells_to_rp_group {args} {

  global DESIGN_NAME;
  set row 0;
  set column 0;
  set height 1;
  set space_width 0;

  parse_proc_arguments -args $args results
  foreach argname [array names results] { 
    set [regsub {\-} $argname ""] $results($argname);
  }

  set cells_count [sizeof_collection $cells];
  if {$space_width>0} {
    set cells_count [expr $cells_count + 1 ];
  }

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

  if {$space_width>0} {
    if {$cells_count>1} {
      add_to_rp_group ${DESIGN_NAME}::$cells_name -keepout SPACE -type space -width $space_width -height 1 \
                    -column [expr ($cells_count-1)/$height] -row [expr ($cells_count-1) % $height];
    } else {
      add_to_rp_group $rp_groups -keepout SPACE_${row}_${column} -type space -width $space_width -height 1 -column $column -row $row;
    }
  }
}

define_proc_attributes add_cells_to_rp_group -info "Adds a group of cells to an existing relative placement group." \
  -define_args \
  {{cells "Specifies the cells to add to the relative placement groups in rp_groups." cells list required}
   {cells_name "Specifies the name of the cells to be added" cells_name string required}
   {rp_groups "Specifies the relative placement groups in which to add an item. The groups must all be in the same design." rp_groups list required}
   {-column "Specifies the column position in which to add the item. If you do not specify the column position, it defaults to zero." integer int optional} 
   {-row "Specifies the row position in which to add the item. If you do not specify the row position, it defaults to zero." integer int optional}
   {-height "number of columns to spread cells across" integer int optional}
   {-space_width "width of space to be added at the end" integer int optional}}


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

    regexp {column_([0-9]*)/csa([0-9]*)_([0-9]*)_([0-9]*)} [get_object_name $CSA_cell] matched CSA_level CSA_column row_index compressed_CSA_column;

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
set max_column_width 0.0;
set total_csa_column_width 0.0;
set total_booth_column_width 0.0;
set core_utilization_ratio 0.5;


  
for { set compressed_column $min_compressed_column } { $compressed_column <= $max_compressed_column} { incr compressed_column } {
  set csa_column_cells [get_cells "Tree/column_*/csa*_*_${compressed_column}/*"];
  set csa_odd_column_width 0.0;
  set csa_even_column_width 0.0;
  foreach_in_collection csa_column_cell $csa_column_cells {
    regexp {csa.*_([0-9]*)_.*} [get_object_name $csa_column_cell] matched row_index;
    if { [expr $row_index%2] } {
      set csa_odd_column_width  [expr $csa_odd_column_width+[get_attribute $csa_column_cell width]];
    } else {
      set csa_even_column_width [expr $csa_even_column_width+[get_attribute $csa_column_cell width]];
    }
  }
  set csa_column_width [expr $csa_odd_column_width+$csa_even_column_width];
  set total_csa_column_width [expr $total_csa_column_width+$csa_column_width];
  if { $csa_column_width > $max_csa_column_width} {
    set max_csa_column_width $csa_column_width;
  }

  set booth_column_index [expr $compressed_column-$min_compressed_column];
  set booth_column_cells [get_cells "Booth/BoothEnc_u*/cell_${booth_column_index}/*"];
  set booth_odd_column_width  0.0;
  set booth_even_column_width 0.0;
  foreach_in_collection booth_column_cell $booth_column_cells {
    regexp {BoothEnc_u([0-9]*)} [get_object_name $booth_column_cell] matched row_index;
    if { [expr $row_index%2] } {
      set booth_odd_column_width  [expr $booth_odd_column_width+[get_attribute $booth_column_cell width]];
    } else {
      set booth_even_column_width [expr $booth_even_column_width+[get_attribute $booth_column_cell width]];
    }
  }
  set booth_column_width [expr $booth_odd_column_width+$booth_even_column_width];
  set total_booth_column_width [expr $total_booth_column_width+$booth_column_width];
  if { $booth_column_width > $max_booth_column_width} {
    set max_booth_column_width $booth_column_width;
  }

  set column_odd_width(${compressed_column})  [expr $csa_odd_column_width  + $booth_odd_column_width ];
  if { $column_odd_width($compressed_column) > $max_column_width} {
    set max_column_width $column_odd_width($compressed_column);
  }

  set column_even_width(${compressed_column}) [expr $csa_even_column_width + $booth_even_column_width];
  if { $column_even_width($compressed_column) > $max_column_width} {
    set max_column_width $column_even_width($compressed_column);
  }
}
set average_csa_column_width [expr $total_csa_column_width/($max_compressed_column-$min_compressed_column+1)];
set average_booth_column_width [expr $total_booth_column_width/($max_compressed_column-$min_compressed_column+1)];
set average_column_width [expr ($average_csa_column_width + $average_booth_column_width)/2]

#set USE_3_2_FLOORPLAN [expr $max_booth_column_width<0.7*$max_csa_column_width?1:0]; 
set USE_3_2_FLOORPLAN 0;

set booth_sel_cells [get_cells -hierarchical "*Booth_sel_*"];
set booth_cells [get_cells -hierarchical "BoothEnc_u*cell_*"];
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
for { set booth_sel_col 0 } { $booth_sel_col < $booth_sel_count} { incr booth_sel_col } {
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

set row_count [expr $max_row + 2 > $booth_encoder_count? $max_row + 2 : $booth_encoder_count];
set column_count [expr $max_compressed_column - $min_compressed_column + 2 + $booth_sel_count];
set booth_select_cadence [expr $column_count/$booth_sel_count];

if { $USE_3_2_FLOORPLAN } {
  set boothSel_aspect_ratio [expr int(ceil($max_boothSel_column_width/(2*$max_booth_column_width)))];
  set rp_column_count  [expr int(ceil(1.5*$column_count))] ;
} else {
  set boothSel_aspect_ratio [expr int(ceil($max_boothSel_column_width/$max_column_width))];
  set rp_column_count  [expr 2*$column_count] ;
}


set fp [open reports/${DESIGN_NAME}.${APPENDIX}_1v0.$target_delay.floorplanning.rpt w];

foreach {column width} [array get column_odd_width] {
   puts $fp "Odd_Width[$column] = $width";
}
foreach {column width} [array get column_even_width] {
   puts $fp "Even_Width[$column] = $width";
}

puts $fp "\nCSA width (max= $max_csa_column_width, avg= $average_csa_column_width )";
puts $fp "Booth width (max= $max_booth_column_width, avg= $average_booth_column_width )";
puts $fp "Column width(max= $max_column_width, avg= $average_column_width )";
puts $fp "BoothSel width (max= $max_boothSel_column_width, avg= $average_boothSel_column_width )";
puts $fp "USE_3_2_FLOORPLAN=$USE_3_2_FLOORPLAN";
puts $fp "BoothSel aspect ratio = $boothSel_aspect_ratio";

close $fp;

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
}


if {$max_compressed_column > 0} {
  initialize_floorplan \
  	-control_type row_number \
  	-number_rows [expr $rp_column_count+($boothSel_aspect_ratio-1)*$booth_sel_count] \
  	-core_utilization $core_utilization_ratio \
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
  	-core_utilization $core_utilization_ratio \
  	-row_core_ratio 1 \
  	-left_io2core $io2core \
  	-bottom_io2core $io2core \
  	-right_io2core $io2core \
  	-top_io2core $io2core \
  	-start_first_row
}

set placement_site_height [get_attribute [get_core_areas] tile_height];
set placement_site_width  [get_attribute [get_core_areas] tile_width];

if {[info exists ENABLE_MANUAL_PLACEMENT]} {

  # flip rows and columns to keep it more square
  suppress_message [list SEL-004 PSYN-1002 RPGP-020 RPGP-090 PSYN-040];

  create_rp_group rp_tree -columns [expr int(ceil(1.5*$row_count))] -rows $rp_column_count -allow_non_rp_cells ;

  if { $USE_3_2_FLOORPLAN } {
    set current_rp_column 0;
    set column_index $min_compressed_column;
    for { set column 0 } { $column < $column_count} { incr column } {
      if { ($column_count-1-$column) % $booth_select_cadence == 0 } {
        set boothSel_index [expr ($column_count-1-$column) / $booth_select_cadence];
        for {set boothEnc_index 0} { $boothEnc_index < $booth_encoder_count } {incr boothEnc_index} {
          set boothSel_child_cells [get_cells "Booth/BoothEnc_u${boothEnc_index}/Booth_sel_${boothSel_index}/*"];
          add_cells_to_rp_group $boothSel_child_cells rp_boothSel_${boothEnc_index}_${boothSel_index} \
                    ${DESIGN_NAME}::rp_tree -column $boothEnc_index -row $current_rp_column -height $boothSel_aspect_ratio;
        }
      } else {

        for {set row_index 0} { $row_index < $max_row } {incr row_index} {
          set CSA_child_cells [get_cells "Tree/column_*/csa*_${row_index}_${column_index}/*"];
          add_cells_to_rp_group $CSA_child_cells rp_CSA_${row_index}_${column_index} ${DESIGN_NAME}::rp_tree \
                    -column $row_index -row $current_rp_column;
        }
        set booth_column_index [expr $column_index -$min_compressed_column];
        if {[expr $booth_column_index%2]==0} {
          incr current_rp_column;
          for {set row_index 0} { $row_index < $booth_encoder_count } {incr row_index} {
            set booth_column_index_plus [expr $booth_column_index + 1];
            set booth_cell [get_cells "Booth/BoothEnc_u${row_index}/cell_${booth_column_index}/* Booth/BoothEnc_u${row_index}/cell_${booth_column_index_plus}/*"];
            add_cells_to_rp_group $booth_cell rp_booth_${row_index}_${booth_column_index} ${DESIGN_NAME}::rp_tree \
                    -column $row_index -row $current_rp_column;
          }

        }
        incr column_index;

      }

      incr current_rp_column;
    }

  } else {

    for { set i 0 } { $i < $rp_column_count} { incr i } {
      set column_occupied($i) 0;
    }

    set boothSel_cells [get_cells -hierarchical "*Booth_sel_*"];


    foreach_in_collection boothSel_cell $boothSel_cells {

      set boothSel_name [get_object_name $boothSel_cell];

      regexp {BoothEnc_u([0-9]*)/Booth_sel_([0-9])} $boothSel_name matched boothEnc_index boothSel_index;
      set boothSel_column [expr $rp_column_count -1 - ($booth_sel_count-1-$boothSel_index)*$rp_column_count/$booth_sel_count];

      set column_occupied($boothSel_column) 1;

      set boothSel_child_cells [get_cells "${boothSel_name}/*"];

      add_cells_to_rp_group $boothSel_child_cells rp_boothSel_${boothEnc_index}_${boothSel_index} ${DESIGN_NAME}::rp_tree \
                    -column [expr int(floor(1.5*$boothEnc_index))] -row $boothSel_column -height $boothSel_aspect_ratio;
    }

    set column_offset(0) $column_occupied(0);
    for { set i 1 } { $i < $rp_column_count} { incr i } {
      set column_offset($i) $column_offset([expr $i-1]);
      set occupy_idx [expr $i+$column_offset($i)];
      if { $occupy_idx < $rp_column_count} {
        set column_offset($i) [expr $column_offset($i)+$column_occupied($occupy_idx) ]
      }
    }

    foreach_in_collection CSA_cell $CSA_cells {

      set CSA_name [get_object_name $CSA_cell];

      regexp {column_([0-9]*)/csa([0-9]*)_([0-9]*)_([0-9]*)} $CSA_name matched CSA_level CSA_column row_index compressed_CSA_column;
      set is_odd_row [expr $row_index%2];
      set column_index [expr 2*($compressed_CSA_column-$min_compressed_column)+$is_odd_row];
      set column_position [expr $column_index + $column_offset($column_index)];
 
      # Second: CSA cells

      set CSA_child_cells [get_cells "${CSA_name}/*"];
      add_cells_to_rp_group $CSA_child_cells rp_CSA_${row_index}_${column_index} ${DESIGN_NAME}::rp_tree \
                    -column [expr int(floor(1.5*$row_index))+1-$is_odd_row] -row $column_position;

      set in_space [expr  ($row_index%4==0 || $row_index%4==1)? \
                    int(floor( 4 * ( 1.3 * $max_column_width - ($is_odd_row ? $column_odd_width($compressed_CSA_column) : $column_even_width($compressed_CSA_column) )) / ( $placement_site_width * $row_count) ))  \
                    : 0 ];
      if {$in_space>0} {
        add_to_rp_group ${DESIGN_NAME}::rp_tree -keepout SPACE_${row_index}_${column_index} -type space -width $in_space -height 1 \
                    -column [expr int(floor(1.5*$row_index))+2-$is_odd_row] -row $column_position;
      }
    }

    foreach_in_collection booth_cell $booth_cells {

      set booth_cell_name [get_object_name $booth_cell];
      regexp {BoothEnc_u([0-9]*)/cell_([0-9]*)} $booth_cell_name  matched row_index booth_column_index;
      set is_odd_row [expr $row_index%2];
      set column_index [expr 2*$booth_column_index+$is_odd_row ];
      set column_position [expr $column_index + $column_offset($column_index)];

      set booth_child_cells [get_cells "${booth_cell_name}/*"];
      add_cells_to_rp_group $booth_child_cells rp_booth_${row_index}_${booth_column_index} ${DESIGN_NAME}::rp_tree \
                    -column [expr int(floor(1.5*$row_index))-$is_odd_row] -row $column_position;
    }

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

  if {[file exists ../../place_PartialProductSum.tcl] && $DESIGN_NAME!="MultiplierP_unq1"} {
    source -echo ../../place_PartialProductSum.tcl
    check_rp_groups -verbose ${DESIGN_NAME}::PartialProductSum
    check_rp_groups -verbose ${DESIGN_NAME}::PartialProductSum_2
    create_rp_group RP_MULT -columns 2 -rows 2 -allow_non_rp_cells
    add_to_rp_group ${DESIGN_NAME}::RP_MULT   -hierarchy ${DESIGN_NAME}::rp_tree            -column 0 -row 1 ;
    add_to_rp_group ${DESIGN_NAME}::RP_MULT   -hierarchy ${DESIGN_NAME}::PartialProductSum  -column 0 -row 0 ;
    add_to_rp_group ${DESIGN_NAME}::RP_MULT   -hierarchy ${DESIGN_NAME}::PartialProductSum_2  -column 1 -row 1 ;
    check_rp_groups -verbose ${DESIGN_NAME}::RP_MULT
  }

  check_rp_groups -all -verbose


  set_rp_group_options [all_rp_groups] \
           -allow_non_rp_cells \
           -placement_type compression;
#           -psynopt_option fixed_placement \
#           -disable_buffering \
#           -route_opt_option in_place_size_only \
#           -cts_option fixed_placement;

  check_rp_groups -all -verbose


}







save_mw_cel -as ${DESIGN_NAME}_before_placement



if {$TLUPLUS_MIN_FILE == ""} {set TLUPLUS_MIN_FILE $TLUPLUS_MAX_FILE}
set_tlu_plus_files \
     -max_tluplus $TLUPLUS_MAX_FILE \
     -min_tluplus $TLUPLUS_MIN_FILE \
     -tech2itf_map $MAP_FILE               ;# set the tlu plus files

derive_pg_connection -power_net $MW_POWER_NET -power_pin $MW_POWER_PORT -ground_net $MW_GROUND_NET -ground_pin $MW_GROUND_PORT
derive_pg_connection -power_net $MW_POWER_NET -power_pin $MW_POWER_PORT -ground_net $MW_GROUND_NET -ground_pin $MW_GROUND_PORT -tie


#place_opt  -effort low


 if {$max_compressed_column > 0} {
#  place_opt -effort high -power -area_recovery
  create_placement
#  psynopt -area_recovery
  refine_placement
  save_mw_cel -as ${DESIGN_NAME}_before_rp_blowout
  remove_rp_groups -all
  refine_placement
  save_mw_cel -as ${DESIGN_NAME}_before_psynopt
  place_opt -skip_initial_placement -effort high -power -area_recovery
  estimate_fp_area -sizing_type fixed_height
 } else {
  place_opt -effort high -power -area_recovery
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

