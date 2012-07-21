

setenv TSMCHOME /cad/synopsys_EDK2/TSMCHOME


#main standard cell libraries
setenv TSMC_LIB_DIR $TSMCHOME/digital/Front_End/timing_power_noise/NLDM

#Coarse grain libraries for Multi voltage flows
setenv TSMC_CGLIB_DIR $TSMCHOME/digital/Front_End/timing_power

#Milkyway libraries for physical design
setenv TSMC_MWLIB_DIR $TSMCHOME/digital/Back_End/milkyway


#First: Standard Vt libraries

setenv TCBN45GSNAME tcbn45gsbwp_110a

setenv TCBN45GS_SVT_WC_0V8 $TSMC_LIB_DIR/$TCBN45GSNAME/tcbn45gsbwpwc0d72.db
setenv TCBN45GS_SVT_BC_0V8 $TSMC_LIB_DIR/$TCBN45GSNAME/tcbn45gsbwpbc0d88.db
setenv TCBN45GS_SVT_WC_0V9 $TSMC_LIB_DIR/$TCBN45GSNAME/tcbn45gsbwpwc.db
setenv TCBN45GS_SVT_BC_0V9 $TSMC_LIB_DIR/$TCBN45GSNAME/tcbn45gsbwpbc.db
setenv TCBN45GS_SVT_WC_1V0 $TSMC_LIB_DIR/$TCBN45GSNAME/tcbn45gsbwpwc0d9.db
setenv TCBN45GS_SVT_BC_1V0 $TSMC_LIB_DIR/$TCBN45GSNAME/tcbn45gsbwpbc1d1.db

setenv TCBN45GS_SVT_MW $TSMC_MWLIB_DIR/$TCBN45GSNAME/frame_only_VHV_0d5_0/tcbn45gsbwp


#Second: Low Vt libraries

setenv TCBN45GSLVTNAME tcbn45gsbwplvt_110a

setenv TCBN45GS_LVT_WC_0V8 $TSMC_LIB_DIR/$TCBN45GSLVTNAME/tcbn45gsbwplvtwc0d72.db
setenv TCBN45GS_LVT_BC_0V8 $TSMC_LIB_DIR/$TCBN45GSLVTNAME/tcbn45gsbwplvtbc0d88.db
setenv TCBN45GS_LVT_WC_0V9 $TSMC_LIB_DIR/$TCBN45GSLVTNAME/tcbn45gsbwplvtwc.db
setenv TCBN45GS_LVT_BC_0V9 $TSMC_LIB_DIR/$TCBN45GSLVTNAME/tcbn45gsbwplvtbc.db
setenv TCBN45GS_LVT_WC_1V0 $TSMC_LIB_DIR/$TCBN45GSLVTNAME/tcbn45gsbwplvtwc0d9.db
setenv TCBN45GS_LVT_BC_1V0 $TSMC_LIB_DIR/$TCBN45GSLVTNAME/tcbn45gsbwplvtbc1d1.db

setenv TCBN45GSLVT_MW $TSMC_MWLIB_DIR/$TCBN45GSLVTNAME/frame_only_VHV_0d5_0/tcbn45gsbwplvt

#Third: High Vt libraries

setenv TCBN45GSHVTNAME tcbn45gsbwphvt_110a

setenv TCBN45GS_HVT_WC_0V8 $TSMC_LIB_DIR/$TCBN45GSHVTNAME/tcbn45gsbwphvtwc0d72.db
setenv TCBN45GS_HVT_BC_0V8 $TSMC_LIB_DIR/$TCBN45GSHVTNAME/tcbn45gsbwphvtbc0d88.db
setenv TCBN45GS_HVT_WC_0V9 $TSMC_LIB_DIR/$TCBN45GSHVTNAME/tcbn45gsbwphvtwc.db
setenv TCBN45GS_HVT_BC_0V9 $TSMC_LIB_DIR/$TCBN45GSHVTNAME/tcbn45gsbwphvtbc.db
setenv TCBN45GS_HVT_WC_1V0 $TSMC_LIB_DIR/$TCBN45GSHVTNAME/tcbn45gsbwphvtwc0d9.db
setenv TCBN45GS_HVT_BC_1V0 $TSMC_LIB_DIR/$TCBN45GSHVTNAME/tcbn45gsbwphvtbc1d1.db

setenv TCBN45GSHVT_MW $TSMC_MWLIB_DIR/$TCBN45GSHVTNAME/frame_only_VHV_0d5_0/tcbn45gsbwphvt




