set TECH_DIR          $env(TSMC_MWLIB_DIR)/tcbn45gsbwp_110a/techfiles
set TECH_FILE         ${TECH_DIR}/VHV_0d5_0/tsmcn45_10lm7X2ZRDL.tf ;#  Milkyway technology file
set MAP_FILE          ${TECH_DIR}/tluplus/star.map_10M ;#  Mapping file for TLUplus
set TLUPLUS_MAX_FILE  ${TECH_DIR}/tluplus/cln45gs_1p10m+alrdl_cworst_top2.tluplus; #  Max TLUplus file
set TLUPLUS_MIN_FILE  ${TECH_DIR}/tluplus/cln45gs_1p10m+alrdl_rcbest_top2.tluplus ;#  Min TLUplus file

###############################
## SIGNOFF_OPT Input variables
###############################
set PT_DIR      $env(SYNOPSYS_PTS)/bin   ;# path to PT bin directory
set PT_SDC_FILE ""                     ;# optional file in case PT has different SDC that what is available in the ICC database
set STARRCXT_DIR $env(SYNOPSYS_STARRC_DIR)/bin ;# path to Star-rcxt bin directory

set STARRCXT_MAX_NXTGRD $TLUPLUS_MAX_FILE ;# MAX NXTGRD file 
set STARRCXT_MIN_NXTGRD $TLUPLUS_MIN_FILE ;# MIN NXTGRD file
set STARRCXT_MAP_FILE   $MAP_FILE ;# NXTGRD mapping file, defaults to TLUPlus mapping file, but could be different

set MW_POWER_NET                "VDD" ;#
set MW_POWER_PORT               "VDD" ;#
set MW_GROUND_NET               "VSS" ;#
set MW_GROUND_PORT              "VSS" ;#

set MIN_ROUTING_LAYER            ""   ;# Min routing layer
set MAX_ROUTING_LAYER            "M6"   ;# Max routing layer

set PNS_PAD_MASTERS        		"pv0i.FRAM pv0a.FRAM"		;# Only for top level design. Specify cell masters for power pads, e.g. "pv0i.FRAM pv0a.FRAM"

