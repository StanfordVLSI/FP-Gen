# set wc library database
set wc_lib_dbs [ list \
			 $env(CORE28SOILR_WC)\
			 $env(CORE28SOILL_WC) \
			 $env(CLK28SOILR_WC)\
			 $env(CLK28SOILL_WC)\
			 $env(PR28SOILR_WC)\
			 $env(PR28SOILL_WC)\

]

# set bc library database
set bc_lib_dbs [ list \
			 $env(CORE28SOILR_BC)\
			 $env(CORE28SOILL_BC) \
			 $env(CLK28SOILR_BC)\
			 $env(CLK28SOILL_BC)\
			 $env(PR28SOILR_BC)\
			 $env(PR28SOILL_BC)\

]
		     

# set milkyway reference library database
set mw_ref_lib_dbs [ list \
			 $env(CORE28SOILR_MW) \
			 $env(CORE28SOILL_MW) \
			 $env(CLK28SOILR_MW) \
			 $env(CLK28SOILL_MW) \
			 $env(PR28SOILR_MW) \
			 $env(PR28SOILL_MW) \
			 $env(UNITTILE_12T_MW)\
]

# set symbol library
set symbol_library [list \
			$env(CORE28SOILR_SYM) \
			$env(CORE28SOILL_SYM) \
			$env(CLK28SOILR_SYM) \
			$env(CLK28SOILL_SYM) \ 
]

# set target library
set lvt_target_libs  [list \
			      $env(CORE28SOILL_WC) \
			      $env(CLK28SOILL_WC) \
			      $env(PR28SOILL_WC)\
]

set rvt_target_libs  [list \
			      $env(CORE28SOILR_WC) \
			      $env(CLK28SOILR_WC) \
			      $env(PR28SOILR_WC)\
]


if {$VT == "lvt" } {
  set target_library  $lvt_target_libs
} elseif {$VT == "rvt"} {
  set target_library  $rvt_target_libs
}

set synthetic_library [list dw_foundation.sldb]

set link_library $wc_lib_dbs

foreach L $synthetic_library {
 lappend link_library $L
}

if { ($synopsys_program_name == "icc_shell") } {
# attach min library to max library to be used for hold-time fix if the variable $holdfix is defined
foreach wc_lib_db $wc_lib_dbs bc_lib_db $bc_lib_dbs {
    set  command  "set_min_library $wc_lib_db -min_version $bc_lib_db"
    echo $command
    eval $command
}
}
