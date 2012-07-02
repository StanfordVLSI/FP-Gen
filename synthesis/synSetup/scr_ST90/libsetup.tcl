# set wc library database
set wc_1v0_lib_dbs [ list \
    $env(CORE90GPLVT_1V0_WC) \
    $env(CORE90GPSVT_1V0_WC) \
    $env(CORE90GPHVT_1V0_WC) \
    $env(CLOCK90GPLVT_1V0_WC) \
    $env(CLOCK90GPSVT_1V0_WC) \
    $env(CLOCK90GPHVT_1V0_WC) \
    $env(CORX90GPLVT_1V0_WC) \
    $env(CORX90GPSVT_1V0_WC) \
    $env(CORX90GPHVT_1V0_WC) \
    $env(IO90GPHVT_1V0_WC) \
    $env(IO90GPHVT_BASIC_1V0_WC) \
    $env(IO90GPHVT_FILLERCUT_1V0_WC) \
    $env(IO90GPHVT_REF_COMPENSATION_1V0_WC) \
]

set wc_1v2_lib_dbs [ list \
    $env(CORE90GPLVT_1V2_WC) \
    $env(CORE90GPSVT_1V2_WC) \
    $env(CORE90GPHVT_1V2_WC) \
    $env(CLOCK90GPLVT_1V2_WC) \
    $env(CLOCK90GPSVT_1V2_WC) \
    $env(CLOCK90GPHVT_1V2_WC) \
    $env(CORX90GPLVT_1V2_WC) \
    $env(CORX90GPSVT_1V2_WC) \
    $env(CORX90GPHVT_1V2_WC) \
    $env(IO90GPHVT_1V2_WC) \
    $env(IO90GPHVT_BASIC_1V2_WC) \
    $env(IO90GPHVT_FILLERCUT_1V2_WC) \
    $env(IO90GPHVT_REF_COMPENSATION_1V2_WC) \
]

# set bc library database
set bc_1v0_lib_dbs [ list \
    $env(CORE90GPLVT_1V0_BC) \
    $env(CORE90GPSVT_1V0_BC) \
    $env(CORE90GPHVT_1V0_BC) \
    $env(CLOCK90GPLVT_1V0_BC) \
    $env(CLOCK90GPSVT_1V0_BC) \
    $env(CLOCK90GPHVT_1V0_BC) \
    $env(CORX90GPLVT_1V0_BC) \
    $env(CORX90GPSVT_1V0_BC) \
    $env(CORX90GPHVT_1V0_BC) \
    $env(IO90GPHVT_1V0_BC) \
    $env(IO90GPHVT_BASIC_1V0_BC) \
    $env(IO90GPHVT_FILLERCUT_1V0_BC) \
    $env(IO90GPHVT_REF_COMPENSATION_1V0_BC) \
]

set bc_1v2_lib_dbs [ list \
    $env(CORE90GPLVT_1V2_BC) \
    $env(CORE90GPSVT_1V2_BC) \
    $env(CORE90GPHVT_1V2_BC) \
    $env(CLOCK90GPLVT_1V2_BC) \
    $env(CLOCK90GPSVT_1V2_BC) \
    $env(CLOCK90GPHVT_1V2_BC) \
    $env(CORX90GPLVT_1V2_BC) \
    $env(CORX90GPSVT_1V2_BC) \
    $env(CORX90GPHVT_1V2_BC) \
    $env(IO90GPHVT_1V2_BC) \
    $env(IO90GPHVT_BASIC_1V2_BC) \
    $env(IO90GPHVT_FILLERCUT_1V2_BC) \
    $env(IO90GPHVT_REF_COMPENSATION_1V2_BC) \
]

# set wc bc library pairs database
set wc_bc_1v0_lib_dbs [ list \
    $env(CORE90GPLVT_1V0_WC) $env(CORE90GPLVT_1V0_BC) \
    $env(CORE90GPSVT_1V0_WC) $env(CORE90GPSVT_1V0_BC) \
    $env(CORE90GPHVT_1V0_WC) $env(CORE90GPHVT_1V0_BC) \
    $env(CLOCK90GPLVT_1V0_WC) $env(CLOCK90GPLVT_1V0_BC) \
    $env(CLOCK90GPSVT_1V0_WC) $env(CLOCK90GPSVT_1V0_BC) \
    $env(CLOCK90GPHVT_1V0_WC) $env(CLOCK90GPHVT_1V0_BC) \
    $env(CORX90GPLVT_1V0_WC) $env(CORX90GPLVT_1V0_BC) \
    $env(CORX90GPSVT_1V0_WC) $env(CORX90GPSVT_1V0_BC) \
    $env(CORX90GPHVT_1V0_WC) $env(CORX90GPHVT_1V0_BC) \
    $env(IO90GPHVT_1V0_WC) $env(IO90GPHVT_1V0_BC) \
    $env(IO90GPHVT_BASIC_1V0_WC) $env(IO90GPHVT_BASIC_1V0_BC) \
    $env(IO90GPHVT_FILLERCUT_1V0_WC) $env(IO90GPHVT_FILLERCUT_1V0_BC) \
    $env(IO90GPHVT_REF_COMPENSATION_1V0_WC) $env(IO90GPHVT_REF_COMPENSATION_1V0_BC) \
]

set wc_bc_1v2_lib_dbs [ list \
    $env(CORE90GPLVT_1V2_WC) $env(CORE90GPLVT_1V2_BC) \
    $env(CORE90GPSVT_1V2_WC) $env(CORE90GPSVT_1V2_BC) \
    $env(CORE90GPHVT_1V2_WC) $env(CORE90GPHVT_1V2_BC) \
    $env(CLOCK90GPLVT_1V2_WC) $env(CLOCK90GPLVT_1V2_BC) \
    $env(CLOCK90GPSVT_1V2_WC) $env(CLOCK90GPSVT_1V2_BC) \
    $env(CLOCK90GPHVT_1V2_WC) $env(CLOCK90GPHVT_1V2_BC) \
    $env(CORX90GPLVT_1V2_WC) $env(CORX90GPLVT_1V2_BC) \
    $env(CORX90GPSVT_1V2_WC) $env(CORX90GPSVT_1V2_BC) \
    $env(CORX90GPHVT_1V2_WC) $env(CORX90GPHVT_1V2_BC) \
    $env(IO90GPHVT_1V2_WC) $env(IO90GPHVT_1V2_BC) \
    $env(IO90GPHVT_BASIC_1V2_WC) $env(IO90GPHVT_BASIC_1V2_BC) \
    $env(IO90GPHVT_FILLERCUT_1V2_WC) $env(IO90GPHVT_FILLERCUT_1V2_BC) \
    $env(IO90GPHVT_REF_COMPENSATION_1V2_WC) $env(IO90GPHVT_REF_COMPENSATION_1V2_BC) \
]

# set milkyway reference library database
set mw_ref_lib_dbs [ list \
    $env(CORE90GPLVT_MW) \
    $env(CORE90GPSVT_MW) \
    $env(CORE90GPHVT_MW) \
    $env(CLOCK90GPLVT_MW) \
    $env(CLOCK90GPSVT_MW) \
    $env(CLOCK90GPHVT_MW) \
    $env(CORX90GPLVT_MW) \
    $env(CORX90GPSVT_MW) \
    $env(CORX90GPHVT_MW) \
    $env(IO90GPHVT_MW) \
    $env(IO90GPHVT_BASIC_MW) \
    $env(IO90GPHVT_FILLERCUT_MW) \
    $env(IO90GPHVT_REF_COMPENSATION_MW) \
    $env(UNITTILE_STD_MW) \
]

# set target library
set lvt_1v0_target_libs   [list $env(CORE90GPLVT_1V0_WC) $env(CORX90GPLVT_1V0_WC)]
set svt_1v0_target_libs   [list $env(CORE90GPSVT_1V0_WC) $env(CORX90GPSVT_1V0_WC)]
set hvt_1v0_target_libs   [list $env(CORE90GPHVT_1V0_WC) $env(CORX90GPHVT_1V0_WC)]
set mvt_1v0_target_libs   [concat $lvt_1v0_target_libs $svt_1v0_target_libs $hvt_1v0_target_libs]

set lvt_1v2_target_libs  [list $env(CORE90GPLVT_1V2_WC) $env(CORX90GPLVT_1V2_WC)]
set svt_1v2_target_libs  [list $env(CORE90GPSVT_1V2_WC) $env(CORX90GPSVT_1V2_WC)]
set hvt_1v2_target_libs  [list $env(CORE90GPHVT_1V2_WC) $env(CORX90GPHVT_1V2_WC)]
set mvt_1v2_target_libs  [concat $lvt_1v2_target_libs $svt_1v2_target_libs $hvt_1v2_target_libs]

if {$ENABLE_HIGH_VOLTAGE} {
  set LIB_VOLTAGE 1V2
} else {
  set LIB_VOLTAGE 1V0
}


set target_library $env(CORE90GPSVT_${LIB_VOLTAGE}_WC)
if {$ENABLE_MVT} {
    lappend target_library $env(CORE90GPLVT_${LIB_VOLTAGE}_WC)
	  lappend target_library $env(CORE90GPHVT_${LIB_VOLTAGE}_WC)	
}
	
if {$ENABLE_CORX} {
    lappend target_library $env(CORX90GPSVT_${LIB_VOLTAGE}_WC)
    if {$ENABLE_MVT} {
      lappend target_library $env(CORX90GPHVT_${LIB_VOLTAGE}_WC)
	    lappend target_library $env(CORX90GPLVT_${LIB_VOLTAGE}_WC)	
    }		
}	
    
if {$ENABLE_CLOCK_GATE} {
    lappend target_library $env(CORX90GPLVT_${LIB_VOLTAGE}_WC)
}	

# set link library to all wc library dbs

set link_library [set wc_[string tolower $LIB_VOLTAGE]_lib_dbs]

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
