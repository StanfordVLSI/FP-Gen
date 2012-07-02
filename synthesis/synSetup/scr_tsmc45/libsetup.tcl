# set wc library database
set wc_0v8_lib_dbs [ list \
    $env(TCBN45GS_SVT_WC_0V8) \
    $env(TCBN45GS_LVT_WC_0V8) \
    $env(TCBN45GS_HVT_WC_0V8) \
]

set wc_0v9_lib_dbs [ list \
    $env(TCBN45GS_SVT_WC_0V9) \
    $env(TCBN45GS_LVT_WC_0V9) \
    $env(TCBN45GS_HVT_WC_0V9) \
]

set wc_1v0_lib_dbs [ list \
    $env(TCBN45GS_SVT_WC_1V0) \
    $env(TCBN45GS_LVT_WC_1V0) \
    $env(TCBN45GS_HVT_WC_1V0) \
]

# set bc library database
set bc_0v8_lib_dbs [ list \
    $env(TCBN45GS_SVT_BC_0V8) \
    $env(TCBN45GS_LVT_BC_0V8) \
    $env(TCBN45GS_HVT_BC_0V8) \
]

set bc_0v9_lib_dbs [ list \
    $env(TCBN45GS_SVT_BC_0V9) \
    $env(TCBN45GS_LVT_BC_0V9) \
    $env(TCBN45GS_HVT_BC_0V9) \
]

set bc_1v0_lib_dbs [ list \
    $env(TCBN45GS_SVT_BC_1V0) \
    $env(TCBN45GS_LVT_BC_1V0) \
    $env(TCBN45GS_HVT_BC_1V0) \
]

# set wc bc library pairs database
set wc_bc_0v8_lib_dbs [ list \
    $env(TCBN45GS_SVT_WC_0V8) $env(TCBN45GS_SVT_BC_0V8) \
    $env(TCBN45GS_LVT_WC_0V8) $env(TCBN45GS_LVT_BC_0V8) \
    $env(TCBN45GS_HVT_WC_0V8) $env(TCBN45GS_HVT_BC_0V8) \
]

set wc_bc_0v9_lib_dbs [ list \
    $env(TCBN45GS_SVT_WC_0V9) $env(TCBN45GS_SVT_BC_0V9) \
    $env(TCBN45GS_LVT_WC_0V9) $env(TCBN45GS_LVT_BC_0V9) \
    $env(TCBN45GS_HVT_WC_0V9) $env(TCBN45GS_HVT_BC_0V9) \
]

set wc_bc_1v0_lib_dbs [ list \
    $env(TCBN45GS_SVT_WC_0V9) $env(TCBN45GS_SVT_BC_0V9) \
    $env(TCBN45GS_LVT_WC_0V9) $env(TCBN45GS_LVT_BC_0V9) \
    $env(TCBN45GS_HVT_WC_0V9) $env(TCBN45GS_HVT_BC_0V9) \
]

# set milkyway reference library database
set mw_ref_lib_dbs [ list \
    $env(TCBN45GS_SVT_MW) \
    $env(TCBN45GSLVT_MW) \
    $env(TCBN45GSHVT_MW) \
]

# set target library
set lvt_0v8_target_libs   $env(TCBN45GS_LVT_WC_0V8)
set svt_0v8_target_libs   $env(TCBN45GS_SVT_WC_0V8)
set hvt_0v8_target_libs   $env(TCBN45GS_HVT_WC_0V8)
set mvt_0v8_target_libs   [concat $lvt_0v8_target_libs $svt_0v8_target_libs $hvt_0v8_target_libs]

set lvt_0v9_target_libs   $env(TCBN45GS_LVT_WC_0V9)
set svt_0v9_target_libs   $env(TCBN45GS_SVT_WC_0V9)
set hvt_0v9_target_libs   $env(TCBN45GS_HVT_WC_0V9)
set mvt_0v9_target_libs   [concat $lvt_0v9_target_libs $svt_0v9_target_libs $hvt_0v9_target_libs]

set lvt_1v0_target_libs   $env(TCBN45GS_LVT_WC_1V0)
set svt_1v0_target_libs   $env(TCBN45GS_SVT_WC_1V0)
set hvt_1v0_target_libs   $env(TCBN45GS_HVT_WC_1V0)
set mvt_1v0_target_libs   [concat $lvt_1v0_target_libs $svt_1v0_target_libs $hvt_1v0_target_libs]

if {$ENABLE_HIGH_VOLTAGE} {
  set LIB_VOLTAGE 1V0
} else {
  set LIB_VOLTAGE 0V9
}


set target_library $env(TCBN45GS_SVT_WC_${LIB_VOLTAGE})
if {$ENABLE_MVT} {
    lappend target_library $env(TCBN45GS_LVT_WC_${LIB_VOLTAGE})
	  lappend target_library $env(TCBN45GS_HVT_WC_${LIB_VOLTAGE})	
}

# set link library to all wc library dbs


set link_library "*"

foreach L [set wc_[string tolower $LIB_VOLTAGE]_lib_dbs] {
 lappend link_library $L
}

set synthetic_library [list dw_foundation.sldb]

foreach L $synthetic_library {
 lappend link_library $L
}


# attach min library to max library to be used for hold-time fix if the variable $holdfix is defined
if {[info exists holdfix]} {
    foreach wc_lib_db $wc_lib_dbs bc_lib_db $bc_lib_dbs {
	set  command  "set_min_library $wc_lib_db -min_version $bc_lib_db"
	echo $command
	eval $command
    }
}

source -v -echo $env(HOME)/synopsys_startup/scr_tsmc45/init_psynenv.tcl
