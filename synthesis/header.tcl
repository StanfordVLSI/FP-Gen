
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

if {[info exists ENABLE_MANUAL_PLACEMENT]} {
  set APPENDIX optimized.$VT
} else {
  set APPENDIX $VT
}

set target_library [set ${VT}_${Voltage}_target_libs]

set link_library [set wc_${Voltage}_lib_dbs]
set synthetic_library [list dw_foundation.sldb]
foreach L $synthetic_library {
 lappend link_library $L
}


set DESIGN_NAME Multiplier_unq1
