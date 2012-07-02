
if {[info exists ENABLE_90]} {
# ST 90nm
  source $env(FPGEN)/synthesis/synSetup/synopsys_startup/scr_ST90/common_options.tcl
  source $env(FPGEN)/synthesis/synSetup/synopsys_startup/scr_ST90/libsetup.tcl -continue_on_error
  source $env(FPGEN)/synthesis/synSetup/synopsys_startup/scr_ST90/init_psynenv.tcl
} else {
  # TSMC 45nm
  source $env(FPGEN)/synthesis/synSetup/synopsys_startup/scr_tsmc45/common_options.tcl
  source $env(FPGEN)/synthesis/synSetup/synopsys_startup/scr_tsmc45/libsetup.tcl -continue_on_error
  source $env(FPGEN)/synthesis/synSetup/synopsys_startup/scr_tsmc45/init_psynenv.tcl
}




