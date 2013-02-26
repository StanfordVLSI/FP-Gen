set TECH_DIR          $env(ST28SOITECH_ROOT)
set TECH_FILE         ${TECH_DIR}/COMMON/tech_tile12T.tf ;#  Milkyway technology file
set MAP_FILE          ${TECH_DIR}/TLUPLUS/mapfile ;#  Mapping file for TLUplus
set TLUPLUS_MAX_FILE  ${TECH_DIR}/TLUPLUS/FuncCmax/tluplus; #  Max TLUplus file
set TLUPLUS_MIN_FILE  ${TECH_DIR}/TLUPLUS/FuncRCmin/tluplus ;#  Min TLUplus file

###############################
## SIGNOFF_OPT Input variables
###############################
set PT_DIR      $env(SYNOPSYS_PTS)/bin   ;# path to PT bin directory
set PT_SDC_FILE ""                     ;# optional file in case PT has different SDC that what is available in the ICC database
set STARRCXT_DIR $env(SYNOPSYS_STARRC_DIR)/bin ;# path to Star-rcxt bin directory

set STARRCXT_MAX_NXTGRD $TLUPLUS_MAX_FILE ;# MAX NXTGRD file 
set STARRCXT_MIN_NXTGRD $TLUPLUS_MIN_FILE ;# MIN NXTGRD file
set STARRCXT_MAP_FILE   $MAP_FILE ;# NXTGRD mapping file, defaults to TLUPlus mapping file, but could be different


set MW_POWER_NET                "vdd" ;#
set MW_POWER_PORT               "vdd" ;#
set MW_GROUND_NET               "gnd" ;#
set MW_GROUND_PORT              "gnd" ;#

set MIN_ROUTING_LAYER            ""   ;# Min routing layer
set MAX_ROUTING_LAYER            "M6"   ;# Max routing layer

set PNS_PAD_MASTERS        		"VDDCO_HDRV_MT_1V0_LIN.FRAM VSSCO_HDRV_MT_LIN.FRAM VSSIO_2V5_LIN.FRAM"		;# Only for top level design. Specify cell masters for power pads, e.g. "pv0i.FRAM pv0a.FRAM"

