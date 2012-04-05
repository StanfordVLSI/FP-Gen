

SRC_DIR = ..

#Default Values
io2core ?= 30
VT ?= lvt
Voltage ?= 1v0
MOD_NAME ?= MultiplierP
DESIGN_TARGET ?= $(MOD_NAME)_unq1
target_delay ?= 1500

PIPE_CNT ?= xxx

RUN_NAME = $(VT)_$(Voltage)_$(target_delay)_p$(PIPE_CNT)

COMMAND_STRING =  "set VT  $(VT); set Voltage $(Voltage); set target_delay $(target_delay); set io2core $(io2core); set DESIGN_TARGET $(DESIGN_TARGET); "
OPTIMIZED_COMMAND_STRING = "set ENABLE_MANUAL_PLACEMENT 1; set VT  $(VT); set Voltage $(Voltage); set target_delay $(target_delay); set io2core $(io2core); set DESIGN_TARGET $(DESIGN_TARGET); "

all: $(RUN_NAME)/log/icc_optimized_$(RUN_NAME).log $(RUN_NAME)/log/icc_$(RUN_NAME).log

#-64bit

$(RUN_NAME)/log/dc_$(RUN_NAME).log: $(SRC_DIR)/*.v
	@echo ==================================================
	@echo ==================================================
	@echo Making $@ because of $?
	@echo Target: ${DESIGN_TARGET}
	@echo ==================================================
	@echo ==================================================
	mkdir -p $(RUN_NAME)
	cd $(RUN_NAME); mkdir -p log; dc_shell-xg-t -64bit -f ../multiplier_dc.tcl -x $(COMMAND_STRING) 2>&1 | tee -i log/dc_$(RUN_NAME).log
	perl checkRun.pl $(RUN_NAME)/log/dc_$(RUN_NAME).log

$(RUN_NAME)/log/icc_$(RUN_NAME).log: ./$(RUN_NAME)/log/dc_$(RUN_NAME).log
	perl checkRun.pl $(RUN_NAME)/log/dc_$(RUN_NAME).log
	@echo ==================================================
	@echo ==================================================
	@echo Making $@ because of $?
	@echo Target: ${DESIGN_TARGET}
	@echo ==================================================
	@echo ==================================================
	mkdir -p $(RUN_NAME)
	cd $(RUN_NAME); mkdir -p log; icc_shell -64bit -f ../multiplier_icc.tcl -x $(COMMAND_STRING) 2>&1 | tee -i log/icc_$(RUN_NAME).log
	rm -rf cache work command.log default.svf filenames.log icc_output.txt *_port_map* nfs* legalizer*
	perl checkRun.pl $(RUN_NAME)/log/icc_$(RUN_NAME).log

$(RUN_NAME)/log/icc_optimized_$(RUN_NAME).log: ./$(RUN_NAME)/log/dc_$(RUN_NAME).log
	perl checkRun.pl $(RUN_NAME)/log/dc_$(RUN_NAME).log
	perl checkRun.pl $(RUN_NAME)/log/icc_$(RUN_NAME).log
	@echo ==================================================
	@echo ==================================================
	@echo Making $@ because of $?
	@echo Target: ${DESIGN_TARGET}
	@echo ==================================================
	@echo ==================================================
	mkdir -p $(RUN_NAME)
	cd $(RUN_NAME); mkdir -p log; icc_shell -64bit -f ../multiplier_icc.tcl -x $(OPTIMIZED_COMMAND_STRING) 2>&1 | tee -i log/icc_optimized_$(RUN_NAME).log
	rm -rf cache work command.log default.svf filenames.log icc_output.txt *_port_map* nfs* legalizer*
	perl checkRun.pl $(RUN_NAME)/log/icc_optimized_$(RUN_NAME).log

clean:
	rm -rf $(RUN_NAME)
