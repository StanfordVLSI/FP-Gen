setenv ST28SOIHOME /st28soi-pdk/st28-digital/prods/

setenv SynopsysTechnoKit SynopsysTechnoKit_cmos028FDSOI_6U1x_2U2x_2T8x_LB@2.1.2@20121128.2
setenv ST28SOITECH_ROOT $ST28SOIHOME/$SynopsysTechnoKit

setenv UNITTILE_12T_MW $ST28SOITECH_ROOT/COMMON/UnitTile/unitTile_12T

# RVT core standard cell
setenv CORE28SOILRNAME C32_SC_12_CORE_LR_C28SOI@1.3@20121009.0

setenv CORE28SOILR_V   $ST28SOIHOME/$CORE28SOILRNAME/behaviour/verilog/C32_SC_12_CORE_LR.v
setenv CORE28SOILR_WC $ST28SOIHOME/$CORE28SOILRNAME/libs/C32_SC_12_CORE_LR_ss28_0.90V_125C.db
setenv CORE28SOILR_BC $ST28SOIHOME/$CORE28SOILRNAME/libs/C32_SC_12_CORE_LR_ff28_1.15V_m40C.db 
setenv CORE28SOILR_SYM $ST28SOIHOME/$CORE28SOILRNAME/libs/C32_SC_12_CORE_LR.sdb
setenv CORE28SOILR_MW  $ST28SOIHOME/$CORE28SOILRNAME/SYNOPSYS/PR/C32_SC_12_CORE_LR


# LVT core standard cell
setenv CORE28SOILLNAME C32_SC_12_CORE_LL_C28SOI@2.1@20121009.0

setenv CORE28SOILL_V   $ST28SOIHOME/$CORE28SOILLNAME/behaviour/verilog/C32_SC_12_CORE_LL.v
setenv CORE28SOILL_WC $ST28SOIHOME/$CORE28SOILLNAME/libs/C32_SC_12_CORE_LL_ss28_0.90V_0.00V_0.00V_0.00V_125C.db
setenv CORE28SOILL_BC $ST28SOIHOME/$CORE28SOILLNAME/libs/C32_SC_12_CORE_LL_ff28_1.15V_0.00V_0.00V_0.00V_m40C.db  
setenv CORE28SOILL_SYM $ST28SOIHOME/$CORE28SOILLNAME/libs/C32_SC_12_CORE_LL.sdb
setenv CORE28SOILL_MW  $ST28SOIHOME/$CORE28SOILLNAME/SYNOPSYS/PR/C32_SC_12_CORE_LL


# RVT clock network standard cell
setenv CLK28SOILRNAME C32_SC_12_CLK_LR_C28SOI@1.3@20121008.0

setenv CLK28SOILR_V   $ST28SOIHOME/$CLK28SOILRNAME/behaviour/verilog/C32_SC_12_CLK_LR.v
setenv CLK28SOILR_WC $ST28SOIHOME/$CLK28SOILRNAME/libs/C32_SC_12_CLK_LR_ss28_0.90V_125C.db
setenv CLK28SOILR_BC $ST28SOIHOME/$CLK28SOILRNAME/libs/C32_SC_12_CLK_LR_ff28_1.15V_m40C.db 
setenv CLK28SOILR_SYM $ST28SOIHOME/$CLK28SOILRNAME/libs/C32_SC_12_CLK_LR.sdb
setenv CLK28SOILR_MW  $ST28SOIHOME/$CLK28SOILRNAME/SYNOPSYS/PR/C32_SC_12_CLK_LR



# LVT clock network standard cell
setenv CLK28SOILLNAME C28SOI_SC_12_CLK_LL@1.1@20121009.0

setenv CLK28SOILL_V   $ST28SOIHOME/$CLK28SOILLNAME/behaviour/verilog/C28SOI_SC_12_CLK_LL.v
setenv CLK28SOILL_WC $ST28SOIHOME/$CLK28SOILLNAME/libs/C28SOI_SC_12_CLK_LL_ss28_0.90V_0.00V_0.00V_0.00V_125C.db
setenv CLK28SOILL_BC $ST28SOIHOME/$CLK28SOILLNAME/libs/C28SOI_SC_12_CLK_LL_ff28_1.15V_0.00V_0.00V_0.00V_m40C.db  
setenv CLK28SOILL_SYM $ST28SOIHOME/$CLK28SOILLNAME/libs/C28SOI_SC_12_CLK_LL.sdb
setenv CLK28SOILL_MW  $ST28SOIHOME/$CLK28SOILLNAME/SYNOPSYS/PR/C28SOI_SC_12_CLK_LL



# RVT PR standard cell
setenv PR28SOILRNAME C28SOI_SC_12_PR_LR@1.1@20121010.0

setenv PR28SOILR_V   $ST28SOIHOME/$PR28SOILRNAME/behaviour/verilog/C28SOI_SC_12_PR_LR.v
setenv PR28SOILR_WC $ST28SOIHOME/$PR28SOILRNAME/libs/C28SOI_SC_12_PR_LR_ss28_0.90V_125C.db
setenv PR28SOILR_BC $ST28SOIHOME/$PR28SOILRNAME/libs/C28SOI_SC_12_PR_LR_ff28_1.15V_m40C.db 
setenv PR28SOILR_SYM $ST28SOIHOME/$PR28SOILRNAME/libs/C28SOI_SC_12_PR_LR.sdb
setenv PR28SOILR_MW  $ST28SOIHOME/$PR28SOILRNAME/SYNOPSYS/PR/C28SOI_SC_12_PR_LR



# LVT PR standard cell
setenv PR28SOILLNAME C28SOI_SC_12_PR_LL@1.1@20121010.0

setenv PR28SOILL_V   $ST28SOIHOME/$PR28SOILLNAME/behaviour/verilog/C28SOI_SC_12_PR_LL.v
setenv PR28SOILL_WC $ST28SOIHOME/$PR28SOILLNAME/libs/C28SOI_SC_12_PR_LL_ss28_0.90V_0.00V_0.00V_0.00V_125C.db
setenv PR28SOILL_BC $ST28SOIHOME/$PR28SOILLNAME/libs/C28SOI_SC_12_PR_LL_ff28_1.15V_0.00V_0.00V_0.00V_m40C.db  
setenv PR28SOILL_SYM $ST28SOIHOME/$PR28SOILLNAME/libs/C28SOI_SC_12_PR_LL.sdb
setenv PR28SOILL_MW  $ST28SOIHOME/$PR28SOILLNAME/SYNOPSYS/PR/C28SOI_SC_12_PR_LL


# Basic IO cell
setenv IO28SOI_BASICNAME C28SOI_IO_SF_BASIC_EG_6U1X2U2X2T8XLB@1.1@20120719.0

setenv IO28SOI_BASIC_V   $ST28SOIHOME/$IO28SOI_BASICNAME/behaviour/verilog/C28SOI_IO_SF_BASIC_EG_6U1X2U2X2T8XLB.v
setenv IO28SOI_BASIC_WC $ST28SOIHOME/$IO28SOI_BASICNAME/libs/C28SOI_IO_SF_BASIC_EG_6U1X2U2X2T8XLB_ss28_0.90V_1.65V_125C.db
setenv IO28SOI_BASIC_BC $ST28SOIHOME/$IO28SOI_BASICNAME/libs/C28SOI_IO_SF_BASIC_EG_6U1X2U2X2T8XLB_ff28_1.15V_1.95V_m40C.db
setenv IO28SOI_BASIC_MW  $ST28SOIHOME/$IO28SOI_BASICNAME/SYNOPSYS/PR/C28SOI_IO_SF_BASIC_EG_6U1X2U2X2T8XLB


# Dedicated Core supply IO cell
setenv IO28SOI_CORESUPPLYNAME C28SOI_IO_ALLF_CORESUPPLY_EG_6U1X2U2X2T8XLB@1.0@20120712.0

setenv IO28SOI_CORESUPPLY_V   $ST28SOIHOME/$IO28SOI_CORESUPPLYNAME/behaviour/verilog/C28SOI_IO_ALLF_CORESUPPLY_EG_6U1X2U2X2T8XLB.v
setenv IO28SOI_CORESUPPLY_WC $ST28SOIHOME/$IO28SOI_CORESUPPLYNAME/libs/C28SOI_IO_ALLF_CORESUPPLY_EG_6U1X2U2X2T8XLB_ss28_0.90V_125C.db
setenv IO28SOI_CORESUPPLY_BC $ST28SOIHOME/$IO28SOI_CORESUPPLYNAME/libs/C28SOI_IO_ALLF_CORESUPPLY_EG_6U1X2U2X2T8XLB_ff28_1.15V_m40C.db
setenv IO28SOI_CORESUPPLY_MW  $ST28SOIHOME/$IO28SOI_CORESUPPLYNAME/SYNOPSYS/PR/C28SOI_IO_ALLF_CORESUPPLY_EG_6U1X2U2X2T8XLB

# Programmable Bidirectional IO cell
setenv IO28SOI_IONAME C28SOI_IO_SF_TESTMUX1V8_LR_EG_6U1X2U2X2T8XLB@1.0@20120710.0

setenv IO28SOI_IO_V   $ST28SOIHOME/$IO28SOI_IONAME/behaviour/verilog/C28SOI_IO_SF_TESTMUX1V8_LR_EG_6U1X2U2X2T8XLB.v
setenv IO28SOI_IO_WC $ST28SOIHOME/$IO28SOI_IONAME/libs/C28SOI_IO_SF_TESTMUX1V8_LR_EG_6U1X2U2X2T8XLB_ss28_0.90V_1.65V_125C.db
setenv IO28SOI_IO_BC $ST28SOIHOME/$IO28SOI_IONAME/libs/C28SOI_IO_SF_TESTMUX1V8_LR_EG_6U1X2U2X2T8XLB_ff28_1.15V_1.95V_m40C.db
setenv IO28SOI_IO_MW  $ST28SOIHOME/$IO28SOI_IONAME/SYNOPSYS/PR/C28SOI_IO_SF_TESTMUX1V8_LR_EG_6U1X2U2X2T8XLB

# Physical only IO cell
# Frame Kit
setenv IO28SOI_FRAMEKITNAME C28SOI_IO_ALLF_FRAMEKIT_EG_6U1X2U2X2T8XLB@1.1@20120709.4
setenv IO28SOI_FRAMEKIT_MW  $ST28SOIHOME/$IO28SOI_FRAMEKITNAME/SYNOPSYS/LAYOUT/C28SOI_IO_ALLF_FRAMEKIT_EG_6U1X2U2X2T8XLB_CEL
# IO Supply Kit
setenv IO28SOI_SUPPLYKITNAME C28SOI_IO_ALLF_IOSUPPLYKIT_EG_6U1X2U2X2T8XLB@1.0@20120718.1
setenv IO28SOI_SUPPLYKIT_MW  $ST28SOIHOME/$IO28SOI_SUPPLYKITNAME/SYNOPSYS/LAYOUT/C28SOI_IO_ALLF_IOSUPPLYKIT_EG_6U1X2U2X2T8XLB_CEL
# Bump
setenv IO28SOI_BUMPNAME C28SOI_IO_BUMP_6U1X2U2X2T8XLB@1.0@20120628.0
setenv IO28SOI_BUMP_MW  $ST28SOIHOME/$IO28SOI_BUMPNAME/SYNOPSYS/PR/C28SOI_IO_BUMP_6U1X2U2X2T8XLB