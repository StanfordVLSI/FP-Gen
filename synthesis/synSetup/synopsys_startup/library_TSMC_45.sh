

export TSMCHOME=/cad/synopsys_EDK2/TSMCHOME


#main standard cell libraries
export TSMC_LIB_DIR=$TSMCHOME/digital/Front_End/timing_power_noise/NLDM

#Coarse grain libraries for Multi voltage flows
export TSMC_CGLIB_DIR=$TSMCHOME/digital/Front_End/timing_power

#Milkyway libraries for physical design
export TSMC_MWLIB_DIR=$TSMCHOME/digital/Back_End/milkyway


#First: Standard Vt libraries

export TCBN45GSNAME=tcbn45gsbwp_110a

export TCBN45GS_SVT_WC_0V8=$TSMC_LIB_DIR/$TCBN45GSNAME/tcbn45gsbwpwc0d72.db
export TCBN45GS_SVT_BC_0V8=$TSMC_LIB_DIR/$TCBN45GSNAME/tcbn45gsbwpbc0d88.db
export TCBN45GS_SVT_WC_0V9=$TSMC_LIB_DIR/$TCBN45GSNAME/tcbn45gsbwpwc.db
export TCBN45GS_SVT_BC_0V9=$TSMC_LIB_DIR/$TCBN45GSNAME/tcbn45gsbwpbc.db
export TCBN45GS_SVT_WC_1V0=$TSMC_LIB_DIR/$TCBN45GSNAME/tcbn45gsbwpwc0d9.db
export TCBN45GS_SVT_BC_1V0=$TSMC_LIB_DIR/$TCBN45GSNAME/tcbn45gsbwpbc1d1.db

export TCBN45GS_SVT_MW=$TSMC_MWLIB_DIR/$TCBN45GSNAME/frame_only_VHV_0d5_0/tcbn45gsbwp


#Second: Low Vt libraries

export TCBN45GSLVTNAME=tcbn45gsbwplvt_110a

export TCBN45GS_LVT_WC_0V8=$TSMC_LIB_DIR/$TCBN45GSLVTNAME/tcbn45gsbwplvtwc0d72.db
export TCBN45GS_LVT_BC_0V8=$TSMC_LIB_DIR/$TCBN45GSLVTNAME/tcbn45gsbwplvtbc0d88.db
export TCBN45GS_LVT_WC_0V9=$TSMC_LIB_DIR/$TCBN45GSLVTNAME/tcbn45gsbwplvtwc.db
export TCBN45GS_LVT_BC_0V9=$TSMC_LIB_DIR/$TCBN45GSLVTNAME/tcbn45gsbwplvtbc.db
export TCBN45GS_LVT_WC_1V0=$TSMC_LIB_DIR/$TCBN45GSLVTNAME/tcbn45gsbwplvtwc0d9.db
export TCBN45GS_LVT_BC_1V0=$TSMC_LIB_DIR/$TCBN45GSLVTNAME/tcbn45gsbwplvtbc1d1.db

export TCBN45GSLVT_MW=$TSMC_MWLIB_DIR/$TCBN45GSLVTNAME/frame_only_VHV_0d5_0/tcbn45gsbwplvt

#Third: High Vt libraries

export TCBN45GSHVTNAME=tcbn45gsbwphvt_110a

export TCBN45GS_HVT_WC_0V8=$TSMC_LIB_DIR/$TCBN45GSHVTNAME/tcbn45gsbwphvtwc0d72.db
export TCBN45GS_HVT_BC_0V8=$TSMC_LIB_DIR/$TCBN45GSHVTNAME/tcbn45gsbwphvtbc0d88.db
export TCBN45GS_HVT_WC_0V9=$TSMC_LIB_DIR/$TCBN45GSHVTNAME/tcbn45gsbwphvtwc.db
export TCBN45GS_HVT_BC_0V9=$TSMC_LIB_DIR/$TCBN45GSHVTNAME/tcbn45gsbwphvtbc.db
export TCBN45GS_HVT_WC_1V0=$TSMC_LIB_DIR/$TCBN45GSHVTNAME/tcbn45gsbwphvtwc0d9.db
export TCBN45GS_HVT_BC_1V0=$TSMC_LIB_DIR/$TCBN45GSHVTNAME/tcbn45gsbwphvtbc1d1.db

export TCBN45GSHVT_MW=$TSMC_MWLIB_DIR/$TCBN45GSHVTNAME/frame_only_VHV_0d5_0/tcbn45gsbwphvt




