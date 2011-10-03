This is a Floating Point Adder/Multiplier/Multiply-Accumulate generator and testbench

To run it, use:
  make clean [gen|run] [SIM_ENGINE=mentor] [GENESIS_HIERARCHY=new.xml] [GENESIS_CFG_XML=SysCfgs/changefile.xml]
Example:
  make clean gen GENESIS_CFG_XML=SysCfgs/my_config.xml
  make clean run GENESIS_CFG_XML=SysCfgs/your_config.xml


* gen|run -- choose to either just generate the design also run the testbench
* Replace SIM_ENGINE=mentor with SIM_ENGINE=synopsys for using synopsys simulation tools.
* GENESIS_HIERARCHY=new.xml redirect the OUTPUT xml file to file 'new.xml' (important for the gui)
* GENESIS_CFG_XML=SysCfgs/changefile.xml tells genesis to use the design configuration specified in 'changefile.xml'

