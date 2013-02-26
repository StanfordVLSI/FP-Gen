
if { $TECH == 90 } {
# ST 90nm
  source $env(FPGEN)/synthesis/synSetup/scr_ST90/common_options.tcl
  source $env(FPGEN)/synthesis/synSetup/scr_ST90/libsetup.tcl -continue_on_error
  source $env(FPGEN)/synthesis/synSetup/scr_ST90/init_psynenv.tcl
}  elseif { $TECH == 28 } {
# ST 28nm
  source $env(FPGEN)/synthesis/synSetup/scr_ST28SOI/common_options.tcl
  source $env(FPGEN)/synthesis/synSetup/scr_ST28SOI/libsetup.tcl -continue_on_error
  source $env(FPGEN)/synthesis/synSetup/scr_ST28SOI/init_psynenv.tcl
} else {
  # TSMC 45nm
  source $env(FPGEN)/synthesis/synSetup/scr_tsmc45/common_options.tcl
  source $env(FPGEN)/synthesis/synSetup/scr_tsmc45/libsetup.tcl -continue_on_error
  source $env(FPGEN)/synthesis/synSetup/scr_tsmc45/init_psynenv.tcl
}




