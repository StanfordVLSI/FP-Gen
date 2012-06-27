
if {[info exists ENABLE_90]} {
  source $env(HOME)/synopsys_startup/scr_ST90/common_options.tcl
  source $env(HOME)/synopsys_startup/scr_ST90/libsetup.tcl -continue_on_error
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

set target_library [set ${VT}_${Voltage}_target_libs]

set_host_options -max_cores 2

set link_library [set wc_${Voltage}_lib_dbs]
set synthetic_library [list dw_foundation.sldb]
foreach L $synthetic_library {
 lappend link_library $L
}

if {![info exists DESIGN_TARGET]} {
    exit ;
} else {
    set DESIGN_NAME ${DESIGN_TARGET}
}

# Suppressed Messages:
# Information: Changed wire load model for 'BoothCell_unq1_1451' from 'ZeroWireload' to 'ZeroWireload'. (OPT-170)
suppress_message [list OPT-170]

