

SRC_DIR = ..
RUN_NAME = $(VT)_$(Voltage)_$(target_delay)
io2core ?= 30
COMMAND_STRING =  "set VT  $(VT); set Voltage $(Voltage); set target_delay $(target_delay); set io2core $(io2core);"
OPTIMIZED_COMMAND_STRING = "set ENABLE_MANUAL_PLACEMENT 1; set VT  $(VT); set Voltage $(Voltage); set target_delay $(target_delay); set io2core $(io2core);"

all: $(RUN_NAME)/log/icc_optimized_$(RUN_NAME).log $(RUN_NAME)/log/icc_$(RUN_NAME).log

$(RUN_NAME)/log/dc_$(RUN_NAME).log: $(SRC_DIR)/*.v
	mkdir -p $(RUN_NAME)
	cd $(RUN_NAME); mkdir -p log; dc_shell-xg-t -64bit -f ../multiplier_dc.tcl -x $(COMMAND_STRING) | tee -i log/dc_$(RUN_NAME).log

$(RUN_NAME)/log/icc_$(RUN_NAME).log: ./$(RUN_NAME)/log/dc_$(RUN_NAME).log
	mkdir -p $(RUN_NAME)
	cd $(RUN_NAME); mkdir -p log; icc_shell -64bit -f ../multiplier_icc.tcl -x $(COMMAND_STRING) | tee -i log/icc_$(RUN_NAME).log
	rm -rf cache work command.log default.svf filenames.log icc_output.txt *_port_map* nfs* legalizer*

$(RUN_NAME)/log/icc_optimized_$(RUN_NAME).log: ./$(RUN_NAME)/log/dc_$(RUN_NAME).log
	mkdir -p $(RUN_NAME)
	cd $(RUN_NAME); mkdir -p log; icc_shell -64bit -f ../multiplier_icc.tcl -x $(OPTIMIZED_COMMAND_STRING) | tee -i log/icc_optimized_$(RUN_NAME).log
	rm -rf cache work command.log default.svf filenames.log icc_output.txt *_port_map* nfs* legalizer*

clean:
	rm -rf $(RUN_NAME)
