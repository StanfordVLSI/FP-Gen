

source $env(FPGEN)/synthesis/synSetup/synopsys_startup/libselector.tcl

if {![info exists DESIGN_HOME]} {
  set DESIGN_HOME "../.."
}

if {![info exists VT]} {
  set VT lvt
}



if {![info exists Voltage]} {
  set Voltage 1v0
}

#TODO: get clk to q delay from datasheets that is vth and vdd specific instead of average
set CLOCK_TO_Q_DELAY 0.15
set CLOCK_SETUP_TIME 0.05

if {![info exists target_delay]} {
  set target_delay 0
}

if {[info exists CLOCK_PERIOD_PS]} {
  set CLOCK_PERIOD [expr double($CLOCK_PERIOD_PS)/1000];
} else {
  set CLOCK_PERIOD [expr $target_delay+$CLOCK_SETUP_TIME+$CLOCK_TO_Q_DELAY];
}

if {![info exists PIPELINE_STAGES_COUNT]} {
  set PIPELINE_STAGES_COUNT 0
}

if {![info exists io2core]} {
  set io2core 30
}

if {[info exists ENABLE_MANUAL_PLACEMENT]} {
  set APPENDIX optimized.$VT
} else {
  set APPENDIX $VT
}

if { [info exists ENABLE_MANUAL_PLACEMENT] } {
    if { ![file exists ../../place_MultiplierP.tcl] } {
	unset ENABLE_MANUAL_PLACEMENT  
    }
}

if { [file exists ../../gen_params.tcl] } {
  source -echo -verbose ../../gen_params.tcl
} 

if {![info exists PipelineDepth]} {
  set PipelineDepth 0
}

if {![info exists Retiming]} {
  set Retiming 1
}

if {![info exists SmartRetiming]} {
  set SmartRetiming 0
}

if {![info exists MulpPipelineDepth]} {
  set MulpPipelineDepth 1
}

if {![info exists EnableMultiplePumping]} {
  set EnableMultiplePumping NO
}

if {![info exists EnableClockGating]} {
  set EnableClockGating 1
}

set $Voltage [string tolower $Voltage]

set_host_options -max_cores 2

set target_library [set ${VT}_${Voltage}_target_libs]
set link_library [set link_library_${Voltage}]

if { $Voltage=="0v9"} {
  set wc_voltage ""
} elseif { $Voltage  =="1v0"} {
  set wc_voltage "0d9"
} else {
  set wc_voltage "0d72"
}

if { $VT=="svt" } {
  set library_name "tcbn45gsbwpwc${wc_voltage}"
} else {
  set library_name "tcbn45gsbwp${VT}wc${wc_voltage}"
}

if {![info exists DESIGN_TARGET]} {
    exit 7;
}

# Suppressed Messages:
# Information: Changed wire load model for 'BoothCell_unq1_1451' from 'ZeroWireload' to 'ZeroWireload'. (OPT-170)
# Information: Skipping clock gating on design BoothSel_unq1_33, since there are no registers. (PWR-806)
suppress_message {OPT-170 PWR-806}

if { $synopsys_program_name == "dc_shell" && [shell_is_in_topographical_mode] } {
  set MW_DESIGN_LIBRARY ${DESIGN_TARGET}_${VT}_${target_delay}_LIB
  if { ![file isdirectory $MW_DESIGN_LIBRARY] } {
     create_mw_lib \
            -tech $TECH_FILE \
            -bus_naming_style {[%d]} \
            -mw_reference_library $mw_ref_lib_dbs \
            $MW_DESIGN_LIBRARY
  } else {
     set_mw_lib_reference $MW_DESIGN_LIBRARY -mw_reference_library $mw_ref_lib_dbs
  }

  open_mw_lib $MW_DESIGN_LIBRARY

  check_library

  set_tlu_plus_files \
      -max_tluplus $TLUPLUS_MAX_FILE \
      -min_tluplus $TLUPLUS_MIN_FILE \
      -tech2itf_map $MAP_FILE               ;# set the tlu plus files

  check_tlu_plus_files
}



proc set_DESIGN_switching_activity {args} {

  global DESIGN_TARGET;
  set saif_file ""
  parse_proc_arguments -args $args results
  foreach argname [array names results] { 
    set [regsub {\-} $argname ""] $results($argname);
  }

  if { $saif_file=="" } {
      set_switching_activity -toggle_rate 0 -base_clock clk -static_probability 0 mp_mode

      set_switching_activity -toggle_rate 0.5 -base_clock clk -static_probability 0.5 -type inputs
      set_switching_activity -toggle_rate 2 -base_clock clk -static_probability 0.5 clk
      if { [get_ports SI] != []} {
	  set_switching_activity -toggle_rate 0.01 -base_clock clk -static_probability 0.01 {reset SI stall_in SCAN_ENABLE test_mode}
      }
      if { [get_ports valid_in] != [] } {
	  set_switching_activity -toggle_rate 0 -base_clock clk -static_probability 1 valid_in
      }
    if { $inst_name=="add" } {
      set_switching_activity -toggle_rate 0 -base_clock clk -static_probability 1 adder_mode
      set_switching_activity -toggle_rate 0 -base_clock clk -static_probability 0 multiplier_mode
    } elseif { $inst_name=="mul" } {
      set_switching_activity -toggle_rate 0 -base_clock clk -static_probability 0 adder_mode
      set_switching_activity -toggle_rate 0 -base_clock clk -static_probability 1 multiplier_mode
    } elseif { $inst_name=="muladd" } {
      set_switching_activity -toggle_rate 0 -base_clock clk -static_probability 0 adder_mode
      set_switching_activity -toggle_rate 0 -base_clock clk -static_probability 0 multiplier_mode
    } elseif { $inst_name=="avg" } {
      set_switching_activity -toggle_rate 0.2 -base_clock clk -static_probability 0.4 adder_mode
      set_switching_activity -toggle_rate 0.2 -base_clock clk -static_probability 0.25 multiplier_mode
    }
  } else {
    read_saif -auto_map_names -instance top_$DESIGN_TARGET/$DESIGN_TARGET -input $saif_file -verbose
  }

  set_switching_activity -toggle_rate 0 -base_clock clk -static_probability 0 mp_mode
}

define_proc_attributes set_DESIGN_switching_activity -info "Sets the switching activity factors on the design." \
  -define_args \
  {{inst_name "name of instruction: add, mul, muladd, avg" inst_name string required}
   {saif_file "saif file to read from" inst_name string optional}}



proc report_DESIGN_power {args} {


  global link_library;
  global DESIGN_TARGET;
  global target_delay;
  global APPENDIX;
  global link_library_0v8;
  global link_library_0v9;
  global link_library_1v0;

  parse_proc_arguments -args $args results
  foreach argname [array names results] { 
    set [regsub {\-} $argname ""] $results($argname);
  }

  if { $saif_type=="icc" && [info exists ENABLE_MANUAL_PLACEMENT] } {
    set saif_type "icc_opt";
  }

  
  
  reset_switching_activity
  if { $use_saif } {
    set_DESIGN_switching_activity $inst_name SAIF/$DESIGN_TARGET.$saif_type.$inst_name.saif
  } else {
    set_DESIGN_switching_activity $inst_name
  }

  remove_attribute -quiet [current_design] local_link_library

  set link_library $link_library_0v8
  report_power -analysis_effort high -hierarchy -levels 3  > reports/${DESIGN_TARGET}.${APPENDIX}_0v8.$target_delay.$config_name.${inst_name}_power.rpt

  set link_library $link_library_0v9
  report_power -analysis_effort high -hierarchy -levels 3  > reports/${DESIGN_TARGET}.${APPENDIX}_0v9.$target_delay.$config_name.${inst_name}_power.rpt

  set link_library $link_library_1v0
  report_power -analysis_effort high -hierarchy -levels 3  > reports/${DESIGN_TARGET}.${APPENDIX}_1v0.$target_delay.$config_name.${inst_name}_power.rpt

}

define_proc_attributes report_DESIGN_power -info "Reports power for FPGen for different instructions." \
  -define_args \
  {{saif_type "type of saif file used:dc, icc, icc_opt" saif_type string required}
   {config_name "name of configuration: mapped, routed" config_name string required}
   {inst_name "name of instruction: add, mul, muladd, avg" inst_name string required}
   {use_saif "use saif file" integer int required}}


