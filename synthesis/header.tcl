

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


set_host_options -max_cores 2

set target_library [set ${VT}_[string tolower $Voltage]_target_libs]
set link_library [set link_library_[string tolower $Voltage] ]

if {![info exists DESIGN_TARGET]} {
    exit 7;
}

# Suppressed Messages:
# Information: Changed wire load model for 'BoothCell_unq1_1451' from 'ZeroWireload' to 'ZeroWireload'. (OPT-170)
# Information: Skipping clock gating on design BoothSel_unq1_33, since there are no registers. (PWR-806)
suppress_message {OPT-170 PWR-806}




proc report_DESIGN_power {args} {


  global link_library;
  global DESIGN_TARGET;
  global target_delay;
  global APPENDIX;
  global USE_GATE_SAIF;
  global link_library_0v8;
  global link_library_0v9;
  global link_library_1v0;

  parse_proc_arguments -args $args results
  foreach argname [array names results] { 
    set [regsub {\-} $argname ""] $results($argname);
  }


  if { $USE_GATE_SAIF } {
    reset_switching_activity
    read_saif -auto_map_names -instance top_${DESIGN_TARGET}/${DESIGN_TARGET} -input SAIF/${DESIGN_TARGET}.dc.${inst_name}.saif -verbose
  } else {
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
  {{config_name "name of configuration: mapped, routed" config_name string required}
   {inst_name "name of instruction: add, mul, muladd, avg" inst_name string required}}


