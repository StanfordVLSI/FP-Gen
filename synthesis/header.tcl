
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

if {![info exists target_delay]} {
  set target_delay 0
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