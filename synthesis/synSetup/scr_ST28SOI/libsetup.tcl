# set wc library database
set wc_lib_dbs [ list \
			 $env(CORE28SOILR_WC)\
			 $env(CORE28SOILL_WC) \
			 $env(CLK28SOILR_WC)\
			 $env(CLK28SOILL_WC)\
			 $env(PR28SOILR_WC)\
			 $env(PR28SOILL_WC)\
			 $env(IO28SOI_BASIC_WC)\
			 $env(IO28SOI_CORESUPPLY_WC)\
			 $env(IO28SOI_IO_WC)\

]

# set bc library database
set bc_lib_dbs [ list \
			 $env(CORE28SOILR_BC)\
			 $env(CORE28SOILL_BC) \
			 $env(CLK28SOILR_BC)\
			 $env(CLK28SOILL_BC)\
			 $env(PR28SOILR_BC)\
			 $env(PR28SOILL_BC)\
			 $env(IO28SOI_BASIC_BC)\
			 $env(IO28SOI_CORESUPPLY_BC)\
			 $env(IO28SOI_IO_BC)\

]
		     

# set milkyway reference library database
set mw_ref_lib_dbs [ list \
			 $env(CORE28SOILR_MW) \
			 $env(CORE28SOILL_MW) \
			 $env(CLK28SOILR_MW) \
			 $env(CLK28SOILL_MW) \
			 $env(PR28SOILR_MW) \
			 $env(PR28SOILL_MW) \
			 $env(IO28SOI_BASIC_MW)\
			 $env(IO28SOI_CORESUPPLY_MW)\
			 $env(IO28SOI_IO_MW)\
			 $env(IO28SOI_FRAMEKIT_MW)\
			 $env(IO28SOI_SUPPLYKIT_MW)\
			 $env(IO28SOI_BUMP_MW)\
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
			      $env(IO28SOI_BASIC_WC)\
]


if {$ENABLE_HIGH_VOLTAGE} {
  set LIB_VOLTAGE 1V0
} else {
  set LIB_VOLTAGE WC
}


set target_library  $lvt_target_libs
if {$ENABLE_MVT} {
#    lappend target_library $env(TCBN45GS_LVT_WC_${LIB_VOLTAGE})
#	  lappend target_library $env(TCBN45GS_HVT_WC_${LIB_VOLTAGE})	
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